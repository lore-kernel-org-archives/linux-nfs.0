From: =?UTF-8?Q?Peter_=C3=85strand?= <astrand@cendio.se>
Subject: Re: [PATCH] NFS: Sign Extentions with Tru64 FSIDs.
Date: Tue, 6 Mar 2007 11:11:51 +0100 (CET)
Message-ID: <Pine.LNX.4.64.0703061104240.4177@maggie.lkpg.cendio.se>
References: <45EC7F0F.4090600@RedHat.com>
	<1173130678.6315.7.camel@heimdal.trondhjem.org>
	<45EC8FD3.4010809@redhat.com>
	<1173132182.6315.27.camel@heimdal.trondhjem.org>
	<45EC9837.1010504@redhat.com>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="789237761-776233001-1173175465=:4177"
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HOWeK-0001i1-PW
	for nfs@lists.sourceforge.net; Tue, 06 Mar 2007 02:12:05 -0800
Received: from mail.cendio.se ([193.12.253.69])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HOWeK-0005qA-5K
	for nfs@lists.sourceforge.net; Tue, 06 Mar 2007 02:12:06 -0800
Received: from maggie.lkpg.cendio.se (maggie.lkpg.cendio.se [10.47.1.208])
	by mail.cendio.se (Postfix) with ESMTP id 1625225DA34
	for <nfs@lists.sourceforge.net>; Tue,  6 Mar 2007 11:11:51 +0100 (CET)
In-Reply-To: <45EC9837.1010504@redhat.com>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--789237761-776233001-1173175465=:4177
Content-Type: TEXT/PLAIN; CHARSET=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Content-ID: <Pine.LNX.4.64.0703061106211.4177@maggie.lkpg.cendio.se>

On Mon, 5 Mar 2007, Peter Staubach wrote:

> > Hacking the fsid on behalf of the server is certainly vetoed.
>=20
> Well, I find it a little hard to imagine that anyone would choose
> a combination of fsids which would cause this to do the wrong thing,
> but okay.  It is definitely a heuristic and thus, subject to possible
> failure, no matter how remote.

The different userspace servers, such as unfs3, often uses non-obvious=20
fsid:s and fileid:s. Modern versions of unfs3 uses "real" fsid:s on UNIX,=
=20
but hashed fsid:s on Windows.=20


> Perhaps the right thing to do is to revert the NFSv2/NFSv3 support
> completely and not have them worry about changing fsids?  The common
> practice is to use an automounting facility or static mounts to
> construct namespaces for NFSv2/NFSv3 networks.  It is really only
> with the advent of NFSv4 that the fsids actually become interesting
> and something that the client needs to be aware of.

I disagree. This new support for mount point crossing is wonderful. It's=20
very useful with unfs3, since it allows for re-exporting file systems in a=
=20
very nice way. It's not just for NFSv4.=20


> Or we could just punt and document that READDIRPLUS must be disabled
> on all Tru64 NFS servers if this problem is seen.

Sounds like a much better solution. I agree with Trond; we shouldn't fix=20
server bugs in the client, and certainly not if this means less=20
functionality.

Regards,=20
---
Peter =C3=85strand=09=09ThinLinc Chief Developer
Cendio AB=09=09http://www.cendio.se
Teknikringen 3
583 30 Link=C3=B6ping=09Phone: +46-13-21 46 00
--789237761-776233001-1173175465=:4177
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
--789237761-776233001-1173175465=:4177
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--789237761-776233001-1173175465=:4177--
