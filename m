Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from aserp2130.oracle.com ([141.146.126.79]:36424 "EHLO
        aserp2130.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933665AbeCGPnl (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 7 Mar 2018 10:43:41 -0500
Content-Type: text/plain;
        charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 11.2 \(3445.5.20\))
Subject: Re: [PATCH V2] clnt_dg_call: Change the memory allocation
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <20180307140903.13278-1-steved@redhat.com>
Date: Wed, 7 Mar 2018 10:43:24 -0500
Cc: libtirpc List <libtirpc-devel@lists.sourceforge.net>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <F54DC53D-FFAE-4230-95AD-370B394AA51B@oracle.com>
References: <20180307140903.13278-1-steved@redhat.com>
To: Steve Dickson <SteveD@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Steve-

> On Mar 7, 2018, at 9:09 AM, Steve Dickson <SteveD@redhat.com> wrote:
> 
> Commit 2936f109590e add free()s on memory that
> was allocated from the stack (via alloca()).
> That type memory is automatically freed so
> those added free()s was causing a double frees.

I'm going to split hairs, but that doesn't mean I
object to the patch. You know that's the way I roll.

My copy of "man alloca(3)" says:

"Do not attempt to free(3) space allocated by alloca()!"

Since memory returned by alloca(3) is not in the heap,
it's an attempt to free memory that was not allocated
via malloc(3), which is technically not a double-free.


> It was suggested allocating memory from the
> stack can be a bit troublesome. So this patch
> changes the memory allocation from the stack
> to the heap which also eliminates the double frees.

My reading of CVE-2016-4429 is that the alloca(3) was the
real problem. There is a "goto call_again;" later down in
this function that can force this piece of code to be
called in a loop, resulting in more than one call to
alloca(3) in this function. Stack exhaustion occurs if the
loop goto is taken too many times.

Using a heap allocation and freeing that memory within the
loop is a good fix for this issue, and that's what we end
up with after this patch is applied. It would be helpful to
replace this second paragraph with a note that states this
patch is needed to finally close CVE-2016-4429.

Happily, this appears to be the only remaining alloca(3)
call site in libtirpc.

It would make this code a little easier to understand if
the numeric literals (256) were replaced by a macro or enum.
That's a nit, but then it becomes more clear that the size
of the buffer is made available to recvmsg(2) so that, IIUC,
the buffer is never overrun by the incoming message.


> Fixes: 2936f109590e ("clnt_dg_call: Fix a buffer overflow (CVE-2016-4429)")
> BugLink: https://bugzilla.redhat.com/show_bug.cgi?id=1552163
> 
> Signed-off-by: Steve Dickson <steved@redhat.com>

Reviewed-by: Chuck Lever <chuck.lever@oracle.com>


> ---
> src/clnt_dg.c | 6 +++---
> 1 file changed, 3 insertions(+), 3 deletions(-)
> 
> diff --git a/src/clnt_dg.c b/src/clnt_dg.c
> index 884a2db..04a2aba 100644
> --- a/src/clnt_dg.c
> +++ b/src/clnt_dg.c
> @@ -430,7 +430,7 @@ get_reply:
> 	  struct sockaddr_in err_addr;
> 	  struct sockaddr_in *sin = (struct sockaddr_in *)&cu->cu_raddr;
> 	  struct iovec iov;
> -	  char *cbuf = (char *) alloca (outlen + 256);
> +	  char *cbuf = (char *) mem_alloc((outlen + 256));
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



