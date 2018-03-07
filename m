Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:54390 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S934327AbeCGT6l (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 7 Mar 2018 14:58:41 -0500
Subject: Re: [PATCH V2] clnt_dg_call: Change the memory allocation
To: Chuck Lever <chuck.lever@oracle.com>
Cc: libtirpc List <libtirpc-devel@lists.sourceforge.net>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
References: <20180307140903.13278-1-steved@redhat.com>
 <F54DC53D-FFAE-4230-95AD-370B394AA51B@oracle.com>
From: Steve Dickson <SteveD@RedHat.com>
Message-ID: <888ed43a-f198-ac77-8972-59e0ab781918@RedHat.com>
Date: Wed, 7 Mar 2018 14:58:40 -0500
MIME-Version: 1.0
In-Reply-To: <F54DC53D-FFAE-4230-95AD-370B394AA51B@oracle.com>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hey!

On 03/07/2018 10:43 AM, Chuck Lever wrote:
> Hi Steve-
> 
>> On Mar 7, 2018, at 9:09 AM, Steve Dickson <SteveD@redhat.com> wrote:
>>
>> Commit 2936f109590e add free()s on memory that
>> was allocated from the stack (via alloca()).
>> That type memory is automatically freed so
>> those added free()s was causing a double frees.
> 
> I'm going to split hairs, but that doesn't mean I
> object to the patch. You know that's the way I roll.
I know all to well... ;-) 

> 
> My copy of "man alloca(3)" says:
> 
> "Do not attempt to free(3) space allocated by alloca()!"
> 
> Since memory returned by alloca(3) is not in the heap,
> it's an attempt to free memory that was not allocated
> via malloc(3), which is technically not a double-free.
> 
This was definitely brain-fart on my part... I wish
I had read that before doing the commit... 

I was not familiar with the workings of alloca(3)
I just assume alloca(3) was like the rest of the 
[m|c]alloc family but no... it had to be a twisted sister! 8-)
  
> 
>> It was suggested allocating memory from the
>> stack can be a bit troublesome. So this patch
>> changes the memory allocation from the stack
>> to the heap which also eliminates the double frees.
> 
> My reading of CVE-2016-4429 is that the alloca(3) was the
> real problem. There is a "goto call_again;" later down in
> this function that can force this piece of code to be
> called in a loop, resulting in more than one call to
> alloca(3) in this function. Stack exhaustion occurs if the
> loop goto is taken too many times.
> 
> Using a heap allocation and freeing that memory within the
> loop is a good fix for this issue, and that's what we end
> up with after this patch is applied. It would be helpful to
> replace this second paragraph with a note that states this
> patch is needed to finally close CVE-2016-4429.
I see this as the fix for the fix of the CVE.

> 
> Happily, this appears to be the only remaining alloca(3)
> call site in libtirpc.
Bingo! 

> 
> It would make this code a little easier to understand if
> the numeric literals (256) were replaced by a macro or enum.
> That's a nit, but then it becomes more clear that the size
> of the buffer is made available to recvmsg(2) so that, IIUC,
> the buffer is never overrun by the incoming message.
Let remember this is UDP... which is no longer on by default
in the upstream server and an unnamed source as told me
that UDP will not be supported in upcoming distro release.

So I'm hoping to just fix the CVE and move on... 
 
> 
> 
>> Fixes: 2936f109590e ("clnt_dg_call: Fix a buffer overflow (CVE-2016-4429)")
>> BugLink: https://bugzilla.redhat.com/show_bug.cgi?id=1552163
>>
>> Signed-off-by: Steve Dickson <steved@redhat.com>
> 
> Reviewed-by: Chuck Lever <chuck.lever@oracle.com>
Added... and Thank you!!

steved.
> 
> 
>> ---
>> src/clnt_dg.c | 6 +++---
>> 1 file changed, 3 insertions(+), 3 deletions(-)
>>
>> diff --git a/src/clnt_dg.c b/src/clnt_dg.c
>> index 884a2db..04a2aba 100644
>> --- a/src/clnt_dg.c
>> +++ b/src/clnt_dg.c
>> @@ -430,7 +430,7 @@ get_reply:
>> 	  struct sockaddr_in err_addr;
>> 	  struct sockaddr_in *sin = (struct sockaddr_in *)&cu->cu_raddr;
>> 	  struct iovec iov;
>> -	  char *cbuf = (char *) alloca (outlen + 256);
>> +	  char *cbuf = (char *) mem_alloc((outlen + 256));
>> 	  int ret;
>>
>> 	  if (cbuf == NULL) 
>> @@ -462,13 +462,13 @@ get_reply:
>> 		 cmsg = CMSG_NXTHDR (&msg, cmsg))
>> 	      if (cmsg->cmsg_level == SOL_IP && cmsg->cmsg_type == IP_RECVERR)
>> 		{
>> -		  free(cbuf);
>> +		  mem_free(cbuf, (outlen + 256));
>> 		  e = (struct sock_extended_err *) CMSG_DATA(cmsg);
>> 		  cu->cu_error.re_errno = e->ee_errno;
>> 		  release_fd_lock(cu->cu_fd, mask);
>> 		  return (cu->cu_error.re_status = RPC_CANTRECV);
>> 		}
>> -	  free(cbuf);
>> +	  mem_free(cbuf, (outlen + 256));
>> 	}
>> #endif
>>
>> -- 
>> 2.14.3
> 
> --
> Chuck Lever
> 
> 
> 
