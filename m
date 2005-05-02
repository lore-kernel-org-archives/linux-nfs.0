From: =?iso-8859-1?Q?Peter_=C5strand?= <astrand@cendio.se>
Subject: Re: FC3 server -> Solaris client, directories come and go
Date: Mon, 2 May 2005 19:49:17 +0200 (CEST)
Message-ID: <Pine.LNX.4.61.0505021947170.22627@maggie.lkpg.cendio.se>
References: <4276662A.5050602@aastra.com>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="789237761-167493841-1115056114=:22627"
Cc: NFS List <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DSf2w-000097-OR
	for nfs@lists.sourceforge.net; Mon, 02 May 2005 10:49:30 -0700
Received: from mail.cendio.se ([193.12.253.69])
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.41)
	id 1DSf2s-0007cY-T5
	for nfs@lists.sourceforge.net; Mon, 02 May 2005 10:49:30 -0700
To: "Steven A. Falco" <sfalco@aastra.com>
In-Reply-To: <4276662A.5050602@aastra.com>
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

--789237761-167493841-1115056114=:22627
Content-Type: TEXT/PLAIN; CHARSET=iso-8859-1; format=flowed
Content-ID: <Pine.LNX.4.61.0505021948411.22627@maggie.lkpg.cendio.se>
Content-Transfer-Encoding: quoted-printable

On Mon, 2 May 2005, Steven A. Falco wrote:

> I'm having a problem with directories "disappearing" using a Fedora 3 N=
FS=20
> server and a solaris 5.10 client (NFS v3).  When I first cd into the=20
> directory, an ls shows what I expect.  If I then wait an hour and redo =
the=20
> ls, I get:

This bug is in Red Hats Bugzilla:=20
https://bugzilla.redhat.com/bugzilla/show_bug.cgi?id=3D150759. This is a=20
big problem for us as well.


--=20
Peter =C5strand		Chief Developer
Cendio			www.thinlinc.com
Teknikringen 3		www.cendio.se
583 30 Link=F6ping        Phone: +46-13-21 46 00
--789237761-167493841-1115056114=:22627--


-------------------------------------------------------
This SF.Net email is sponsored by: NEC IT Guy Games.
Get your fingers limbered up and give it your best shot. 4 great events, 4
opportunities to win big! Highest score wins.NEC IT Guy Games. Play to
win an NEC 61 plasma display. Visit http://www.necitguy.com/?r=20
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
