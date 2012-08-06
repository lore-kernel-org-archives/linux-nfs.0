Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:48196 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756474Ab2HFOXk (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 6 Aug 2012 10:23:40 -0400
Message-ID: <501FD363.9070102@RedHat.com>
Date: Mon, 06 Aug 2012 10:23:31 -0400
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: Chuck Lever <chuck.lever@oracle.com>
CC: bfields@redhat.com, linux-nfs@vger.kernel.org
Subject: Re: [PATCH] rpc.gssd: don't call poll(2) twice a second
References: <20120801164738.27815.94008.stgit@seurat.1015granger.net>
In-Reply-To: <20120801164738.27815.94008.stgit@seurat.1015granger.net>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 08/01/2012 12:49 PM, Chuck Lever wrote:
> Use ppoll() instead.
> 
> [ cel Wed Aug  1 11:44:46 EDT 2012 - autoconfiscated Bruce's version ]
> 
> Related clean-up: Since we're pulling the poll/ppoll call out into a
> separate function, note that the second argument of poll(2) and
> ppoll(2) is not an int, it's an unsigned long.  The nfds_t typedef
> is a recent invention, so use the raw type for compatibility with
> older glibc headers.
> 
> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
Committed...

steved.

> ---
> 
> Bruce-
> 
> How does this strike you?  I've build-tested both arms of the
> HAVE_PPOLL #ifdef, but otherwise have done no further testing.
> 
> 
>  configure.ac                |    2 +-
>  utils/gssd/gssd_main_loop.c |   56 +++++++++++++++++++++++++++++++------------
>  utils/gssd/gssd_proc.c      |    2 +-
>  3 files changed, 42 insertions(+), 18 deletions(-)
> 
> diff --git a/configure.ac b/configure.ac
> index b408f1b..18ee11a 100644
> --- a/configure.ac
> +++ b/configure.ac
> @@ -392,7 +392,7 @@ AC_CHECK_FUNCS([alarm atexit dup2 fdatasync ftruncate getcwd \
>                 gethostbyaddr gethostbyname gethostname getmntent \
>                 getnameinfo getrpcbyname getifaddrs \
>                 gettimeofday hasmntopt inet_ntoa innetgr memset mkdir pathconf \
> -               realpath rmdir select socket strcasecmp strchr strdup \
> +               ppoll realpath rmdir select socket strcasecmp strchr strdup \
>                 strerror strrchr strtol strtoul sigprocmask])
>  
>  
> diff --git a/utils/gssd/gssd_main_loop.c b/utils/gssd/gssd_main_loop.c
> index cec09ea..22e082f 100644
> --- a/utils/gssd/gssd_main_loop.c
> +++ b/utils/gssd/gssd_main_loop.c
> @@ -55,7 +55,7 @@
>  #include "err_util.h"
>  
>  extern struct pollfd *pollarray;
> -extern int pollsize;
> +extern unsigned long pollsize;
>  
>  #define POLL_MILLISECS	500
>  
> @@ -99,7 +99,7 @@ scan_poll_results(int ret)
>  				break;
>  		}
>  	}
> -};
> +}
>  
>  static int
>  topdirs_add_entry(struct dirent *dent)
> @@ -175,10 +175,46 @@ out_err:
>  	return -1;
>  }
>  
> +#ifdef HAVE_PPOLL
> +static void gssd_poll(struct pollfd *fds, unsigned long nfds)
> +{
> +	sigset_t emptyset;
> +	int ret;
> +
> +	sigemptyset(&emptyset);
> +	ret = ppoll(fds, nfds, NULL, &emptyset);
> +	if (ret < 0) {
> +		if (errno != EINTR)
> +			printerr(0, "WARNING: error return from poll\n");
> +	} else if (ret == 0) {
> +		printerr(0, "WARNING: unexpected timeout\n");
> +	} else {
> +		scan_poll_results(ret);
> +	}
> +}
> +#else	/* !HAVE_PPOLL */
> +static void gssd_poll(struct pollfd *fds, unsigned long nfds)
> +{
> +	int ret;
> +
> +	/* race condition here: dir_changed could be set before we
> +	 * enter the poll, and we'd never notice if it weren't for the
> +	 * timeout. */
> +	ret = poll(fds, nfds, POLL_MILLISECS);
> +	if (ret < 0) {
> +		if (errno != EINTR)
> +			printerr(0, "WARNING: error return from poll\n");
> +	} else if (ret == 0) {
> +		/* timeout */
> +	} else { /* ret > 0 */
> +		scan_poll_results(ret);
> +	}
> +}
> +#endif	/* !HAVE_PPOLL */
> +
>  void
>  gssd_run()
>  {
> -	int			ret;
>  	struct sigaction	dn_act;
>  	sigset_t		set;
>  
> @@ -207,19 +243,7 @@ gssd_run()
>  				exit(1);
>  			}
>  		}
> -		/* race condition here: dir_changed could be set before we
> -		 * enter the poll, and we'd never notice if it weren't for the
> -		 * timeout. */
> -		ret = poll(pollarray, pollsize, POLL_MILLISECS);
> -		if (ret < 0) {
> -			if (errno != EINTR)
> -				printerr(0,
> -					 "WARNING: error return from poll\n");
> -		} else if (ret == 0) {
> -			/* timeout */
> -		} else { /* ret > 0 */
> -			scan_poll_results(ret);
> -		}
> +		gssd_poll(pollarray, pollsize);
>  	}
>  	topdirs_free_list();
>  
> diff --git a/utils/gssd/gssd_proc.c b/utils/gssd/gssd_proc.c
> index aa39435..bda0249 100644
> --- a/utils/gssd/gssd_proc.c
> +++ b/utils/gssd/gssd_proc.c
> @@ -104,7 +104,7 @@
>  
>  struct pollfd * pollarray;
>  
> -int pollsize;  /* the size of pollaray (in pollfd's) */
> +unsigned long pollsize;  /* the size of pollaray (in pollfd's) */
>  
>  /*
>   * convert a presentation address string to a sockaddr_storage struct. Returns
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
