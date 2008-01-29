From: Gianluca Alberici <gianluca-I6s3FmifXcAEdjjp4vwUeA@public.gmane.org>
Subject: Re: NFS EINVAL on open(... | O_TRUNC) on 2.6.23.9
Date: Tue, 29 Jan 2008 20:50:15 +0100
Message-ID: <479F8377.6090704@abinetworks.biz>
References: <476CEC5E.9070002@abinetworks.biz> <838DE9A2-59B2-49FA-B3E8-89B26368B1CF@bluecamel.eml.cc> <476E47F5.4090807@abinetworks.biz> <20071225140431.9264970a.akpm@linux-foundation.org> <199BEBA7-E46E-4B1F-9D36-91BB43331B75@oracle.com> <4791EE99.3030802@abinetworks.biz> <5FD6714F-EF9A-4F07-B2B6-D6F6CC911936@oracle.com> <479C744A.6020207@abinetworks.biz> <12964A18-350B-443F-B15A-D78B3723C89A@oracle.com> <479F2463.2040704@abinetworks.biz> <4AAA3DAF-898C-4ED5-BD07-4FD2B5CEEF16@oracle.com> <Pine.LNX.4.64.0801291851110.4820@maggie.lkpg.cendio.se> <7EE4B02B-3359-41C0-BFED-0947DF9F5F5A@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Cc: =?ISO-8859-1?Q?Peter_=C5strand?= <astrand-+4tYiAq3b6azQB+pC5nmwQ@public.gmane.org>,
	NFS list <linux-nfs@vger.kernel.org>
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from ns4.abinetworks.biz ([216.218.212.66]:39936 "EHLO
	ns4.abinetworks.biz" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754172AbYA2Tp0 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 29 Jan 2008 14:45:26 -0500
In-Reply-To: <7EE4B02B-3359-41C0-BFED-0947DF9F5F5A@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hello,

I confirm that i have encountered this same problem (EINVAL on open=20
(...O | TRUNC) with the following userspace servers:

- nfs-user-server shipped with debian sarge/etch etc...
- cfsd (crypto file system which is an nfs server)

I want to underline again that these userspace servers have been woking=
=20
perfectly until 2.6.21.7 (which is the last 2.6.21)
Since 2.6.22 the problem came out and it is still present into 2.6.24=20
rc7 (last i tested). Conclusion: there must have been something that is
changed in 2.6.22 that caused the problem.

I thought about nfs client because of the only difference between the=20
userspace server and the knfsd was the RPC call_decode() exit status=20
(see sysctl debug traces).

I have also tried unfs3 which, if i remember well, used to give me=20
EINVAL at mount time (!). But i should retest.
Also, i have tried to warn debian mantainers (both nfs-user-server and=20
cfsd) but without success.

Anyway any help is appreciated, and many thanks a lot for the help up t=
o=20
now.

Regards,

Gianluca
Chuck Lever wrote:

>
> On Jan 29, 2008, at 12:54 PM, Peter =C5strand wrote:
>
>> On Tue, 29 Jan 2008, Chuck Lever wrote:
>>
>>> I think you mentioned previously that the server is the Debian =20
>>> user-space
>>> server.  You should contact Debian and ask for their help to =20
>>> diagnose the
>>> problem.  (As far as I know there are no user-space server =20
>>> developers on this
>>> list, but I could be incorrect).
>>
>>
>> (I've thought I've been advertising unfs3 almost too much :-))
>>
>> If this problem shows up with unfs3, I can probably take a look at i=
t.
>
>
> From one of Gianluca's previous e-mails, the server is:
>
> "I propose to anybody interested to test cfsd or nfs-user-server =20
> 2.2beta47-23 (from debian etch) on any kernel >=3D 2.6.23."
>
> --=20
> Chuck Lever
> chuck[dot]lever[at]oracle[dot]com


