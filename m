From: Neil Brown <neilb@cse.unsw.edu.au>
Subject: Re: NFS server reports stale handles intermittently
Date: Mon, 8 Apr 2002 13:12:03 +1000 (EST)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <15537.2691.713117.44648@notabene.cse.unsw.edu.au>
References: <009101c1dc62$2510ac80$47426682@csee.uq.edu.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: <nfs@Lists.sourceforge.net>
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.28])
	by usw-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 16uPWn-0000Sm-00
	for <nfs@lists.sourceforge.net>; Sun, 07 Apr 2002 20:09:09 -0700
Received: From notabene ([129.94.211.194] == dulcimer.orchestra.cse.unsw.EDU.AU)
	(for <c.pascoe@itee.uq.edu.au>) (for <nfs@lists.sourceforge.net>) By
	tone With Smtp ; Mon, 8 Apr 2002 13:08:59 +1000
To: "Chris Pascoe" <c.pascoe@itee.uq.edu.au>
In-Reply-To: message from Chris Pascoe on Friday April 5
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

On Friday April 5, c.pascoe@itee.uq.edu.au wrote:
> Hi,
> 
> I'm trying to track down problems with NFS exports of a large XFS
> partition that's only become apparent when the server went into production
> (of course it didn't show up in 6 months of stability testing!).

Isn't that always the way...

> 
> In my find test, all the stale handles are returned for directories that I
> have no access to the contents of;

This seems to suggest that the problem happens when nfsd has to do a
lookup of ".." in a directory as it has to do when you access a
directory that has fallen out of cache (it has to put it backin cache
by finding a full path name).
However the lookup("..") happens below the normal permission checking
so this shouldn't be a problem.... I had a look at a couple of XFS
patches and they don't seem to do any extra permission checking so it
doesn't seem to be that...


>                                    however we have seen stale handles
> returned for binaries that are most definitely accessible to users (like
> window managers, etc), and mail folders, etc.

If the problem is related to building a patch back to the root, then
you can remove the problem for non-directories by exporting with
"no_subtree_check". 

NeilBrown

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
