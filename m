From: Greg Banks <gnb@melbourne.sgi.com>
Subject: Re: Re: [PATCH] fix nfsidem cthon test
Date: Fri, 22 Oct 2004 14:12:07 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1098418326.21421.49.camel@hole.melbourne.sgi.com>
References: <1098341478.21421.7.camel@hole.melbourne.sgi.com>
	 <1098343891.28394.15.camel@lade.trondhjem.org>
	 <20041021161309.GC24417@fieldses.org>
	 <1098413781.21421.37.camel@hole.melbourne.sgi.com>
	 <16760.31766.119716.302669@cse.unsw.edu.au>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Trond Myklebust <trond.myklebust@fys.uio.no>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Linux NFS Mailing List <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CKqUq-0004Wq-Sq
	for nfs@lists.sourceforge.net; Thu, 21 Oct 2004 20:53:44 -0700
Received: from omx2-ext.sgi.com ([192.48.171.19] helo=omx2.sgi.com)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.41)
	id 1CKqUq-0001jT-86
	for nfs@lists.sourceforge.net; Thu, 21 Oct 2004 20:53:44 -0700
To: Neil Brown <neilb@cse.unsw.edu.au>
In-Reply-To: <16760.31766.119716.302669@cse.unsw.edu.au>
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

On Fri, 2004-10-22 at 13:18, Neil Brown wrote:
> On Friday October 22, gnb@melbourne.sgi.com wrote:
> > +	/*
> > +	 * If target is a hard link to the source, then noop.
> > +	 * We compare the entire file handle instead of just
> > +	 * the fileid to handle the nohide case.   This test
> > +	 * is supposed to happen on the server, but some servers
> > +	 * are buggy.
> > +	 */
> 
> I don't disagree with this patch, and I don't want to assert that no
> servers are buggy, or that the Linux server in particular isn't
> buggy.  However I don't think the line:
> 
>     This test is supposed to happen on the server, but some servers
>     are buggy.
> 
> is fair or accurate.

I'm happy to revise the comment ;-)

> This test is trivial to do on the server, 

Agreed.

> and I am sure it is being
> done.

I took a brief look at the server code this morning, and came to 
the conclusion that the test is done in vfs_rename() and is done
correctly, or at least would be if the only thing the client did
was a RENAME call.

> The real problem here is, I think, due to "sillyrename"
> Consider
>     create /a/fred
>     ln /a/fred /b/bob
>     open /b/bob
>     rename /a/fred /b/bob
> 
> The rename should be a no-op because the two names refer to the same
> file.   The client might be able to tell if they are the same by
> inspecting the filehandles and so avoid the rename.  That is a useful
> optimisation but is not guaranteed to find that they are the same when
> they are.

Agreed, and this is what the patch does:  it happens to make the test
pass for all the servers and backend filesystems I've seen test results
for.

> As the client has /b/bob open, and as it thinks /b/bob might be about
> to be unlinked, it replaces the
>     rename /a/fred /b/bob
> call with a silly-rename, viz
>     rename /b/bob /b/.nfsXXXX
>     rename /a/fred /a/bob
> 
> This will do something very different.  It will unlink /a/fred, which
> it shouldn't.

I agree with your analysis...yet this same client code works against
an IRIX server.  I'll grab some snoops and see what's happening on
the wire in that case.

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
