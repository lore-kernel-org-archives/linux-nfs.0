From: =?iso-8859-1?Q?Peter_=C5strand?= <astrand@cendio.se>
Subject: Re: PyNFS
Date: Wed, 24 May 2006 09:22:55 +0200 (CEST)
Message-ID: <Pine.LNX.4.64.0605240919340.6128@maggie.lkpg.cendio.se>
References: <ea2ed4af0605232059r56854793s8b7fef615dc587d3@mail.gmail.com>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="789237761-188216910-1148455375=:6128"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Fini5-00065h-IR
	for nfs@lists.sourceforge.net; Wed, 24 May 2006 00:23:13 -0700
Received: from mail.cendio.se ([193.12.253.69])
	by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1Fini1-0000aU-78
	for nfs@lists.sourceforge.net; Wed, 24 May 2006 00:23:13 -0700
To: parinay <parinay@gmail.com>
In-Reply-To: <ea2ed4af0605232059r56854793s8b7fef615dc587d3@mail.gmail.com>
Sender: nfs-admin@lists.sourceforge.net
Errors-To: nfs-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--789237761-188216910-1148455375=:6128
Content-Type: TEXT/PLAIN; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: quoted-printable


> Any help on PyNFS for NFSv2 NFSv3 ??
> I have downloaded  PyNFS for NFSv4.In process of onfiguring and running=
 it.
> Any help on that will also be very much helpfull.

I haven't looked at PyNFS for two years, but then, I was able to generate=
=20
Python code for the mount protocol, by using rpcgen.py. This "mount=20
client" can be found in the UNFS3 CVS.

Don't know about the rest of NFSv2/v3, though.

Kind regards,
--=20
Peter =C5strand		ThinLinc Chief Developer
Cendio			http://www.cendio.se
Teknikringen 3
583 30 Link=F6ping        Phone: +46-13-21 46 00
--789237761-188216910-1148455375=:6128--


-------------------------------------------------------
All the advantages of Linux Managed Hosting--Without the Cost and Risk!
Fully trained technicians. The highest number of Red Hat certifications in
the hosting industry. Fanatical Support. Click to learn more
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=107521&bid=248729&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
