From: Ricardo Labiaga <labiaga@yahoo.com>
Subject: Re: [NFS] I/O Errors with hard mounts
Date: Wed, 4 Jun 2008 15:45:04 -0700 (PDT)
Message-ID: <927260.87785.qm@web31407.mail.mud.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: nfs@lists.sourceforge.net
To: dakoner@gmail.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from neil.brown.name ([220.233.11.133]:50370 "EHLO neil.brown.name"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750900AbYFDWp2 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 4 Jun 2008 18:45:28 -0400
Received: from brown by neil.brown.name with local (Exim 4.63)
	(envelope-from <nfs-bounces@lists.sourceforge.net>)
	id 1K41jP-0002aa-6k
	for linux-nfs@vger.kernel.org; Thu, 05 Jun 2008 08:45:23 +1000
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Does=A0/var/log/messages show any errors around the same time?=A0 In ad=
dition=A0to the=A0network trace=A0and=A0rpcdebug on the client, take a =
look at "nfsstat -d" on the filer.=A0Is=A0the filer=A0dropping the conn=
ection?=A0 Look for "dropped with EAGAIN" or "dropped from vol offline"=
 in the output.=A0 This will help narrow down the problem.
- ricardo
> -----Original Message-----
> From: David Konerding [mailto:dakoner@gmail.com]=20
> Sent: Wednesday, June 04, 2008 6:33 AM
> To: nfs@lists.sourceforge.net
> Subject: [NFS] I/O Errors with hard mounts
>=20
> Hi,
>=20
> We have a bunch of Linux clients (SLES 10 SP1) which mount a=20
> NetApp filer.
>=20
> When the NetApp gets very, very busy, for example, one user is
> deleting 1Tbyte of data
> while another user is doing a 30 client throughput test, it will stop
> responding to some requests.
>=20
> Although we are using hard mounts, some users report that during the
> hammering period, some of their
> file operations produce "I/O Error" messages on their terminal.
>=20
> We checked, and the hosts are indeed using hard mounting.=A0 From our
> reading, I/O Errors
> should only ever make it back to the user if are using soft mounting.
>=20
> We're pretty sure the filer is not sending back an NFS_ERR=20
> response (and we're
> pretty sure that wouldn't get reported to the user as an I/O Error...=
)
>=20
> At this point, we suspect there must be a path in the NFS
> implementation that returns I/O Error to user
> space even with a hard mount.
>=20
> Any ideas?
>=20
> Dave



     =20

-----------------------------------------------------------------------=
--
Check out the new SourceForge.net Marketplace.
It's the best place to buy or sell services for
just about anything Open Source.
http://sourceforge.net/services/buy/index.php
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
_______________________________________________
Please note that nfs@lists.sourceforge.net is being discontinued.
Please subscribe to linux-nfs@vger.kernel.org instead.
    http://vger.kernel.org/vger-lists.html#linux-nfs

