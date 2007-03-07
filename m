From: =?UTF-8?Q?Peter_=C3=85strand?= <astrand@cendio.se>
Subject: Re: [PATCH] NFS: Sign Extentions with Tru64 FSIDs.
Date: Wed, 7 Mar 2007 08:45:48 +0100 (CET)
Message-ID: <Pine.LNX.4.64.0703070842410.11660@maggie.lkpg.cendio.se>
References: <45EC7F0F.4090600@RedHat.com>
	<1173130678.6315.7.camel@heimdal.trondhjem.org>
	<45EC8FD3.4010809@redhat.com>
	<1173132182.6315.27.camel@heimdal.trondhjem.org>
	<45EC9837.1010504@redhat.com>
	<1173186308.6393.7.camel@heimdal.trondhjem.org>
	<45ED8135.2010008@RedHat.com> <45EDE060.3020501@RedHat.com>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY=------------050704030705070401070800
Cc: nfs@lists.sourceforge.net
To: Steve Dickson <SteveD@redhat.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HOqqV-0002Fv-V0
	for nfs@lists.sourceforge.net; Tue, 06 Mar 2007 23:46:00 -0800
Received: from mail.cendio.se ([193.12.253.69])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HOqqT-0008Tu-Ub
	for nfs@lists.sourceforge.net; Tue, 06 Mar 2007 23:45:59 -0800
In-Reply-To: <45EDE060.3020501@RedHat.com>
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

--------------050704030705070401070800
Content-Type: TEXT/PLAIN; CHARSET=UTF-8; FORMAT=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Content-ID: <Pine.LNX.4.64.0703070842412.11660@maggie.lkpg.cendio.se>

On Tue, 6 Mar 2007, Steve Dickson wrote:

>+               { NFS_MOUNT_NORDIRPLUS, ",nordirplus", "" },

I prefer the option name "noreaddirplus". It's only 3 chars longer, but=20
that's a small price to pay for avoiding confusion etc.=20

Regards,=20
---
Peter =C3=83=C2=85strand=09=09ThinLinc Chief Developer
Cendio AB=09=09http://www.cendio.se
Teknikringen 3
583 30 Link=C3=83=C2=B6ping=09Phone: +46-13-21 46 00
--------------050704030705070401070800
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
--------------050704030705070401070800
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--------------050704030705070401070800--
