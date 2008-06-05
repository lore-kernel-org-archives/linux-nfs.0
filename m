From: Ricardo Labiaga <labiaga@yahoo.com>
Subject: [NFS] (no subject)
Date: Wed, 4 Jun 2008 17:37:55 -0700 (PDT)
Message-ID: <789108.93067.qm@web31401.mail.mud.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: nfs@lists.sourceforge.net
To: dakoner@gmail.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from neil.brown.name ([220.233.11.133]:51673 "EHLO neil.brown.name"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755861AbYFEAiM convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 4 Jun 2008 20:38:12 -0400
Received: from brown by neil.brown.name with local (Exim 4.63)
	(envelope-from <nfs-bounces@lists.sourceforge.net>)
	id 1K43UX-00033U-HH
	for linux-nfs@vger.kernel.org; Thu, 05 Jun 2008 10:38:09 +1000
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

David,
Can you provide the entire nfsstat -d output on the filer?
- ricardo

> -----Original Message-----
> From: David Konerding [mailto:dakoner@gmail.com]=20
> Sent: Wednesday, June 04, 2008 3:56 PM
> To: nfs@lists.sourceforge.net
> Subject: Re: [NFS] I/O Errors with hard mounts
>=20
> On Wed, Jun 4, 2008 at 3:45 PM, Ricardo Labiaga=20
> <labiaga@yahoo.com> wrote:
> > Does /var/log/messages show any errors around the same=20
> time?=A0 In addition to the network trace and rpcdebug on the=20
> client, take a look at "nfsstat -d" on the filer. Is the=20
> filer dropping the connection?=A0 Look for "dropped with=20
> EAGAIN" or "dropped from vol offline" in the output.=A0 This=20
> will help narrow down the problem.
>=20
> So, sometimes when somebody deletes a lot of data (like the problem w=
e
> just observed),
> the deleting host, and often other hosts, do report=A0 'filer not
> responding' in the logs.
> However, operations that aren't happening in the delete dir, tend to
> work just fine (for example, iozone could be running and doing pretty
> well)).=A0 Further, the most recent time this happened, the host didn=
't
> report filer not responding.
>=20
>=20
> This is the only EAGAN reference I see:
>=20
> assist queue (queued, split mbufs, drop for EAGAIN) =3D (0,=20
> 64478612, 94340)
>=20
>=20
> Dave
>=20



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

