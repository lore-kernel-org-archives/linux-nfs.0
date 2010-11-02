Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from exprod5og104.obsmtp.com ([64.18.0.178]:59496 "HELO
	exprod5og104.obsmtp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1752609Ab0KBGey (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 2 Nov 2010 02:34:54 -0400
Message-ID: <4CCFB107.1090600@panasas.com>
Date: Tue, 02 Nov 2010 08:34:47 +0200
From: Benny Halevy <bhalevy@panasas.com>
To: Jim Rees <rees@umich.edu>
CC: linux-nfs@vger.kernel.org, Eric Anderle <eanderle@umich.edu>,
        peter honeyman <honey@citi.umich.edu>
Subject: Re: [PATCH] nfs-utils: Various bug fixes and cleanups to blkmapd
References: <20101029153637.GA31961@merit.edu>
In-Reply-To: <20101029153637.GA31961@merit.edu>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hi Jim, Sorry for the late response.

There are conflicts merging this patch as bldev_read_ap_state
is already defined (in "Add complex block layout discovery and mapping daemon")
I'm not sure how, but we seem out of sync, maybe I didn't get an earlier patch
of yours.

I've rebased the nfs-utils tree onto nfs-utils-1-2-4-rc1 and pushed it out
so please rebase your changes on top of it and resend.

Thanks,

Benny

On 2010-10-29 17:36, Jim Rees wrote:
> Add "-d" command line option to just do discovery then exit
> 
> Restore active/passive test but ignore passive devices
> 
> Don't log EUI errors.  These aren't really errors, since we'll fall back to
> a different id type, or just use the file name.
> 
> Eliminate fd/pidfd confusion
> 
> use INFO syslog level instead of ERR for info messages
> 
> Signed-off-by: Jim Rees <rees@umich.edu>
> ---
>  utils/blkmapd/device-discovery.c |   87 ++++++++++++++++++++++---------------
>  utils/blkmapd/device-discovery.h |    2 +
>  utils/blkmapd/device-inq.c       |   35 +++++++++++----
>  utils/blkmapd/device-process.c   |   22 +++-------
>  4 files changed, 86 insertions(+), 60 deletions(-)
> 
> diff --git a/utils/blkmapd/device-discovery.c b/utils/blkmapd/device-discovery.c
> index 271c7ed..0497a11 100644
> --- a/utils/blkmapd/device-discovery.c
> +++ b/utils/blkmapd/device-discovery.c
> @@ -153,6 +153,11 @@ void bl_add_disk(char *filepath)
>  
>  	dev = sb.st_rdev;
>  	serial = bldev_read_serial(fd, filepath);
> +	ap_state = bldev_read_ap_state(fd);
> +	close(fd);
> +
> +	if (ap_state == BL_PATH_STATE_PASSIVE)
> +		return;
>  
>  	for (disk = visible_disk_list; disk != NULL; disk = disk->next) {
>  		/* Already scanned or a partition?
> @@ -165,14 +170,10 @@ void bl_add_disk(char *filepath)
>  		}
>  	}
>  
> -	if (disk && diskpath) {
> -		close(fd);
> +	if (disk && diskpath)
>  		return;
> -	}
> -
> -	close(fd);
>  
> -	BL_LOG_ERR("%s: %s\n", __func__, filepath);
> +	BL_LOG_INFO("%s: %s\n", __func__, filepath);
>  
>  	/*
>  	 * Not sure how to identify a pseudo device created by
> @@ -180,8 +181,6 @@ void bl_add_disk(char *filepath)
>  	 */
>  	if (strncmp(filepath, "/dev/mapper", 11) == 0)
>  		ap_state = BL_PATH_STATE_PSEUDO;
> -	else
> -		ap_state = BL_PATH_STATE_ACTIVE;
>  
>  	/* add path */
>  	path = malloc(sizeof(struct bl_disk_path));
> @@ -321,7 +320,7 @@ int bl_disk_inquiry_process(int fd)
>  		bl_discover_devices();
>  		if (!process_deviceinfo(buf, buflen, &major, &minor)) {
>  			head->status = BL_DEVICE_REQUEST_ERR;
> -			goto out;
> +			break;
>  		}
>  		tmp = realloc(head, sizeof(major) + sizeof(minor) +
>  			      sizeof(struct pipefs_hdr));
> @@ -343,6 +342,7 @@ int bl_disk_inquiry_process(int fd)
>  		break;
>  	default:
>  		head->status = BL_DEVICE_REQUEST_ERR;
> +		break;
>  	}
>  
>  	head->totallen = sizeof(struct pipefs_hdr) + len;
> @@ -399,49 +399,61 @@ int bl_run_disk_inquiry_process(int fd)
>  /* Daemon */
>  int main(int argc, char **argv)
>  {
> -	int fd, opt, fg = 0, ret = 1;
> +	int fd, pidfd = -1, opt, dflag = 0, fg = 0, ret = 1;
>  	struct stat statbuf;
>  	char pidbuf[64];
>  
> -	while ((opt = getopt(argc, argv, "f")) != -1) {
> +	while ((opt = getopt(argc, argv, "df")) != -1) {
>  		switch (opt) {
> +		case 'd':
> +			dflag = 1;
> +			break;
>  		case 'f':
>  			fg = 1;
>  			break;
>  		}
>  	}
>  
> -	if (!stat(PID_FILE, &statbuf)) {
> -		fprintf(stderr, "Pid file already existed\n");
> -		return -1;
> -	}
> +	if (fg) {
> +		openlog("blkmapd", LOG_PERROR, 0);
> +	} else {
> +		if (!stat(PID_FILE, &statbuf)) {
> +			fprintf(stderr, "Pid file %s already existed\n", PID_FILE);
> +			exit(1);
> +		}
>  
> -	if (!fg && daemon(0, 0) != 0) {
> -		fprintf(stderr, "Daemonize failed\n");
> -		return -1;
> -	}
> +		if (daemon(0, 0) != 0) {
> +			fprintf(stderr, "Daemonize failed\n");
> +			exit(1);
> +		}
>  
> -	openlog("blkmapd", LOG_PID, 0);
> -	fd = open(PID_FILE, O_WRONLY | O_CREAT, 0644);
> -	if (fd < 0) {
> -		BL_LOG_ERR("Create pid file failed\n");
> -		return -1;
> +		openlog("blkmapd", LOG_PID, 0);
> +		pidfd = open(PID_FILE, O_WRONLY | O_CREAT, 0644);
> +		if (pidfd < 0) {
> +			BL_LOG_ERR("Create pid file %s failed\n", PID_FILE);
> +			exit(1);
> +		}
> +
> +		if (lockf(pidfd, F_TLOCK, 0) < 0) {
> +			BL_LOG_ERR("Lock pid file %s failed\n", PID_FILE);
> +			close(pidfd);
> +			exit(1);
> +		}
> +		ftruncate(pidfd, 0);
> +		sprintf(pidbuf, "%d\n", getpid());
> +		write(pidfd, pidbuf, strlen(pidbuf));
>  	}
>  
> -	if (lockf(fd, F_TLOCK, 0) < 0) {
> -		BL_LOG_ERR("Lock pid file failed\n");
> -		close(fd);
> -		return -1;
> +	if (dflag) {
> +		bl_discover_devices();
> +		exit(0);
>  	}
> -	ftruncate(fd, 0);
> -	sprintf(pidbuf, "%d\n", getpid());
> -	write(fd, pidbuf, strlen(pidbuf));
>  
>  	/* open pipe file */
>  	fd = open(BL_PIPE_FILE, O_RDWR);
>  	if (fd < 0) {
> -		BL_LOG_ERR("open pipe file error\n");
> -		return -1;
> +		BL_LOG_ERR("open pipe file %s error\n", BL_PIPE_FILE);
> +		exit(1);
>  	}
>  
>  	while (1) {
> @@ -454,6 +466,11 @@ int main(int argc, char **argv)
>  			BL_LOG_ERR("inquiry process return %d\n", ret);
>  		}
>  	}
> -	close(fd);
> -	return ret;
> +
> +	if (pidfd >= 0) {
> +		close(pidfd);
> +		unlink(PID_FILE);
> +	}
> +
> +	exit(ret);
>  }
> diff --git a/utils/blkmapd/device-discovery.h b/utils/blkmapd/device-discovery.h
> index 4d12cba..8cf88b8 100644
> --- a/utils/blkmapd/device-discovery.h
> +++ b/utils/blkmapd/device-discovery.h
> @@ -151,8 +151,10 @@ uint64_t process_deviceinfo(const char *dev_addr_buf,
>  extern ssize_t atomicio(ssize_t(*f) (int, void *, size_t),
>  			int fd, void *_s, size_t n);
>  extern struct bl_serial *bldev_read_serial(int fd, const char *filename);
> +extern enum bl_path_state_e bldev_read_ap_state(int fd);
>  extern int bl_discover_devices(void);
>  
> +#define BL_LOG_INFO(fmt...)		syslog(LOG_INFO, fmt)
>  #define BL_LOG_WARNING(fmt...)		syslog(LOG_WARNING, fmt)
>  #define BL_LOG_ERR(fmt...)		syslog(LOG_ERR, fmt)
>  #define BL_LOG_DEBUG(fmt...)		syslog(LOG_DEBUG, fmt)
> diff --git a/utils/blkmapd/device-inq.c b/utils/blkmapd/device-inq.c
> index c817e72..e1c0128 100644
> --- a/utils/blkmapd/device-inq.c
> +++ b/utils/blkmapd/device-inq.c
> @@ -52,9 +52,10 @@
>  #define DEF_ALLOC_LEN	255
>  #define MX_ALLOC_LEN	(0xc000 + 0x80)
>  
> -struct bl_serial *bl_create_scsi_string(int len, const char *bytes)
> +static struct bl_serial *bl_create_scsi_string(int len, const char *bytes)
>  {
>  	struct bl_serial *s;
> +
>  	s = malloc(sizeof(*s) + len);
>  	if (s) {
>  		s->data = (char *)&s[1];
> @@ -64,7 +65,7 @@ struct bl_serial *bl_create_scsi_string(int len, const char *bytes)
>  	return s;
>  }
>  
> -void bl_free_scsi_string(struct bl_serial *str)
> +static void bl_free_scsi_string(struct bl_serial *str)
>  {
>  	if (str)
>  		free(str);
> @@ -107,7 +108,7 @@ static int bldev_inquire_page(int fd, int page, char *buffer, int len)
>  	return -1;
>  }
>  
> -int bldev_inquire_pages(int fd, int page, char **buffer)
> +static int bldev_inquire_pages(int fd, int page, char **buffer)
>  {
>  	int status = 0;
>  	char *tmp;
> @@ -149,6 +150,27 @@ int bldev_inquire_pages(int fd, int page, char **buffer)
>  	return status;
>  }
>  
> +/* For EMC multipath devices, use VPD page (0xc0) to get status.
> + * For other devices, return ACTIVE for now
> + */
> +extern enum bl_path_state_e bldev_read_ap_state(int fd)
> +{
> +	int status = 0;
> +	char *buffer = NULL;
> +	enum bl_path_state_e ap_state = BL_PATH_STATE_ACTIVE;
> +
> +	status = bldev_inquire_pages(fd, 0xc0, &buffer);
> +	if (status)
> +		goto out;
> +
> +	if (buffer[4] < 0x02)
> +		ap_state = BL_PATH_STATE_PASSIVE;
> + out:
> +	if (buffer)
> +		free(buffer);
> +	return ap_state;
> +}
> +
>  struct bl_serial *bldev_read_serial(int fd, const char *filename)
>  {
>  	struct bl_serial *serial_out = NULL;
> @@ -177,11 +199,8 @@ struct bl_serial *bldev_read_serial(int fd, const char *filename)
>  			 */
>  		case 2:	/* EUI-64 based */
>  			if ((dev_id->len != 8) && (dev_id->len != 12) &&
> -			    (dev_id->len != 16)) {
> -				BL_LOG_ERR("EUI-64 only decodes 8, "
> -					   "12 and 16\n");
> +			    (dev_id->len != 16))
>  				break;
> -			}
>  		case 3:	/* NAA */
>  			/* TODO: NAA validity judgement too complicated,
>  			 * so just ingore it here.
> @@ -198,8 +217,6 @@ struct bl_serial *bldev_read_serial(int fd, const char *filename)
>  			serial_out = bl_create_scsi_string(dev_id->len,
>  							   dev_id->data);
>  			break;
> -		default:
> -			break;
>  		}
>  		if (current_id == 3)
>  			break;
> diff --git a/utils/blkmapd/device-process.c b/utils/blkmapd/device-process.c
> index c4e72ea..51158dd 100644
> --- a/utils/blkmapd/device-process.c
> +++ b/utils/blkmapd/device-process.c
> @@ -82,7 +82,7 @@ static int decode_blk_signature(uint32_t **pp, uint32_t *end,
>  		 * for mapping, then thrown away.
>  		 */
>  		sig->si_comps[i].bs_string = (char *)p;
> -		BL_LOG_ERR("%s: si_comps[%d]: bs_length %d, bs_string %s\n",
> +		BL_LOG_INFO("%s: si_comps[%d]: bs_length %d, bs_string %s\n",
>  			   __func__, i, sig->si_comps[i].bs_length,
>  			   sig->si_comps[i].bs_string);
>  		p += ((tmp + 3) >> 2);
> @@ -126,7 +126,7 @@ read_cmp_blk_sig(const char *dev_name, struct bl_sig_comp *comp,
>  		goto error;
>  	}
>  
> -	BL_LOG_ERR
> +	BL_LOG_INFO
>  	    ("%s: %s sig: %s, bs_string: %s, bs_length: %d, bs_offset: %lld\n",
>  	     __func__, dev_name, sig, comp->bs_string, comp->bs_length,
>  	     (long long)bs_offset);
> @@ -155,7 +155,7 @@ static int verify_sig(struct bl_disk *disk, struct bl_sig *sig)
>  		bs_offset = comp->bs_offset;
>  		if (bs_offset < 0)
>  			bs_offset += (((int64_t) disk->size) << 9);
> -		BL_LOG_ERR("%s: bs_offset: %lld\n",
> +		BL_LOG_INFO("%s: bs_offset: %lld\n",
>  			   __func__, (long long) bs_offset);
>  		ret = read_cmp_blk_sig(disk->valid_path->full_path,
>  				       comp, bs_offset);
> @@ -180,7 +180,7 @@ static int map_sig_to_device(struct bl_sig *sig, struct bl_volume *vol)
>  	struct bl_disk *lolDisk = disk;
>  
>  	while (lolDisk) {
> -		BL_LOG_ERR("%s: visible_disk_list: %s\n", __func__,
> +		BL_LOG_INFO("%s: visible_disk_list: %s\n", __func__,
>  			   lolDisk->valid_path->full_path);
>  		lolDisk = lolDisk->next;
>  	}
> @@ -324,16 +324,14 @@ uint64_t process_deviceinfo(const char *dev_addr_buf,
>  	uint32_t *p, *end;
>  	struct bl_volume *vols = NULL, **arrays = NULL, **arrays_ptr = NULL;
>  	uint64_t dev = 0;
> -	int tried = 0;
>  
> - restart:
>  	p = (uint32_t *) dev_addr_buf;
>  	end = (uint32_t *) ((char *)p + dev_addr_len);
>  	/* Decode block volume */
>  	BLK_READBUF(p, end, 4);
>  	READ32(num_vols);
>  	if (num_vols <= 0) {
> -		BL_LOG_WARNING("Error: number of vols: %d\n", num_vols);
> +		BL_LOG_ERR("Error: number of vols: %d\n", num_vols);
>  		goto out_err;
>  	}
>  
> @@ -363,15 +361,6 @@ uint64_t process_deviceinfo(const char *dev_addr_buf,
>  	for (i = 0; i < num_vols; i++) {
>  		vols[i].bv_vols = arrays_ptr;
>  		status = decode_blk_volume(&p, end, vols, i, &count);
> -		if (status == -ENXIO && (tried <= 5)) {
> -			sleep(1);
> -			BL_LOG_DEBUG("%s: discover again!\n", __func__);
> -			bl_discover_devices();
> -			tried++;
> -			free(vols);
> -			free(arrays);
> -			goto restart;
> -		}
>  		if (status)
>  			goto out_err;
>  		arrays_ptr += count;
> @@ -385,6 +374,7 @@ uint64_t process_deviceinfo(const char *dev_addr_buf,
>  	dev = dm_device_create(vols, num_vols);
>  	*major = MAJOR(dev);
>  	*minor = MINOR(dev);
> +
>   out_err:
>  	if (vols)
>  		free(vols);
