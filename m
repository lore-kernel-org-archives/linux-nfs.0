From: =?iso-8859-1?Q?Peter_=C5strand?= <astrand@cendio.se>
Subject: Re: NFS export/mount problem ERR_ACCESS for exported mount
 point
Date: Thu, 20 Jul 2006 23:59:53 +0200 (CEST)
Message-ID: <Pine.LNX.4.64.0607201727310.19496@maggie.lkpg.cendio.se>
References: <44BB9F3D.14211.1695037@Ulrich.Windl.rkdvmks1.ngate.uni-regensburg.de>
	<17596.8411.211050.655554@cse.unsw.edu.au>
	<Pine.LNX.4.64.0607181716100.23497@maggie.lkpg.cendio.se>
	<17597.26188.641053.176665@cse.unsw.edu.au>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="789237761-35182539-1153409252=:19496"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1G3gYw-0005P9-8H
	for nfs@lists.sourceforge.net; Thu, 20 Jul 2006 15:00:06 -0700
Received: from mail.cendio.se ([193.12.253.69])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1G3gYt-0004Wz-5V
	for nfs@lists.sourceforge.net; Thu, 20 Jul 2006 15:00:06 -0700
To: Neil Brown <neilb@suse.de>
In-Reply-To: <17597.26188.641053.176665@cse.unsw.edu.au>
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

--789237761-35182539-1153409252=:19496
Content-Type: TEXT/PLAIN; CHARSET=iso-8859-1; FORMAT=flowed
Content-ID: <Pine.LNX.4.64.0607202349301.26217@maggie.lkpg.cendio.se>
Content-Transfer-Encoding: quoted-printable

On Wed, 19 Jul 2006, Neil Brown wrote:

>> When you say "the user space nfs server", you mean Olaf Kirchs nfs-ser=
ver
>> (http://freshmeat.net/projects/nfs-server/), right? Any particular rea=
son
>> why you are recommending this one instead of UNFS3
>> (http://freshmeat.net/projects/unfs3/)?
>
> I'm not recommending anything in particular.  I didn't even realise
> there were two separate code bases.... I suspect they both come from
> common code started by Mark Shand years and years ago...

Actually, as far as I understand, UNFS3 is a completely independent=20
implementation, but borrows some ideas wrt the filehandles from the old=20
implementation.


> It was more a general reference than a specific recommendation.

Since the old implementation is basically un-maintained nowadays (for=20
example, the Freshmeat entry links to=20
ftp://linux.mathematik.tu-darmstadt.de/pub/linux/people/okir/, which=20
doesn't exist), I think most users will find UNFS3 more useful.

UNFS3 lacks some features of the old server, such as arbitrary uid=20
mappings, but this is pretty exotic. On the other hand, UNFS3 has some=20
pretty cool features[*] such as mount-time password support.

[*]: IMHO, since I implemented this :-)


Best regards,
--=20
Peter =C5strand		ThinLinc Chief Developer
Cendio			http://www.cendio.se
Teknikringen 3
583 30 Link=F6ping        Phone: +46-13-21 46 00
--789237761-35182539-1153409252=:19496
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys -- and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
--789237761-35182539-1153409252=:19496
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--789237761-35182539-1153409252=:19496--
