From: Peter Astrand <astrand@cendio.se>
Subject: Re: unfsd strange behaviour ?
Date: Wed, 22 Nov 2006 10:30:21 +0100 (CET)
Message-ID: <Pine.LNX.4.64.0611221027150.1093@maggie.lkpg.cendio.se>
References: <9c8209a10611212358o75127f4qd433e37c32fefc29@mail.gmail.com>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="===============1168520925=="
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GmoR8-00049z-6I
	for nfs@lists.sourceforge.net; Wed, 22 Nov 2006 01:30:34 -0800
Received: from mail.cendio.se ([193.12.253.69])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1GmoR7-0006mo-Ss
	for nfs@lists.sourceforge.net; Wed, 22 Nov 2006 01:30:35 -0800
To: Murali Bashyam <mbcoder@gmail.com>
In-Reply-To: <9c8209a10611212358o75127f4qd433e37c32fefc29@mail.gmail.com>
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

--===============1168520925==
Content-Type: TEXT/PLAIN; CHARSET=UTF-8
Content-ID: <Pine.LNX.4.64.0611221027211.1093@maggie.lkpg.cendio.se>
Content-Transfer-Encoding: quoted-printable

On Tue, 21 Nov 2006, Murali Bashyam wrote:

> I am running unfsd 0.9.16 on a linux 2.6 machine. I notice that from a
> client machine while reading a file (say  XYZ)  the NFS client does GET=
ATTR
> using a file handle corresponding to that file, and unfsd after process=
ing
> that request initiates a LOOKUP operation for another file in the same
> directory. ?=20

You are saying that unfsd initiates a LOOKUP operation on itself? That=20
doesn't make sense. I suggest that you give us access to a tcp dump,=20
Wireshark screenshot or something like that.=20

Regards,=20
--=20
Peter =C3=85strand		ThinLinc Chief Developer
Cendio AB		http://www.cendio.se
Teknikringen 3
583 30 Link=C3=B6ping	Phone: +46-13-21 46 00
--===============1168520925==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys - and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
--===============1168520925==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--===============1168520925==--
