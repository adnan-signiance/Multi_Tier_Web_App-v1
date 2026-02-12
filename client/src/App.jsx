import { useState, useEffect } from 'react'
import { 
  Target, 
  Mail, 
  User, 
  Phone, 
  Calendar, 
  ArrowRight, 
  Loader2, 
  CheckCircle2, 
  AlertCircle, 
  DollarSign, 
  Users,
  Shield,
  Activity
} from 'lucide-react'
import logoImage from './assets/Untitled.png'
import './App.css'

function App() {
  const [loading, setLoading] = useState(false)
  const [submitting, setSubmitting] = useState(false)
  const [users, setUsers] = useState([])
  const [message, setMessage] = useState('')
  const [isSuccess, setIsSuccess] = useState(null)

  const [formData, setFormData] = useState({
    first_name: '',
    last_name: '',
    age: '',
    email: '',
    phone_number: ''
  })

  useEffect(() => {
    fetchUsers()
  }, [])

  const fetchUsers = async () => {
    try {
      setLoading(true)
      const apiUrl = import.meta.env.VITE_API_URL || 'http://localhost:5000'
      const response = await fetch(`${apiUrl}/api/users`)
      if (response.ok) {
        const data = await response.json()
        setUsers(data)
      }
    } catch (error) {
      console.error('Error fetching users:', error)
    } finally {
      setLoading(false)
    }
  }

  const handleChange = (e) => {
    const { name, value } = e.target
    setFormData(prev => ({ ...prev, [name]: value }))
  }

  const handleSubmit = async (e) => {
    e.preventDefault()
    if (!formData.first_name || !formData.last_name || !formData.email) {
      setMessage('Please fill in required fields.')
      setIsSuccess(false)
      return
    }

    setSubmitting(true)
    setMessage('')
    
    try {
      const apiUrl = import.meta.env.VITE_API_URL || 'http://localhost:5000'
      const response = await fetch(`${apiUrl}/api/users`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(formData)
      })

      if (response.ok) {
        setIsSuccess(true)
        setMessage('User registered successfully!')
        setFormData({
          first_name: '',
          last_name: '',
          age: '',
          email: '',
          phone_number: ''
        })
        fetchUsers()
      } else {
        const data = await response.json()
        setIsSuccess(false)
        setMessage(data.error || 'Failed to register.')
      }
    } catch (error) {
      setIsSuccess(false)
      setMessage('Network error. Try again.')
    } finally {
      setSubmitting(false)
    }
  }

  return (
    <div className="app-container">
      
      {/* LEFT SIDE: Hero Section */}
      <div className="hero-section">
        {/* Animated Background */}
        <div className="hero-bg">
          <div className="grid-pattern"></div>
          <div className="glow-orb-1"></div>
          <div className="glow-orb-2"></div>
        </div>

        {/* Brand / Logo */}
        <div className="logo-section">
          <img src={logoImage} alt="MultiTier" className="brand-logo" />
        </div>

        {/* Middle Content */}
        <div className="hero-content">
          <div className="vertical-line-gradient"></div>
          
          <h1 className="hero-title">
            Build your<br />
            <span>Digital Empire.</span>
          </h1>
          <p className="hero-description">
            Join the platform that powers the next generation of web applications. Secure, scalable, and built for speed.
          </p>

          {/* Stats Cards */}
          <div className="stats-container">
            <div className="glass-card stat-card animate-float">
              <div className="stat-header">
                <div className="icon-box icon-green">
                  <DollarSign size={16} />
                </div>
                <div>
                  <p className="stat-label">Total Volume</p>
                  <p className="stat-value">$1,240.50</p>
                </div>
              </div>
              <div className="stat-footer">
                <span className="ping-wrapper">
                  <span className="ping-dot"></span>
                  <span className="ping-static"></span>
                </span>
                <span className="stat-trend">+12% vs yesterday</span>
              </div>
            </div>

            <div className="glass-card stat-card animate-float-delayed" style={{ marginTop: '2rem' }}>
              <div className="stat-header">
                <div className="icon-box icon-blue">
                  <Users size={16} />
                </div>
                <div>
                  <p className="stat-label">Active Users</p>
                  <p className="stat-value">{users.length > 0 ? users.length : 842}</p>
                </div>
              </div>
              <div className="stat-footer" style={{ width: '100%' }}>
                  <div className="progress-bar-bg">
                    <div className="progress-bar-fill"></div>
                  </div>
              </div>
            </div>
          </div>
        </div>

        {/* Footer */}
        <div className="footer-compliance">
          <div className="compliance-item">
            <Shield size={16} color="#4b5563" /> Secure Registration
          </div>
          <div className="compliance-item">
            <Activity size={16} color="#4b5563" /> Systems Online
          </div>
        </div>
      </div>

      {/* RIGHT SIDE: Form Section */}
      <div className="form-section">
        <div className="mobile-orb"></div>
        <div className="glass-card form-card">
          <div className="top-gradient-border"></div>
          
          <div className="form-header">
            <h2 className="form-title">Join The Network</h2>
            <p className="form-subtitle">Enter your details to create an account.</p>
          </div>

          <form onSubmit={handleSubmit}>
            <div className="form-group">
              <label className="form-label">Name</label>
              <div style={{ display: 'flex', gap: '0.5rem' }}>
                <div className="input-wrapper" style={{ flex: 1 }}>
                  <User size={16} className="input-icon" />
                  <input
                    type="text"
                    name="first_name"
                    placeholder="First"
                    value={formData.first_name}
                    onChange={handleChange}
                    required
                    className="form-input"
                  />
                </div>
                <div className="input-wrapper" style={{ flex: 1 }}>
                  <User size={16} className="input-icon" />
                  <input
                    type="text"
                    name="last_name"
                    placeholder="Last"
                    value={formData.last_name}
                    onChange={handleChange}
                    required
                    className="form-input"
                  />
                </div>
              </div>
            </div>

            <div className="form-group">
              <label className="form-label">Email Address</label>
              <div className="input-wrapper">
                <Mail size={16} className="input-icon" />
                <input
                  type="email"
                  name="email"
                  placeholder="founder@example.com"
                  value={formData.email}
                  onChange={handleChange}
                  required
                  className="form-input"
                />
              </div>
            </div>

            <div className="form-group" style={{ display: 'flex', gap: '0.5rem' }}>
              <div style={{ flex: 1 }}>
                <label className="form-label">Age</label>
                <div className="input-wrapper">
                  <Calendar size={16} className="input-icon" />
                  <input
                    type="number"
                    name="age"
                    placeholder="25"
                    value={formData.age}
                    onChange={handleChange}
                    className="form-input"
                  />
                </div>
              </div>
              <div style={{ flex: 2 }}>
                <label className="form-label">Phone</label>
                <div className="input-wrapper">
                  <Phone size={16} className="input-icon" />
                  <input
                    type="tel"
                    name="phone_number"
                    placeholder="+1 234 567 890"
                    value={formData.phone_number}
                    onChange={handleChange}
                    className="form-input"
                  />
                </div>
              </div>
            </div>

            <button
              type="submit"
              disabled={submitting}
              className="submit-btn"
            >
              <div className="shimmer"></div>
              {submitting ? (
                <Loader2 size={20} className="animate-spin" />
              ) : (
                <>
                  Create Account <ArrowRight size={16} style={{ marginLeft: '0.5rem' }} />
                </>
              )}
            </button>
          </form>

          {message && (
            <div style={{ 
              marginTop: '1.5rem', 
              padding: '0.75rem', 
              borderRadius: '0.5rem', 
              backgroundColor: isSuccess ? 'rgba(34, 197, 94, 0.1)' : 'rgba(239, 68, 68, 0.1)',
              color: isSuccess ? 'var(--color-green-400)' : '#f87171',
              border: `1px solid ${isSuccess ? 'rgba(34, 197, 94, 0.2)' : 'rgba(239, 68, 68, 0.2)'}`,
              display: 'flex',
              alignItems: 'center',
              gap: '0.5rem',
              fontSize: '0.875rem'
            }}>
              {isSuccess ? <CheckCircle2 size={16} /> : <AlertCircle size={16} />}
              {message}
            </div>
          )}

          {/* User List Preview */}
          {users.length > 0 && (
            <div className="user-list-section">
              <p className="form-label" style={{ marginBottom: '0.5rem' }}>Recent Users</p>
              {users.slice(0, 3).map(user => (
                <div key={user.id} className="user-item">
                  <span>{user.first_name} {user.last_name}</span>
                  <span className="user-email">{user.email}</span>
                </div>
              ))}
            </div>
          )}

        </div>
      </div>
    </div>
  )
}

export default App
