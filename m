From: =?ISO-8859-1?Q?Kris=20Vassallo?= <kris@linuxcertified.com>
Subject: Re: FC3 server -> Solaris client, directories come and go
Date: 02 May 2005 11:15:13 -0700
Message-ID: <200505021755.j42HtZnl030456@meteor.hosting4less.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DSfS1-0002Yp-DD
	for nfs@lists.sourceforge.net; Mon, 02 May 2005 11:15:25 -0700
Received: from meteor.hosting4less.com ([63.99.109.5])
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1DSfRz-0003vb-UI
	for nfs@lists.sourceforge.net; Mon, 02 May 2005 11:15:25 -0700
To: astrand@cendio.se, sfalco@aastra.com
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

Would this same bug cause the issue where linux clients would start =
getting ESTALE ERRORS randomly?
-Kris

-----Original Message-----
From:  Peter =C5strand
Date:  5/2/05 10:49 am
To:  Steven A. Falco
Cc:  NFS List 
Subj:  Re: [NFS] FC3 server -> Solaris client, directories come and go

On Mon, 2 May 2005, Steven A. Falco wrote:

> I'm having a problem with directories "disappearing" using a Fedora 3 =
NFS 
> server and a solaris 5.10 client (NFS v3).  When I first cd into the 
> directory, an ls shows what I expect.  If I then wait an hour and redo=
 the 
> ls, I get:

This bug is in Red Hats Bugzilla: 
https://bugzilla.redhat.com/bugzilla/show_bug.cgi?id=3D150759. This is a=
 
big problem for us as well.


-- 
Peter =C5strand		Chief Developer
Cendio			www.thinlinc.com
Teknikringen 3		www.cendio.se
583 30 Link=F6ping        Phone: +46-13-21 46 00


-------------------------------------------------------
This SF.Net email is sponsored by: NEC IT Guy Games.
Get your fingers limbered up and give it your best shot. 4 great events, 4
opportunities to win big! Highest score wins.NEC IT Guy Games. Play to
win an NEC 61 plasma display. Visit http://www.necitguy.com/?r=20
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
