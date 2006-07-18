From: =?iso-8859-1?Q?Peter_=C5strand?= <astrand@cendio.se>
Subject: Re: NFS export/mount problem ERR_ACCESS for exported mount
 point
Date: Tue, 18 Jul 2006 17:24:00 +0200 (CEST)
Message-ID: <Pine.LNX.4.64.0607181716100.23497@maggie.lkpg.cendio.se>
References: <44BB9F3D.14211.1695037@Ulrich.Windl.rkdvmks1.ngate.uni-regensburg.de>
	<17596.8411.211050.655554@cse.unsw.edu.au>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="789237761-260090165-1153236178=:23497"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1G2rQi-0008On-IR
	for nfs@lists.sourceforge.net; Tue, 18 Jul 2006 08:24:12 -0700
Received: from mail.cendio.se ([193.12.253.69])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1G2rQh-0005ZL-KG
	for nfs@lists.sourceforge.net; Tue, 18 Jul 2006 08:24:13 -0700
To: Neil Brown <neilb@suse.de>
In-Reply-To: <17596.8411.211050.655554@cse.unsw.edu.au>
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

--789237761-260090165-1153236178=:23497
Content-Type: TEXT/PLAIN; CHARSET=iso-8859-1; FORMAT=flowed
Content-ID: <Pine.LNX.4.64.0607181723021.23497@maggie.lkpg.cendio.se>
Content-Transfer-Encoding: quoted-printable

On Tue, 18 Jul 2006, Neil Brown wrote:

> The "user space" nfs server does have a --re-export option and it does
> work to some extent, but there are plenty of scenarios where it would
> perform very poorly or fail completely.

When you say "the user space nfs server", you mean Olaf Kirchs nfs-server=
=20
(http://freshmeat.net/projects/nfs-server/), right? Any particular reason=
=20
why you are recommending this one instead of UNFS3=20
(http://freshmeat.net/projects/unfs3/)?

Regards,
--=20
Peter =C5strand		ThinLinc Chief Developer
Cendio			http://www.cendio.se
Teknikringen 3
583 30 Link=F6ping        Phone: +46-13-21 46 00
--789237761-260090165-1153236178=:23497
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys -- and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
--789237761-260090165-1153236178=:23497
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--789237761-260090165-1153236178=:23497--
