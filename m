From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: Re: [PATCH] fix nfsidem cthon test
Date: Mon, 25 Oct 2004 10:41:38 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1098715298.10720.38.camel@lade.trondhjem.org>
References: <1098341478.21421.7.camel@hole.melbourne.sgi.com>
	 <1098343891.28394.15.camel@lade.trondhjem.org>
	 <20041021161309.GC24417@fieldses.org>
	 <1098413781.21421.37.camel@hole.melbourne.sgi.com>
	 <20041022024349.GA30004@fieldses.org>
	 <1098696830.21421.163.camel@hole.melbourne.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "Dr. Bruce Fields" <bfields@fieldses.org>,
	Neil Brown <neilb@cse.unsw.edu.au>,
	Linux NFS Mailing List <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CM62m-0007is-I7
	for nfs@lists.sourceforge.net; Mon, 25 Oct 2004 07:41:56 -0700
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.41)
	id 1CM62k-0003rK-Fb
	for nfs@lists.sourceforge.net; Mon, 25 Oct 2004 07:41:56 -0700
To: Greg Banks <gnb@melbourne.sgi.com>
In-Reply-To: <1098696830.21421.163.camel@hole.melbourne.sgi.com>
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

m=E5 den 25.10.2004 Klokka 19:33 (+1000) skreiv Greg Banks:

> Trond, I don't think it's a good idea to make no_subtree_check the
> default, as this would have the undesirable side effect of defeating
> directory permission checks.  Perhaps we can just make it behave
> more helpfully.

If by "make it behave more helpfully" you mean get rid of the aliased
filehandles, then I'm fine with that. I'm curious to see how you propose
to do it though: as far as I can see there is no way to reconcile the
goal of proper directory permission checks and sane filehandle
behaviour.

Since the permissions problem is solvable in other ways (i.e. by only
exporting partitions/volumes), and in fact that is the way all other
known NFS server implementations expect you to solve the problem, then I
see no problems with making that the default.

A server that doesn't encourage basic data integrity tends to be frowned
upon.

> Neil, is there a good reason why knfsd encodes the parent inode in the
> fileid under all circumstances?  At least some filesystems (XFS, ext3)
> provide apparently useful export_operations.get_parent() functions
> which could be used in find_exported_dentry() instead of sending this
> information out in the fileid.  This would also free up some space to
> encode 64 bit inode numbers (which my hidden agenda).

Look more closely: get_parent() expects the parameter to be a directory.
I don't think ext2/3 or XFS encode a list of parent directories in the
on-disk inode for a regular file.

Cheers,
 Trond

--=20
Trond Myklebust <trond.myklebust@fys.uio.no>



-------------------------------------------------------
This SF.net email is sponsored by: IT Product Guide on ITManagersJournal
Use IT products in your business? Tell us what you think of them. Give us
Your Opinions, Get Free ThinkGeek Gift Certificates! Click to find out more
http://productguide.itmanagersjournal.com/guidepromo.tmpl
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
