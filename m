From: =?UTF-8?Q?Peter_=C3=85strand?= <astrand@cendio.se>
Subject: Re: Locale support in NFS client side
Date: Wed, 6 Jun 2007 12:20:45 +0200 (CEST)
Message-ID: <Pine.LNX.4.64.0706061215080.18979@maggie.lkpg.cendio.se>
References: <92cbf19b0706060015i77a636fas8c9c377c66f4878d@mail.gmail.com>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED;
	BOUNDARY="789237761-1224151784-1181125142=:18979"
Cc: nfs@lists.sourceforge.net
To: Chakri n <chakriin5@gmail.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HvsdI-0006dq-F4
	for nfs@lists.sourceforge.net; Wed, 06 Jun 2007 03:20:52 -0700
Received: from mail.cendio.se ([193.12.253.69])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HvsdK-0003IK-9W
	for nfs@lists.sourceforge.net; Wed, 06 Jun 2007 03:20:55 -0700
In-Reply-To: <92cbf19b0706060015i77a636fas8c9c377c66f4878d@mail.gmail.com>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--789237761-1224151784-1181125142=:18979
Content-Type: TEXT/PLAIN; CHARSET=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Content-ID: <Pine.LNX.4.64.0706061219241.18979@maggie.lkpg.cendio.se>

On Wed, 6 Jun 2007, Chakri n wrote:

> I am planning to write a layer on top of existing V2/V3 client and
> convert server side file or directory names to UTF8 format inside
> kernel, so that user level components using UTF8 always see file names
> as expected by them.

This would certainly be nice to have. My opinion is that you should try to=
=20
use UTF-8 over-the-wire, whenever you can, but I guess a client side=20
solution could also be useful in some cases.=20


> Is this option explored earlier? If it is, can anyone provides me some
> hooks where is the better place to start with?

I've been thinking of adding locale support to the unfs3 server. It=20
already converts to UTF-8 when running on Windows.=20

Another idea is to write a user level proxy, which converts the file=20
names.=20

Regards,=20
---
Peter =C3=85strand=09=09ThinLinc Chief Developer
Cendio AB=09=09http://www.cendio.se
Wallenbergs gata 4
583 30 Link=C3=B6ping=09Phone: +46-13-21 46 00
--789237761-1224151784-1181125142=:18979
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
--789237761-1224151784-1181125142=:18979
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--789237761-1224151784-1181125142=:18979--
