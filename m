From: "Chris Pascoe" <c.pascoe@itee.uq.edu.au>
Subject: Re: NFS server reports stale handles intermittently
Date: Mon, 8 Apr 2002 13:44:52 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <033401c1deaf$bd9cfdb0$47426682@csee.uq.edu.au>
References: <009101c1dc62$2510ac80$47426682@csee.uq.edu.au> <15537.2691.713117.44648@notabene.cse.unsw.edu.au>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Cc: <nfs@Lists.sourceforge.net>
To: "Neil Brown" <neilb@cse.unsw.edu.au>
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
List-Archive: <http://www.geocrawler.com/redir-sf.php3?list=nfs>

Hi Neil,

> However the lookup("..") happens below the normal permission checking
> so this shouldn't be a problem.... I had a look at a couple of XFS
> patches and they don't seem to do any extra permission checking so it
> doesn't seem to be that...

Yes, this is exactly the case.  I tracked down yesterday where it happens to
be this case (XFS does some permission checks in xfs_lookup and that causes
the ".." lookup to fail) and let the XFS people know; they're looking into
it.

It still doesn't help me figure why some clients have got stale handles back
for files they should have been able to access though.  Once this first
problem is sorted out I'll hopefully be able to increase the S/N ratio and
figure out if there's anything in common between the files the problems are
on (although, it might not be happening at all any more, I've had no
complaints today).

Regards,
Chris


_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
