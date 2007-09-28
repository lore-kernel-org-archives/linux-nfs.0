From: Jeff Layton <jlayton@redhat.com>
Subject: Re: [PATCH][RFC] use after free in NLM subsystem -- how best
 to fix it?
Date: Fri, 28 Sep 2007 08:37:07 -0400
Message-ID: <20070928083707.ab7632e5.jlayton@redhat.com>
References: <20070924161236.48779845.jlayton@poochiereds.net>
	<1190672003.6700.34.camel@heimdal.trondhjem.org>
	<20070925102501.c770c202.jlayton@redhat.com>
	<1190739948.7330.18.camel@heimdal.trondhjem.org>
	<20070927135938.d5e733c6.jlayton@redhat.com>
	<20070927183803.GF10113@fieldses.org>
	<20070927150927.12d07946.jlayton@redhat.com>
	<20070927205533.GC21523@fieldses.org>
	<20070927211307.cfe63de9.jlayton@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IbF5n-0004AA-7l
	for nfs@lists.sourceforge.net; Fri, 28 Sep 2007 05:37:15 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IbF5o-0008O8-78
	for nfs@lists.sourceforge.net; Fri, 28 Sep 2007 05:37:17 -0700
In-Reply-To: <20070927211307.cfe63de9.jlayton@redhat.com>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

On Thu, 27 Sep 2007 21:13:07 -0400
Jeff Layton <jlayton@redhat.com> wrote:
> I think for now, I'm going to focus on defining what the behavior
> should be as far as allowing a new lockd to start while the old one
> is still running. And then once we do that, to try to clean up the
> locking around some of the vars that define that behavior.

Now that I've looked over this, there are quite a few things that
don't seem to be adequately protected against concurrent accesses by
multiple lockds. The simplest thing to do here would seem to be to
prevent multiple lockd's from ever being started.

Some questions:

1) the code seems to go out of its way to allow a new lockd to start
before the old one comes all the way down. Is there really a situation
where we need this? It seems like this could be papering over bugs
that prevent lockd from coming down properly. If it is needed then
I suppose we'll have to focus on properly preventing races when
accessing global vars in this situation.

2) lockd seems to take the BKL early and drop it just before exit. Does
anyone know what that's intended to protect? This might be a good time
to take the BKL out of lockd altogether...

-- 
Jeff Layton <jlayton@redhat.com>

-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2005.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
