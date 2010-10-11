From: Steve Dickson <SteveD@redhat.com>
Subject: Re: [PATCH 04/15] mount.nfs: Eliminate compiler warnings
Date: Mon, 11 Oct 2010 12:45:16 -0400
Message-ID: <4CB33F1C.6050108@RedHat.com>
References: <20101010234836.6667.4057.stgit@ellison.1015granger.net> <20101011000441.6667.68536.stgit@ellison.1015granger.net> <4CB311D6.2000503@RedHat.com> <3C05DAD4-965A-42EB-A0AE-1EFD7DCEF3A9@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Cc: linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:26525 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755346Ab0JKQpU (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 11 Oct 2010 12:45:20 -0400
In-Reply-To: <3C05DAD4-965A-42EB-A0AE-1EFD7DCEF3A9@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 10/11/2010 12:18 PM, Chuck Lever wrote:
>=20
> On Oct 11, 2010, at 9:32 AM, Steve Dickson wrote:
>=20
>>
>>
>> On 10/10/2010 08:04 PM, Chuck Lever wrote:
>>> Clean up.
>>>
>>> fstab.c: In function =91lock_mtab=92:
>>> fstab.c:385: warning: declaration of =91errsv=92 shadows a previous=
 local
>>> fstab.c:367: warning: shadowed declaration is here
>>> fstab.c:407: warning: declaration of =91errsv=92 shadows a previous=
 local
>>> fstab.c:367: warning: shadowed declaration is here
>>> fstab.c:417: warning: declaration of =91tries=92 shadows a previous=
 local
>>> fstab.c:325: warning: shadowed declaration is here
>>> fstab.c:422: warning: declaration of =91errsv=92 shadows a previous=
 local
>>> fstab.c:367: warning: shadowed declaration is here
>> Could you please post the gcc flags you using to generate=20
>> theses warnings... These warnings are not being generated with
>> the default gcc flags we are currently using...=20
>=20
> Since I've already privately sent you the compiler flags I use,=20
> would you like me to repost all of these compiler warning patches=20
> with the compiler command line options listed in the patch descriptio=
ns?
No... I'll just dig out those flags you sent me..

>=20
> You can probably see the warnings fixed in this particular patch with=
 "-Wshadow"
Thanks... I'll give that a try...

steved.
