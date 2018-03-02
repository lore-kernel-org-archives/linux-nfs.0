Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:60886 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1946341AbeCBPqM (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 2 Mar 2018 10:46:12 -0500
Subject: Re: [PATCH] clnt_dg_call: Fix a buffer overflow (CVE-2016-4429)
To: Libtirpc-devel Mailing List <libtirpc-devel@lists.sourceforge.net>
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
References: <20180301170629.20780-1-steved@redhat.com>
From: Steve Dickson <SteveD@RedHat.com>
Message-ID: <a86a7db9-2f91-3d1a-15d6-df8d5d9a0fc4@RedHat.com>
Date: Fri, 2 Mar 2018 10:46:10 -0500
MIME-Version: 1.0
In-Reply-To: <20180301170629.20780-1-steved@redhat.com>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 03/01/2018 12:06 PM, Steve Dickson wrote:
> Fixes: https://bugzilla.redhat.com/show_bug.cgi?id=1337142
> Signed-off-by: Steve Dickson <steved@redhat.com>
Committed... 

steved.
> ---
>  src/clnt_dg.c | 7 +++++++
>  1 file changed, 7 insertions(+)
> 
> diff --git a/src/clnt_dg.c b/src/clnt_dg.c
> index 248138b..884a2db 100644
> --- a/src/clnt_dg.c
> +++ b/src/clnt_dg.c
> @@ -433,6 +433,11 @@ get_reply:
>  	  char *cbuf = (char *) alloca (outlen + 256);
>  	  int ret;
>  
> +	  if (cbuf == NULL) 
> +	  {
> +	  	cu->cu_error.re_errno = errno;
> +		return (cu->cu_error.re_status = RPC_CANTRECV);
> +	  }
>  	  iov.iov_base = cbuf + 256;
>  	  iov.iov_len = outlen;
>  	  msg.msg_name = (void *) &err_addr;
> @@ -457,11 +462,13 @@ get_reply:
>  		 cmsg = CMSG_NXTHDR (&msg, cmsg))
>  	      if (cmsg->cmsg_level == SOL_IP && cmsg->cmsg_type == IP_RECVERR)
>  		{
> +		  free(cbuf);
>  		  e = (struct sock_extended_err *) CMSG_DATA(cmsg);
>  		  cu->cu_error.re_errno = e->ee_errno;
>  		  release_fd_lock(cu->cu_fd, mask);
>  		  return (cu->cu_error.re_status = RPC_CANTRECV);
>  		}
> +	  free(cbuf);
>  	}
>  #endif
>  
> 
