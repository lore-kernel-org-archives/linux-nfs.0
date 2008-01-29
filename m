From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: NFS EINVAL on open(... | O_TRUNC) on 2.6.23.9
Date: Tue, 29 Jan 2008 13:14:52 -0500
Message-ID: <7EE4B02B-3359-41C0-BFED-0947DF9F5F5A@oracle.com>
References: <476CEC5E.9070002@abinetworks.biz> <838DE9A2-59B2-49FA-B3E8-89B26368B1CF@bluecamel.eml.cc> <476E47F5.4090807@abinetworks.biz> <20071225140431.9264970a.akpm@linux-foundation.org> <199BEBA7-E46E-4B1F-9D36-91BB43331B75@oracle.com> <4791EE99.3030802@abinetworks.biz> <5FD6714F-EF9A-4F07-B2B6-D6F6CC911936@oracle.com> <479C744A.6020207@abinetworks.biz> <12964A18-350B-443F-B15A-D78B3723C89A@oracle.com> <479F2463.2040704@abinetworks.biz> <4AAA3DAF-898C-4ED5-BD07-4FD2B5CEEF16@oracle.com> <Pine.LNX.4.64.0801291851110.4820@maggie.lkpg.cendio.se>
Mime-Version: 1.0 (Apple Message framework v753)
Content-Type: text/plain; charset=ISO-8859-1;
	delsp=yes	format=flowed
Cc: NFS list <linux-nfs@vger.kernel.org>,
	Gianluca Alberici <gianluca-I6s3FmifXcAEdjjp4vwUeA@public.gmane.org>
To: =?ISO-8859-1?Q?Peter_=C5strand?= <astrand-+4tYiAq3b6azQB+pC5nmwQ@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from agminet01.oracle.com ([141.146.126.228]:20235 "EHLO
	agminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751257AbYA2SRO convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 29 Jan 2008 13:17:14 -0500
In-Reply-To: <Pine.LNX.4.64.0801291851110.4820-K9BqGu7AvB3wj5YHdwD3Ga2PxDmRETKR@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Jan 29, 2008, at 12:54 PM, Peter =C5strand wrote:

> On Tue, 29 Jan 2008, Chuck Lever wrote:
>
>> I think you mentioned previously that the server is the Debian =20
>> user-space
>> server.  You should contact Debian and ask for their help to =20
>> diagnose the
>> problem.  (As far as I know there are no user-space server =20
>> developers on this
>> list, but I could be incorrect).
>
> (I've thought I've been advertising unfs3 almost too much :-))
>
> If this problem shows up with unfs3, I can probably take a look at it=
=2E

 From one of Gianluca's previous e-mails, the server is:

"I propose to anybody interested to test cfsd or nfs-user-server =20
2.2beta47-23 (from debian etch) on any kernel >=3D 2.6.23."

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com