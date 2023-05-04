import './ProfileAvatar.css';

export default function ProfileAvatar(props) {
  const backgroundImage = `url("https://assets.bytetech.digital/avatars/processed/${props.id}.jpg")`;
  const styles = {
    backgroundImage: backgroundImage,
    backgroundSize: 'cover',
    backgroundPosition: 'center',
  };

  return (
    <div 
      className="profile-avatar"
      style={styles}
    ></div>
  );
}