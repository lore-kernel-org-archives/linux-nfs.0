Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from userp2130.oracle.com ([156.151.31.86]:38548 "EHLO
        userp2130.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750782AbeCFST2 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 6 Mar 2018 13:19:28 -0500
Content-Type: text/plain;
        charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 11.2 \(3445.5.20\))
Subject: Re: [PATCH] clnt_dg_call: Change the memory allocation
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <20180306180323.12131-1-steved@redhat.com>
Date: Tue, 6 Mar 2018 13:19:13 -0500
Cc: libtirpc List <libtirpc-devel@lists.sourceforge.net>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <78C60E78-91DF-427B-9BB9-27883F17D28E@oracle.com>
References: <20180306180323.12131-1-steved@redhat.com>
To: Steve Dickson <steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



> On Mar 6, 2018, at 1:03 PM, Steve Dickson <steved@redhat.com> wrote:
> 
> Change the memory allocation from the stack
> to the heap by calling calloc() verses alloca

> Fixes: https://bugzilla.redhat.com/show_bug.cgi?id=1552163

IMO, this should be:

Fixes: 2936f109590e ("clnt_dg_call: Fix a buffer overflow (CVE-2016-4429)")
BugLink: https://bugzilla.redhat.com/show_bug.cgi?id=1552163

Can the patch description explain the problem and why
this is the correct fix? It looks like 2936f109590e
added some free(3) call sites that were perhaps
unneeded. Why not just remove them, for instance?

Reviewed-by: Chuck Lever <chuck.lever@oracle.com>


> Signed-off-by: Steve Dickson <steved@redhat.com>
> ---
> src/clnt_dg.c | 6 +++---
> 1 file changed, 3 insertions(+), 3 deletions(-)
> 
> diff --git a/src/clnt_dg.c b/src/clnt_dg.c
> index 884a2db..1d55b1e 100644
> --- a/src/clnt_dg.c
> +++ b/src/clnt_dg.c
> @@ -430,7 +430,7 @@ get_reply:
> 	  struct sockaddr_in err_addr;
> 	  struct sockaddr_in *sin = (struct sockaddr_in *)&cu->cu_raddr;
> 	  struct iovec iov;
> -	  char *cbuf = (char *) alloca (outlen + 256);
> +	  char *cbuf = (char *) mem_alloc(outlen + 256);
> 	  int ret;
> 
> 	  if (cbuf == NULL) 
> @@ -462,13 +462,13 @@ get_reply:
> 		 cmsg = CMSG_NXTHDR (&msg, cmsg))
> 	      if (cmsg->cmsg_level == SOL_IP && cmsg->cmsg_type == IP_RECVERR)
> 		{
> -		  free(cbuf);
> +		  mem_free(cbuf, (outlen + 256));
> 		  e = (struct sock_extended_err *) CMSG_DATA(cmsg);
> 		  cu->cu_error.re_errno = e->ee_errno;
> 		  release_fd_lock(cu->cu_fd, mask);
> 		  return (cu->cu_error.re_status = RPC_CANTRECV);
> 		}
> -	  free(cbuf);
> +	  mem_free(cbuf, (outlen + 256));
> 	}
> #endif
> 
> -- 
> 2.14.3

--
Chuck Lever



