From: Greg Banks <gnb@melbourne.sgi.com>
Subject: Re: Re: [PATCH] fix nfsidem cthon test
Date: Mon, 25 Oct 2004 19:33:50 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1098696830.21421.163.camel@hole.melbourne.sgi.com>
References: <1098341478.21421.7.camel@hole.melbourne.sgi.com>
	 <1098343891.28394.15.camel@lade.trondhjem.org>
	 <20041021161309.GC24417@fieldses.org>
	 <1098413781.21421.37.camel@hole.melbourne.sgi.com>
	 <20041022024349.GA30004@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Trond Myklebust <trond.myklebust@fys.uio.no>,
	Linux NFS Mailing List <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CM0wN-0006QW-Bb
	for nfs@lists.sourceforge.net; Mon, 25 Oct 2004 02:14:59 -0700
Received: from omx3-ext.sgi.com ([192.48.171.20] helo=omx3.sgi.com)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.41)
	id 1CM0wM-0002fQ-TX
	for nfs@lists.sourceforge.net; Mon, 25 Oct 2004 02:14:59 -0700
To: "J. Bruce Fields" <bfields@fieldses.org>,
	Neil Brown <neilb@cse.unsw.edu.au>
In-Reply-To: <20041022024349.GA30004@fieldses.org>
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

On Fri, 2004-10-22 at 12:43, J. Bruce Fields wrote:
> On Fri, Oct 22, 2004 at 12:56:21PM +1000, Greg Banks wrote:
> > Yes, and I should have seen that...the attached patch deals
> > with nohide by comparing the whole file handle instead of just
> > the fileid.
> 
> Weird.  But I thought the bug the cthon test was seeing was the result
> of the server generating two different filehandles pointing to the same
> file?  (And if that isn't the problem, then why was turning on
> no_subtree_check also making the test pass?)

You're right, this "feature" of subtree_check is the cause of the
problem.  My patch comparing entire filehandles is useless when the
server does things like that.  <sigh> I shouldn't have just extended
the working patch without retesting...

The test works against an IRIX server because the IRIX server always
does the equivalent of no_subtree_check, or at least the filehandles
are the same for two links to the the same inode with different parents.

This strikes me as eminently sensible behaviour, and rfc1813 agrees
but doesn't mandate it: "Servers should try to maintain a one-to-one
correspondence between file handles and files, but this is not
required".  So technically the server is behaving within the limits
of the RFC, and clients are supposed to be able to deal with it.

OTOH the server behaviour is stupid, because it results in two separate
client-side inodes and the resulting possibility of data corruption,
and not just in the Linux client.

For example, the IRIX client is only passing the test by virtue of a
client-side accident.  It appears a side effect of the link() syscall
preceeding the rename() avoids the LOOKUP call and so the client thinks
the files are the same inode and elides the RENAME call.  If just the
rename() syscall is done on a fresh mount, the IRIX client thinks
the files are different and does a RENAME call, which behaves
correctly on the server.

In other words, I really don't think a server should behave the way,
it's too confusing for clients.

Trond, I don't think it's a good idea to make no_subtree_check the
default, as this would have the undesirable side effect of defeating
directory permission checks.  Perhaps we can just make it behave
more helpfully.

Neil, is there a good reason why knfsd encodes the parent inode in the
fileid under all circumstances?  At least some filesystems (XFS, ext3)
provide apparently useful export_operations.get_parent() functions
which could be used in find_exported_dentry() instead of sending this
information out in the fileid.  This would also free up some space to
encode 64 bit inode numbers (which my hidden agenda).

Greg.
-- 
Greg Banks, R&D Software Engineer, SGI Australian Software Group.
I don't speak for SGI.




-------------------------------------------------------
This SF.net email is sponsored by: IT Product Guide on ITManagersJournal
Use IT products in your business? Tell us what you think of them. Give us
Your Opinions, Get Free ThinkGeek Gift Certificates! Click to find out more
http://productguide.itmanagersjournal.com/guidepromo.tmpl
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
