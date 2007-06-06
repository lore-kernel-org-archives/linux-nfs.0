From: =?UTF-8?Q?Peter_=C3=85strand?= <astrand@cendio.se>
Subject: Re: 2.6.21.3: NFS: Buggy server - nlink == 0!
Date: Wed, 6 Jun 2007 12:25:51 +0200 (CEST)
Message-ID: <Pine.LNX.4.64.0706061221340.18979@maggie.lkpg.cendio.se>
References: <20070606081303.GB7168@localdomain>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED;
	BOUNDARY="789237761-1484332135-1181125551=:18979"
Cc: nfs@lists.sourceforge.net
To: Ravikiran G Thirumalai <kiran@scalex86.org>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HvsiB-0007BB-RE
	for nfs@lists.sourceforge.net; Wed, 06 Jun 2007 03:25:56 -0700
Received: from mail.cendio.se ([193.12.253.69])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HvsiD-0004Pz-LR
	for nfs@lists.sourceforge.net; Wed, 06 Jun 2007 03:25:59 -0700
In-Reply-To: <20070606081303.GB7168@localdomain>
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

--789237761-1484332135-1181125551=:18979
Content-Type: TEXT/PLAIN; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE

On Wed, 6 Jun 2007, Ravikiran G Thirumalai wrote:

> While running a dbench stress test on  a nfs mounted file system, I notic=
e
> the subject error message on the client machine.  The client machine is a=
 48
> core box with NUMA characteristics and 1024 dbench processes running
> continuously in a loop, while another memory hog application runs in para=
llel.
> The client is on 2.6.21.3.  The server is booted up with 2.6.21.3 as well=
=2E
> Attached is the server configuration.  Same test on a 2.6.16 client does =
not
> spew out these messages.  Is this really the server issue, or is the NFS
> client to be blamed here?

I've seen this message with the unfs3 server as well, and it contains some=
=20
explicit checks to avoid sending nlink=3D0. So this is another indication=
=20
that this is actually a client problem.

Regards,=20
---
Peter =C3=85strand=09=09ThinLinc Chief Developer
Cendio AB=09=09http://www.cendio.se
Wallenbergs gata 4
583 30 Link=C3=B6ping=09Phone: +46-13-21 46 00
--789237761-1484332135-1181125551=:18979
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
--789237761-1484332135-1181125551=:18979
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--789237761-1484332135-1181125551=:18979--
