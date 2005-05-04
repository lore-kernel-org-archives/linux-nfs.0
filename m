From: Steve Dickson <SteveD@redhat.com>
Subject: Re: FC3 server -> Solaris client, directories come and go
Date: Wed, 04 May 2005 12:18:41 -0400
Message-ID: <4278F5E1.1040407@RedHat.com>
References: <4276662A.5050602@aastra.com> <Pine.LNX.4.61.0505021947170.22627@maggie.lkpg.cendio.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: "Steven A. Falco" <sfalco@aastra.com>,
	NFS List <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DTMbh-0000Gf-Cz
	for nfs@lists.sourceforge.net; Wed, 04 May 2005 09:20:17 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1DTMbf-0006ln-Sx
	for nfs@lists.sourceforge.net; Wed, 04 May 2005 09:20:17 -0700
To: =?ISO-8859-1?Q?Peter_=C5strand?= <astrand@cendio.se>
In-Reply-To: <Pine.LNX.4.61.0505021947170.22627@maggie.lkpg.cendio.se>
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



Peter =C5strand wrote:
> On Mon, 2 May 2005, Steven A. Falco wrote:
>=20
>> I'm having a problem with directories "disappearing" using a Fedora 3=20
>> NFS server and a solaris 5.10 client (NFS v3).  When I first cd into=20
>> the directory, an ls shows what I expect.  If I then wait an hour and=20
>> redo the ls, I get:
>=20
>=20
> This bug is in Red Hats Bugzilla:=20
> https://bugzilla.redhat.com/bugzilla/show_bug.cgi?id=3D150759. This is =
a=20
> big problem for us as well.

yes.. we have been looking into this... just curious what local
filesystem are you using? ext3?

steved.



-------------------------------------------------------
This SF.Net email is sponsored by: NEC IT Guy Games.
Get your fingers limbered up and give it your best shot. 4 great events, 4
opportunities to win big! Highest score wins.NEC IT Guy Games. Play to
win an NEC 61 plasma display. Visit http://www.necitguy.com/?r=20
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
