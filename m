From: Steve Dickson <SteveD@redhat.com>
Subject: Re: rpcbind doesn't build on Fedora 12 ?
Date: Tue, 05 Jan 2010 14:22:30 -0500
Message-ID: <4B439176.5080702@RedHat.com>
References: <268D6516-A19A-4CC7-BF03-6FBFA7C79D0B@oracle.com> <4B43887D.2000006@RedHat.com> <158159AE-BD50-4D41-9B14-450241B42E23@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:19786 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754363Ab0AETWf (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 5 Jan 2010 14:22:35 -0500
In-Reply-To: <158159AE-BD50-4D41-9B14-450241B42E23@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 01/05/2010 01:58 PM, Chuck Lever wrote:
> On Jan 5, 2010, at 1:44 PM, Steve Dickson wrote:
>> On 01/05/2010 12:12 PM, Chuck Lever wrote:
>>> security.c:24:27: error: rpcsvc/rquota.h: No such file or directory
>>> security.c: In function =91check_callit=92:
>>> security.c:286: error: =91RQUOTAPROG=92 undeclared (first use in th=
is
>>> function)
>>> security.c:286: error: (Each undeclared identifier is reported only=
 once
>>> security.c:286: error: for each function it appears in.)
>>>
>>> I have libtirpc-devel installed, but a "find" on /usr/include turns=
 up
>>> no file named rquota.h.  Am I missing some other package?
>>>
>> Yeah... 'yum install quota-devel' is your friend...
>=20
> That fixes it, but... I never had to install this package before.=20
> Either it's new with Fedora 12, or the Fedora 12 install with "softwa=
re
> development" checked doesn't install this one any more.
Packages do come and go with different Fedora releases...=20
>=20
> Is there a good reason why an RPC header would be separated into a
> non-obvious package like this?
>=20
Not that I know of...

steved.
