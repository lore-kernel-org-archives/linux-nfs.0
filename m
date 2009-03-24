From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH] nfs-utils: Removed a number of warn_unused_result warnings
Date: Tue, 24 Mar 2009 12:19:38 -0400
Message-ID: <654687AD-E743-45A4-99B1-BBBEAA5D915D@oracle.com>
References: <49C797C6.8030102@RedHat.com>
Mime-Version: 1.0 (Apple Message framework v930.3)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
To: Steve Dickson <SteveD@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet11.oracle.com ([148.87.113.123]:46733 "EHLO
	rgminet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756207AbZCXQUt (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 24 Mar 2009 12:20:49 -0400
In-Reply-To: <49C797C6.8030102-AfCzQyP5zfLQT0dZR+AlfA@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Steve-

I've actually already addressed all the cases you found under utils/ 
statd/... my re-writes replace both nsm_log() and note() with calls to  
xlog(), and add return code checking to the write(2) calls.

Also, note that you can use the "%m" format specifier to generate the  
same string you get from strerror(errno).

On Mar 23, 2009, at 10:08 AM, Steve Dickson wrote:

> Here is a patch that removes a number of annoying 'warn_unused_result'
> warnings that have recently popped up in Fedora builds.
>
> Its probably a good thing to log these failures, but there is
> really not much we can do about them so I've logged the failures
> as warnings...
>
> This exercise also illuminates all the different ways there
> are to call syslog()... We really need to looking into creating
> exactly one way for all apps in nfs-utils to log messages to
> syslog().. Yeah.. Yeah... I know... Patches are welcome! ;-)
>
> steved.
>
>
> In recent Fedora builds, the '-D _FORTIFY_SOURCE=2' compile
> flag has been set. This cause warnings to be generated when
> return values from reads/writes (and other calls) are not
> checked. The patch address those warnings.
>
> Signed-off-by: Steve Dickson <steved@redhat.com>
> ------------------------------------------
>
> diff -up nfs-utils-1.1.5/support/nfs/cacheio.c.orig nfs-utils-1.1.5/ 
> support/nfs/cacheio.c
> --- nfs-utils-1.1.5/support/nfs/cacheio.c.orig	2009-03-05  
> 06:42:56.000000000 -0500
> +++ nfs-utils-1.1.5/support/nfs/cacheio.c	2009-03-23  
> 09:41:54.000000000 -0400
> @@ -24,6 +24,7 @@
> #include <sys/stat.h>
> #include <fcntl.h>
> #include <time.h>
> +#include <errno.h>
>
> void qword_add(char **bpp, int *lp, char *str)
> {
> @@ -125,7 +126,10 @@ void qword_print(FILE *f, char *str)
> 	char *bp = qword_buf;
> 	int len = sizeof(qword_buf);
> 	qword_add(&bp, &len, str);
> -	fwrite(qword_buf, bp-qword_buf, 1, f);
> +	if (fwrite(qword_buf, bp-qword_buf, 1, f) != 1) {
> +		xlog_warn("qword_print: fwrite failed: errno %d (%s)",
> +			errno, strerror(errno));
> +	}
> }
>
> void qword_printhex(FILE *f, char *str, int slen)
> @@ -133,7 +137,10 @@ void qword_printhex(FILE *f, char *str,
> 	char *bp = qword_buf;
> 	int len = sizeof(qword_buf);
> 	qword_addhex(&bp, &len, str, slen);
> -	fwrite(qword_buf, bp-qword_buf, 1, f);
> +	if (fwrite(qword_buf, bp-qword_buf, 1, f) != 1) {
> +		xlog_warn("qword_printhex: fwrite failed: errno %d (%s)",
> +			errno, strerror(errno));
> +	}
> }
>
> void qword_printint(FILE *f, int num)
> @@ -318,7 +325,10 @@ cache_flush(int force)
> 		sprintf(path, "/proc/net/rpc/%s/flush", cachelist[c]);
> 		fd = open(path, O_RDWR);
> 		if (fd >= 0) {
> -			write(fd, stime, strlen(stime));
> +			if (write(fd, stime, strlen(stime)) != strlen(stime)) {
> +				xlog_warn("Writing to '%s' failed: errno %d (%s)",
> +				path, errno, strerror(errno));
> +			}
> 			close(fd);
> 		}
> 	}
> diff -up nfs-utils-1.1.5/tools/locktest/testlk.c.orig nfs- 
> utils-1.1.5/tools/locktest/testlk.c
> --- nfs-utils-1.1.5/tools/locktest/testlk.c.orig	2009-03-05  
> 06:42:56.000000000 -0500
> +++ nfs-utils-1.1.5/tools/locktest/testlk.c	2009-03-23  
> 08:33:10.000000000 -0400
> @@ -81,7 +81,7 @@ main(int argc, char **argv)
> 		if (fl.l_type == F_UNLCK) {
> 			printf("%s: no conflicting lock\n", fname);
> 		} else {
> -			printf("%s: conflicting lock by %d on (%ld;%ld)\n",
> +			printf("%s: conflicting lock by %d on (%lld;%lld)\n",
> 				fname, fl.l_pid, fl.l_start, fl.l_len);
> 		}
> 		return 0;
> diff -up nfs-utils-1.1.5/utils/gssd/svcgssd.c.orig nfs-utils-1.1.5/ 
> utils/gssd/svcgssd.c
> --- nfs-utils-1.1.5/utils/gssd/svcgssd.c.orig	2009-03-05  
> 06:42:56.000000000 -0500
> +++ nfs-utils-1.1.5/utils/gssd/svcgssd.c	2009-03-23  
> 08:49:49.000000000 -0400
> @@ -132,7 +132,11 @@ release_parent(void)
> 	int status;
>
> 	if (pipefds[1] > 0) {
> -		write(pipefds[1], &status, 1);
> +		if (write(pipefds[1], &status, 1) != 1) {
> +			printerr(1,
> +				"WARN: writing to parent pipe failed: errno %d (%s)\n",
> +				errno, strerror(errno));
> +		}
> 		close(pipefds[1]);
> 		pipefds[1] = -1;
> 	}
> diff -up nfs-utils-1.1.5/utils/idmapd/idmapd.c.orig nfs-utils-1.1.5/ 
> utils/idmapd/idmapd.c
> --- nfs-utils-1.1.5/utils/idmapd/idmapd.c.orig	2009-03-05  
> 06:42:56.000000000 -0500
> +++ nfs-utils-1.1.5/utils/idmapd/idmapd.c	2009-03-23  
> 08:53:44.000000000 -0400
> @@ -169,7 +169,10 @@ flush_nfsd_cache(char *path, time_t now)
> 	fd = open(path, O_RDWR);
> 	if (fd == -1)
> 		return -1;
> -	write(fd, stime, strlen(stime));
> +	if (write(fd, stime, strlen(stime)) != strlen(stime)) {
> +		errx(1, "Flushing nfsd cache failed: errno %d (%s)",
> +			errno, strerror(errno));
> +	}
> 	close(fd);
> 	return 0;
> }
> @@ -988,7 +991,10 @@ release_parent(void)
> 	int status;
>
> 	if (pipefds[1] > 0) {
> -		write(pipefds[1], &status, 1);
> +		if (write(pipefds[1], &status, 1) != 1) {
> +			err(1, "Writing to parent pipe failed: errno %d (%s)\n",
> +				errno, strerror(errno));
> +		}
> 		close(pipefds[1]);
> 		pipefds[1] = -1;
> 	}
> diff -up nfs-utils-1.1.5/utils/mount/fstab.c.orig nfs-utils-1.1.5/ 
> utils/mount/fstab.c
> --- nfs-utils-1.1.5/utils/mount/fstab.c.orig	2009-03-05  
> 06:42:56.000000000 -0500
> +++ nfs-utils-1.1.5/utils/mount/fstab.c	2009-03-23  
> 08:44:42.000000000 -0400
> @@ -546,8 +546,12 @@ update_mtab (const char *dir, struct mnt
> 	   * from the present mtab before renaming.
> 	   */
> 	    struct stat sbuf;
> -	    if (stat (MOUNTED, &sbuf) == 0)
> -		chown (MOUNTED_TEMP, sbuf.st_uid, sbuf.st_gid);
> +	    if (stat (MOUNTED, &sbuf) == 0) {
> +			if (chown (MOUNTED_TEMP, sbuf.st_uid, sbuf.st_gid) < 0) {
> +				nfs_error(_("%s: error changing owner of %s: %s"),
> +					progname, MOUNTED_TEMP, strerror (errno));
> +			}
> +		}
> 	}
>
> 	/* rename mtemp to mtab */
> diff -up nfs-utils-1.1.5/utils/statd/monitor.c.orig nfs-utils-1.1.5/ 
> utils/statd/monitor.c
> --- nfs-utils-1.1.5/utils/statd/monitor.c.orig	2009-03-05  
> 06:42:56.000000000 -0500
> +++ nfs-utils-1.1.5/utils/statd/monitor.c	2009-03-23  
> 09:25:20.000000000 -0400
> @@ -204,7 +204,10 @@ sm_mon_1_svc(struct mon *argp, struct sv
> 			e += sprintf(e, "%02x", 0xff & (argp->priv[i]));
> 		if (e+1-buf != LINELEN) abort();
> 		e += sprintf(e, " %s %s\n", mon_name, my_name);
> -		write(fd, buf, e-buf);
> +		if (write(fd, buf, e-buf) != (e-buf)) {
> +			note(N_WARNING, "writing to %s failed: errno %d (%s)",
> +				path, errno, strerror(errno));
> +		}
> 	}
>
> 	free(path);
> diff -up nfs-utils-1.1.5/utils/statd/sm-notify.c.orig nfs- 
> utils-1.1.5/utils/statd/sm-notify.c
> --- nfs-utils-1.1.5/utils/statd/sm-notify.c.orig	2009-03-23  
> 08:26:22.000000000 -0400
> +++ nfs-utils-1.1.5/utils/statd/sm-notify.c	2009-03-23  
> 08:58:36.000000000 -0400
> @@ -784,7 +784,10 @@ static int record_pid(void)
> 	fd = open("/var/run/sm-notify.pid", O_CREAT|O_EXCL|O_WRONLY, 0600);
> 	if (fd < 0)
> 		return 0;
> -	write(fd, pid, strlen(pid));
> +	if (write(fd, pid, strlen(pid)) != strlen(pid))  {
> +		nsm_log(LOG_WARNING, "Writing to pid file failed: errno %d(%s)",
> +			errno, strerror(errno));
> +	}
> 	close(fd);
> 	return 1;
> }
> @@ -820,12 +823,16 @@ static void drop_privs(void)
> static void set_kernel_nsm_state(int state)
> {
> 	int fd;
> +	const char *file = "/proc/sys/fs/nfs/nsm_local_state";
>
> -	fd = open("/proc/sys/fs/nfs/nsm_local_state",O_WRONLY);
> +	fd = open(file ,O_WRONLY);
> 	if (fd >= 0) {
> 		char buf[20];
> 		snprintf(buf, sizeof(buf), "%d", state);
> -		write(fd, buf, strlen(buf));
> +		if (write(fd, buf, strlen(buf)) != strlen(buf)) {
> +			nsm_log(LOG_WARNING, "Writing to '%s' failed: errno %d (%s)",
> +				file, errno, strerror(errno));
> +		}
> 		close(fd);
> 	}
> }
> diff -up nfs-utils-1.1.5/utils/statd/statd.c.orig nfs-utils-1.1.5/ 
> utils/statd/statd.c
> --- nfs-utils-1.1.5/utils/statd/statd.c.orig	2009-03-05  
> 06:42:56.000000000 -0500
> +++ nfs-utils-1.1.5/utils/statd/statd.c	2009-03-23  
> 09:21:27.000000000 -0400
> @@ -179,14 +179,20 @@ static void create_pidfile(void)
> 		    pidfile, strerror(errno));
> 	fprintf(fp, "%d\n", getpid());
> 	pidfd = dup(fileno(fp));
> -	if (fclose(fp) < 0)
> -		note(N_WARNING, "Flushing pid file failed.\n");
> +	if (fclose(fp) < 0) {
> +		note(N_WARNING, "Flushing pid file failed: errno %d (%s)\n",
> +			errno, strerror(errno));
> +	}
> }
>
> static void truncate_pidfile(void)
> {
> -	if (pidfd >= 0)
> -		ftruncate(pidfd, 0);
> +	if (pidfd >= 0) {
> +		if (ftruncate(pidfd, 0) < 0) {
> +			note(N_WARNING, "truncating pid file failed: errno %d (%s)\n",
> +				errno, strerror(errno));
> +		}
> +	}
> }
>
> static void drop_privs(void)
> @@ -207,9 +213,12 @@ static void drop_privs(void)
> 	/* better chown the pid file before dropping, as if it
> 	 * if over nfs we might loose access
> 	 */
> -	if (pidfd >= 0)
> -		fchown(pidfd, st.st_uid, st.st_gid);
> -
> +	if (pidfd >= 0) {
> +		if (fchown(pidfd, st.st_uid, st.st_gid) < 0) {
> +			note(N_ERROR, "Unable to change owner of %s: %d (%s)",
> +					SM_DIR, strerror (errno));
> +		}
> +	}
> 	setgroups(0, NULL);
> 	if (setgid(st.st_gid) == -1
> 	    || setuid(st.st_uid) == -1) {
> @@ -495,7 +504,10 @@ int main (int argc, char **argv)
> 	/* If we got this far, we have successfully started, so notify  
> parent */
> 	if (pipefds[1] > 0) {
> 		status = 0;
> -		write(pipefds[1], &status, 1);
> +		if (write(pipefds[1], &status, 1) != 1) {
> +			note(N_WARNING, "writing to parent pipe failed: errno %d (%s)\n",
> +				errno, strerror(errno));
> +		}
> 		close(pipefds[1]);
> 		pipefds[1] = -1;
> 	}
> @@ -534,17 +546,23 @@ static void
> load_state_number(void)
> {
> 	int fd;
> +	const char *file = "/proc/sys/fs/nfs/nsm_local_state";
>
> 	if ((fd = open(SM_STAT_PATH, O_RDONLY)) == -1)
> 		return;
>
> -	read(fd, &MY_STATE, sizeof(MY_STATE));
> +	if (read(fd, &MY_STATE, sizeof(MY_STATE)) != sizeof(MY_STATE)) {
> +		note(N_WARNING, "Unable to read state from '%s': errno %d (%s)",
> +				SM_STAT_PATH, errno, strerror(errno));
> +	}
> 	close(fd);
> -	fd = open("/proc/sys/fs/nfs/nsm_local_state",O_WRONLY);
> +	fd = open(file, O_WRONLY);
> 	if (fd >= 0) {
> 		char buf[20];
> 		snprintf(buf, sizeof(buf), "%d", MY_STATE);
> -		write(fd, buf, strlen(buf));
> +		if (write(fd, buf, strlen(buf)) != strlen(buf))
> +			note(N_WARNING, "Writing to '%s' failed: errno %d (%s)",
> +				file, errno, strerror(errno));
> 		close(fd);
> 	}
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs"  
> in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




