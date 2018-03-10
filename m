Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:40002 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932130AbeCJPKL (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Sat, 10 Mar 2018 10:10:11 -0500
Subject: Re: [PATCH V2] clnt_dg_call: Change the memory allocation
To: Libtirpc-devel Mailing List <libtirpc-devel@lists.sourceforge.net>
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
References: <20180307140903.13278-1-steved@redhat.com>
From: Steve Dickson <SteveD@RedHat.com>
Message-ID: <c4f100aa-8d75-f37a-6422-b5ffb20d8a49@RedHat.com>
Date: Sat, 10 Mar 2018 10:10:10 -0500
MIME-Version: 1.0
In-Reply-To: <20180307140903.13278-1-steved@redhat.com>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 03/07/2018 09:09 AM, Steve Dickson wrote:
> Commit 2936f109590e add free()s on memory that
> was allocated from the stack (via alloca()).
> That type memory is automatically freed so
> those added free()s was causing a double frees.
> 
> It was suggested allocating memory from the
> stack can be a bit troublesome. So this patch
> changes the memory allocation from the stack
> to the heap which also eliminates the double frees.
> 
> Fixes: 2936f109590e ("clnt_dg_call: Fix a buffer overflow (CVE-2016-4429)")
> BugLink: https://bugzilla.redhat.com/show_bug.cgi?id=1552163
> 
> Signed-off-by: Steve Dickson <steved@redhat.com>
Committed... 

steved.
> ---
>  src/clnt_dg.c | 6 +++---
>  1 file changed, 3 insertions(+), 3 deletions(-)
> 
> diff --git a/src/clnt_dg.c b/src/clnt_dg.c
> index 884a2db..04a2aba 100644
> --- a/src/clnt_dg.c
> +++ b/src/clnt_dg.c
> @@ -430,7 +430,7 @@ get_reply:
>  	  struct sockaddr_in err_addr;
>  	  struct sockaddr_in *sin = (struct sockaddr_in *)&cu->cu_raddr;
>  	  struct iovec iov;
> -	  char *cbuf = (char *) alloca (outlen + 256);
> +	  char *cbuf = (char *) mem_alloc((outlen + 256));
>  	  int ret;
>  
>  	  if (cbuf == NULL) 
> @@ -462,13 +462,13 @@ get_reply:
>  		 cmsg = CMSG_NXTHDR (&msg, cmsg))
>  	      if (cmsg->cmsg_level == SOL_IP && cmsg->cmsg_type == IP_RECVERR)
>  		{
> -		  free(cbuf);
> +		  mem_free(cbuf, (outlen + 256));
>  		  e = (struct sock_extended_err *) CMSG_DATA(cmsg);
>  		  cu->cu_error.re_errno = e->ee_errno;
>  		  release_fd_lock(cu->cu_fd, mask);
>  		  return (cu->cu_error.re_status = RPC_CANTRECV);
>  		}
> -	  free(cbuf);
> +	  mem_free(cbuf, (outlen + 256));
>  	}
>  #endif
>  
> 
