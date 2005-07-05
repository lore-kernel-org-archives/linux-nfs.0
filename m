From: Peter Staubach <staubach@redhat.com>
Subject: Re: Linux client with MS SFU server
Date: Tue, 05 Jul 2005 14:16:10 -0400
Message-ID: <42CACE6A.6090005@redhat.com>
References: <Pine.LNX.4.61.0507051838180.28175@maggie.lkpg.cendio.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Dps2l-0003aR-T4
	for nfs@lists.sourceforge.net; Tue, 05 Jul 2005 11:21:15 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1Dps2j-0005GG-EB
	for nfs@lists.sourceforge.net; Tue, 05 Jul 2005 11:21:15 -0700
To: =?ISO-8859-1?Q?Peter_=C5strand?= <astrand@cendio.se>
In-Reply-To: <Pine.LNX.4.61.0507051838180.28175@maggie.lkpg.cendio.se>
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

>
> I'm trying to use the Linux NFS client with a Microsoft "Services For=20
> UNIX" (SFU) server. The SFU version if 2.2. The server is actually a=20
> HP Storageworks 1000s NAS server.
>
> It's possible to mount, but then I'm stuck. Basically every operation=20
> on /mnt, except ls/stat on the mount point itself, gives me=20
> "permission denied". The permissions on /mnt is 050, so I'm not=20
> surprised I cannot enter the directory. What's strange, though, is=20
> that "chown", "chmod" etc also fails, even though I'm root, and the=20
> server does not use root squashing.
>
> I've captured a few packets with Ethereal. What's surprises me is that=20
> the server is returning RPC-level AUTH_ERRORs. Is this really normal?
>
> I've tried both UDP and TCP, and both v2 and v3. The packet capture is=20
> available as http://www.cendio.se/~peter/tmp/sfu22-auth-error.cap.


Does this server need to be configured with the uid and maybe gid of the=20
user to
be accessing files on the file system?  I have seen some situations,=20
typically
with Microsoft servers, that need to be accessed using a specific uid/gid
combination.  Since these systems don't have the concept of uid and gid=20
anyway,
perhaps this is required here.

At Connectathon, it seems like some of the servers need to be accessed us=
ing
magic uids and gids...

       ps


-------------------------------------------------------
SF.Net email is sponsored by: Discover Easy Linux Migration Strategies
from IBM. Find simple to follow Roadmaps, straightforward articles,
informative Webcasts and more! Get everything you need to get up to
speed, fast. http://ads.osdn.com/?ad_id=7477&alloc_id=16492&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
