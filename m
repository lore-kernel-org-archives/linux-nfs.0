Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:19141 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751253Ab2GSNpI (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 19 Jul 2012 09:45:08 -0400
Message-ID: <50080F5F.5040600@RedHat.com>
Date: Thu, 19 Jul 2012 09:45:03 -0400
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: Chuck Lever <chuck.lever@oracle.com>
CC: linux-nfs@vger.kernel.org
Subject: Re: [PATCH] rpc.gssd: close upcall pipe on POLLHUP
References: <20120716183526.2399.37839.stgit@degas.1015granger.net>
In-Reply-To: <20120716183526.2399.37839.stgit@degas.1015granger.net>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 07/16/2012 02:36 PM, Chuck Lever wrote:
> When a POLLHUP event is received on a pipe file descriptor, that
> means the other side has closed its end of the pipe.  If the
> receiver does not close its end of the pipe, the pipe is left in an
> open-but-unlinked state.
> 
> For a "gssd" upcall pipe, the kernel may close its end, removing the
> directory entry for it, and then later create a fresh pipe named
> "gssd" in the same directory.  In this case, rpc.gssd continues to
> listen on the open-but-unlinked previous "gssd" pipe.  Thus upcalls
> on the new "gssd" pipe are left unanswered.
> 
> In addition, poll(2) continues to return POLLHUP on the old pipe.
> Since there is no logic to close the pipe in rpc.gssd, poll(2) always
> returns immediately, and rpc.gssd goes into a tight loop.
> 
> Typically, the kernel closes upcall pipes and destroys their
> parent directory at the same time.  When an RPC client's directory
> vanishes, rpc.gssd sees the change via dnotify and eventually
> invokes destroy_client() which closes the user-space end of the
> pipes.
> 
> However, if the kernel wants to switch authentication flavors (say
> from AUTH_KRB5 to AUTH_UNIX) on an RPC client without destroying it,
> the upcall pipes go away, but the RPC client's directory remains.
> rpc.gssd invokes update_client_list(), but that logic never closes
> upcall pipes if the client directory is still in place.
> 
> After a POLLHUP on a pipe, close it when rpc.gssd reconstructs its
> list of upcall clients.
> 
> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
Committed....

steved.
> ---
> 
> I know folks are probably on vacation this week, so this is only a
> request for comments.
> 
>  utils/gssd/gssd.h           |    2 ++
>  utils/gssd/gssd_main_loop.c |    8 ++++++--
>  utils/gssd/gssd_proc.c      |   19 +++++++++++++++++++
>  3 files changed, 27 insertions(+), 2 deletions(-)
> 
> diff --git a/utils/gssd/gssd.h b/utils/gssd/gssd.h
> index e0a2b7b..ec81beb 100644
> --- a/utils/gssd/gssd.h
> +++ b/utils/gssd/gssd.h
> @@ -82,8 +82,10 @@ struct clnt_info {
>  	char			*protocol;
>  	int			krb5_fd;
>  	int			krb5_poll_index;
> +	int			krb5_close_me;
>  	int                     gssd_fd;
>  	int                     gssd_poll_index;
> +	int			gssd_close_me;
>  	struct sockaddr_storage addr;
>  };
>  
> diff --git a/utils/gssd/gssd_main_loop.c b/utils/gssd/gssd_main_loop.c
> index 187954c..6480390 100644
> --- a/utils/gssd/gssd_main_loop.c
> +++ b/utils/gssd/gssd_main_loop.c
> @@ -78,8 +78,10 @@ scan_poll_results(int ret)
>  	{
>  		i = clp->gssd_poll_index;
>  		if (i >= 0 && pollarray[i].revents) {
> -			if (pollarray[i].revents & POLLHUP)
> +			if (pollarray[i].revents & POLLHUP) {
> +				clp->gssd_close_me = 1;
>  				dir_changed = 1;
> +			}
>  			if (pollarray[i].revents & POLLIN)
>  				handle_gssd_upcall(clp);
>  			pollarray[clp->gssd_poll_index].revents = 0;
> @@ -89,8 +91,10 @@ scan_poll_results(int ret)
>  		}
>  		i = clp->krb5_poll_index;
>  		if (i >= 0 && pollarray[i].revents) {
> -			if (pollarray[i].revents & POLLHUP)
> +			if (pollarray[i].revents & POLLHUP) {
> +				clp->krb5_close_me = 1;
>  				dir_changed = 1;
> +			}
>  			if (pollarray[i].revents & POLLIN)
>  				handle_krb5_upcall(clp);
>  			pollarray[clp->krb5_poll_index].revents = 0;
> diff --git a/utils/gssd/gssd_proc.c b/utils/gssd/gssd_proc.c
> index fed2886..5e33379 100644
> --- a/utils/gssd/gssd_proc.c
> +++ b/utils/gssd/gssd_proc.c
> @@ -339,6 +339,25 @@ process_clnt_dir_files(struct clnt_info * clp)
>  	char	gname[PATH_MAX];
>  	char	info_file_name[PATH_MAX];
>  
> +	if (clp->gssd_close_me) {
> +		printerr(2, "Closing 'gssd' pipe for %s\n", clp->dirname);
> +		close(clp->gssd_fd);
> +		memset(&pollarray[clp->gssd_poll_index], 0,
> +			sizeof(struct pollfd));
> +		clp->gssd_fd = -1;
> +		clp->gssd_poll_index = -1;
> +		clp->gssd_close_me = 0;
> +	}
> +	if (clp->krb5_close_me) {
> +		printerr(2, "Closing 'krb5' pipe for %s\n", clp->dirname);
> +		close(clp->krb5_fd);
> +		memset(&pollarray[clp->krb5_poll_index], 0,
> +			sizeof(struct pollfd));
> +		clp->krb5_fd = -1;
> +		clp->krb5_poll_index = -1;
> +		clp->krb5_close_me = 0;
> +	}
> +
>  	if (clp->gssd_fd == -1) {
>  		snprintf(gname, sizeof(gname), "%s/gssd", clp->dirname);
>  		clp->gssd_fd = open(gname, O_RDWR);
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
