From: "Lever, Charles" <Charles.Lever@netapp.com>
Subject: RE: network storage solutions
Date: Fri, 16 May 2003 09:23:04 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <482A3FA0050D21419C269D13989C61131274E1@lavender-fe.eng.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Cc: <beowulf@beowulf.org>, "Josip Loncaric" <josip@lanl.gov>,
   <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from mx01.netapp.com ([198.95.226.53])
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19GhzN-0008QS-00
	for <nfs@lists.sourceforge.net>; Fri, 16 May 2003 09:23:21 -0700
To: "Robert G. Brown" <rgb@phy.duke.edu>,
   "Jeffrey B. Layton" <laytonjb@bellsouth.net>
Errors-To: nfs-admin@lists.sourceforge.net
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

> -----Original Message-----
> From: Robert G. Brown [mailto:rgb@phy.duke.edu]
> Sent: Friday, May 16, 2003 9:22 AM
> To: Jeffrey B. Layton
> Cc: beowulf@beowulf.org; Josip Loncaric; nfs@lists.sourceforge.net;
> Lever, Charles
> Subject: Re: network storage solutions
>=20
> Perhaps it is a question of probability, and what people are=20
> willing to
> accept in terms of data loss in a given environment.  It is a
> cost-benefit equation, as always, so acceptable solutions do=20
> have to at
> least examine the cost of a corrupted file against other costs
> associated with using hard mounts everywhere. =20

right.  we're dealing with probabilities here.  there is always
a non-zero probability of data corruption, even with local
file systems.

using soft mounts increases the probability of silent data
corruption.  if you can live with that, or you have solid
recovery mechanisms, then soft is a reasonable choice.

but it's best to be informed about this choice, rather than
just stabbing at using soft mounts because it makes other
problems go away.


-------------------------------------------------------
Enterprise Linux Forum Conference & Expo, June 4-6, 2003, Santa Clara
The only event dedicated to issues related to Linux enterprise solutions
www.enterpriselinuxforum.com

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
