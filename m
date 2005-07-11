From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH NFSv2] Drop inode after rename
Date: Mon, 11 Jul 2005 07:56:05 -0400
Message-ID: <1121082965.8204.42.camel@lade.trondhjem.org>
References: <20050711104611.GK27163@suse.de>
	 <1121079942.8204.15.camel@lade.trondhjem.org>
	 <20050711110733.GN27163@suse.de>
	 <1121080460.8204.18.camel@lade.trondhjem.org>
	 <20050711112431.GP27163@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: nfs@lists.sourceforge.net, Michael Schroeder <mls@suse.de>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Drwtl-0006Sj-31
	for nfs@lists.sourceforge.net; Mon, 11 Jul 2005 04:56:33 -0700
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.44)
	id 1Drwtj-0001wn-St
	for nfs@lists.sourceforge.net; Mon, 11 Jul 2005 04:56:33 -0700
To: Olaf Kirch <okir@suse.de>
In-Reply-To: <20050711112431.GP27163@suse.de>
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

m=C3=A5 den 11.07.2005 Klokka 13:24 (+0200) skreiv Olaf Kirch:

> unfsd definitely does it this way, unfortunately. I agree that
> it's not a very good idea to continue to use unfsd, but...

I still don't have a good idea about what kind of cache consistency
guarantees a client should attempt to offer against a unfsd server.

> I would still vote for merging this patch, as it just does
> the same nlink accounting that other functions already do,
> eg nfs_rmdir, nfs_safe_remove, etc. The latter even has a comment
> preceding it that says
>=20
> * We invalidate the attribute cache and free the inode prior to the opera=
tion
> * to avoid possible races if the server reuses the inode.
>=20
> So I think my patch isn't that absurd, is it? :)

...but it should be unnecessary.

d_delete() is supposed to cause the inode to be dropped: if it cannot
immediately iput the inode, it will drop the dentry. So unless there
exists a hard link or an aliased dentry, the inode should get dropped
and freed pretty rapidly.

The only case I can see that might cause a problem is if someone holds
onto the dropped dentry for long enough to have a lookup() pick up the
inode again. I cannot see how your patch would change matters there.

I also have some trouble seeing why basic checks of mtime and size upon
lookup/open would fail to catch most of the races. AFAICS you should
almost always get a pagecache invalidation due to that.

Cheers,
  Trond



-------------------------------------------------------
This SF.Net email is sponsored by the 'Do More With Dual!' webinar happening
July 14 at 8am PDT/11am EDT. We invite you to explore the latest in dual
core and dual graphics technology at this free one hour event hosted by HP, 
AMD, and NVIDIA.  To register visit http://www.hp.com/go/dualwebinar
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
