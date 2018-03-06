Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from userp2120.oracle.com ([156.151.31.85]:59296 "EHLO
        userp2120.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754056AbeCFTWC (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 6 Mar 2018 14:22:02 -0500
Content-Type: text/plain;
        charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 11.2 \(3445.5.20\))
Subject: Re: [PATCH] clnt_dg_call: Change the memory allocation
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <c3879bfd-c916-6afe-5867-bd0b53de8e9a@RedHat.com>
Date: Tue, 6 Mar 2018 14:21:48 -0500
Cc: libtirpc List <libtirpc-devel@lists.sourceforge.net>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <CCA63938-32E1-4367-8078-B98EC5820341@oracle.com>
References: <20180306180323.12131-1-steved@redhat.com>
 <78C60E78-91DF-427B-9BB9-27883F17D28E@oracle.com>
 <c3879bfd-c916-6afe-5867-bd0b53de8e9a@RedHat.com>
To: Steve Dickson <SteveD@RedHat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



> On Mar 6, 2018, at 2:10 PM, Steve Dickson <SteveD@RedHat.com> wrote:
>=20
>=20
>=20
> On 03/06/2018 01:19 PM, Chuck Lever wrote:
>>=20
>>=20
>>> On Mar 6, 2018, at 1:03 PM, Steve Dickson <steved@redhat.com> wrote:
>>>=20
>>> Change the memory allocation from the stack
>>> to the heap by calling calloc() verses alloca
>>=20
>>> Fixes: https://bugzilla.redhat.com/show_bug.cgi?id=3D1552163
>>=20
>> IMO, this should be:
>>=20
>> Fixes: 2936f109590e ("clnt_dg_call: Fix a buffer overflow =
(CVE-2016-4429)")
>> BugLink: https://bugzilla.redhat.com/show_bug.cgi?id=3D1552163
> point.
>=20
>>=20
>> Can the patch description explain the problem and why
>> this is the correct fix? It looks like 2936f109590e
>> added some free(3) call sites that were perhaps
>> unneeded.=20
> Yeah alloca() allocates from the stack and the memory
> is automatically freed when routine returns
> (something that was pointed out to me by IRC people
> when their UDP mounts broke ;-) So this CVE is basically bogus!

> But it was also point out (by the IRC people) that=20
> allocating from the heap is probably better than=20
> scribbling on stack and I agree.

Yeah, I prefer to avoid alloca too.

As a generic comment, any new code needs to be careful
about bounds checking when writing into cbuf, even if
cbuf is on the heap instead of the stack. I didn't look
carefully at that, but sounds like I will get a second
shot to review ;-)


> I'll try to be more more descriptive in the description.

Cool, thanks.


> Why not just remove them, for instance?
> I assumed outlen can be variable size, but did not=20
> look very hard. I'm just trying to clean up some=20
> old bz so the less change I do the better... IMHO...=20

>> Reviewed-by: Chuck Lever <chuck.lever@oracle.com>
> Thanks!
>=20
> steved.
>=20
>>=20
>>=20
>>> Signed-off-by: Steve Dickson <steved@redhat.com>
>>> ---
>>> src/clnt_dg.c | 6 +++---
>>> 1 file changed, 3 insertions(+), 3 deletions(-)
>>>=20
>>> diff --git a/src/clnt_dg.c b/src/clnt_dg.c
>>> index 884a2db..1d55b1e 100644
>>> --- a/src/clnt_dg.c
>>> +++ b/src/clnt_dg.c
>>> @@ -430,7 +430,7 @@ get_reply:
>>> 	  struct sockaddr_in err_addr;
>>> 	  struct sockaddr_in *sin =3D (struct sockaddr_in =
*)&cu->cu_raddr;
>>> 	  struct iovec iov;
>>> -	  char *cbuf =3D (char *) alloca (outlen + 256);
>>> +	  char *cbuf =3D (char *) mem_alloc(outlen + 256);
>>> 	  int ret;
>>>=20
>>> 	  if (cbuf =3D=3D NULL)=20
>>> @@ -462,13 +462,13 @@ get_reply:
>>> 		 cmsg =3D CMSG_NXTHDR (&msg, cmsg))
>>> 	      if (cmsg->cmsg_level =3D=3D SOL_IP && cmsg->cmsg_type =3D=3D=
 IP_RECVERR)
>>> 		{
>>> -		  free(cbuf);
>>> +		  mem_free(cbuf, (outlen + 256));
>>> 		  e =3D (struct sock_extended_err *) CMSG_DATA(cmsg);
>>> 		  cu->cu_error.re_errno =3D e->ee_errno;
>>> 		  release_fd_lock(cu->cu_fd, mask);
>>> 		  return (cu->cu_error.re_status =3D RPC_CANTRECV);
>>> 		}
>>> -	  free(cbuf);
>>> +	  mem_free(cbuf, (outlen + 256));
>>> 	}
>>> #endif
>>>=20
>>> --=20
>>> 2.14.3
>>=20
>> --
>> Chuck Lever
>>=20
>>=20
>>=20

--
Chuck Lever



