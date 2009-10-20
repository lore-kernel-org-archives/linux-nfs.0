From: Peter Staubach <staubach@redhat.com>
Subject: Re: [RFC] When locking an inexistent file, NFSv3 and NFSv4 get different
 result.
Date: Tue, 20 Oct 2009 15:47:30 -0400
Message-ID: <4ADE13D2.50108@redhat.com>
References: <4ADD7D8F.1040700@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: trond.myklebust@fys.uio.no,
	NFSv3 community <linux-nfs@vger.kernel.org>, mingo@elte.hu,
	bfields@fieldses.org
To: Mi Jinlong <mijinlong@cn.fujitsu.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:37421 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751797AbZJTTrt (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 20 Oct 2009 15:47:49 -0400
In-Reply-To: <4ADD7D8F.1040700@cn.fujitsu.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Mi Jinlong wrote:
> When locking an inexistent file, NFSv3 and NFSv4 get different result=
=2E
>=20
> A: Test procedure=EF=BC=9A
>=20
>          Client              Server
>        ---------------+----------------
> step1:  open file     |
> step2:                |   delete file
> step3:  lock file     |
> step4:  close file    |
>                       V
>=20
>    On NFSv3: lock file fail, and return ESTALE at step3.
>    On NFSv4: lock file success, and return OK at step3.
>=20
> B: Reason:
>=20
>    NFSv4 server open file when client open the file at step1.
>          so it can lock file success at step3.
>    NFSv3 server don't open file when client open the file at step1,
>          but open file at step3, so lock fail caused by open file fai=
l.
>=20
> C: Suggestion:
>=20
>    I suggest modifying the NFSv3 to accordding with NFSv4. As followe=
d:
>=20
>    1. Add two NLMPROCs for nlm.
>=20
>       NLMPROC_OPEN:  client sent it to server, and server open file
>       NLMPROC_CLOSE: client sent it to server, and server close file
>=20

Modifying the NLM protocol is pretty much a non-starter.
While not well documented, it is implemented already by
most implementations.  Most of those implementations have
already placed their NFSv2 and NFSv3 implementations on
support only and the only development occuring is on the
NFSv4 implementation.

This is another case of pretty much just how NFS has worked
for 20+ years now.  Most people have learned how to deal
with it and thus, fixing it, is more work than it is worth.

Also, if the scenario below was the only one, it might be
slightly worth considering.  However, what happens if the
client never sends an NLMPROC_CLOSE?  The file can never
be really deleted.  NFSv4 has explicit support for a
situation like this, so would handle it.

		ps


>    2.=20
>      If use NLM, client send NLMPROC_OPEN request to server when clie=
nt open file,
>      and send NLMPROC_CLOSE request when client close file.
>=20
>             client                  server
>               |   nfs.lookup request   |
>          Open |----------------------->|
>               |    nfs.lookup reply    |
>               |<-----------------------|
>               |                        |
>               |  NLMPROC_OPEN request  |
>               |----------------------->| open file and add it to nlm_=
files list
>               |   NLMPROC_OPEN reply   | =20
>               |<-----------------------|
>               |                        |
>         Lock  |  NMLPROC_LOCK request  |
>               |----------------------->| use the file opened before=20
>               |   NMLPROC_LOCK reply   |
>               |<-----------------------|
>               |                        |
>         Close |  NMLPROC_CLOSE request |
>               |----------------------->| remove the file from nlm_fil=
es list
>               |   NMLPROC_CLOSE reply  |
>               |<-----------------------|
>               V                        V
>=20

