From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH 03/20] SUNRPC: Fix some signed v. unsigned
	comparisons	in xprtsock.c
Date: Mon, 13 Aug 2007 13:42:06 -0400
Message-ID: <1187026926.6628.44.camel@heimdal.trondhjem.org>
References: <20070806155636.31233.33750.stgit@manray.1015granger.net>
	<1186843423.17941.18.camel@heimdal.trondhjem.org>
	<46C06655.6030706@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: chuck.lever@oracle.com
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IKdvf-00009R-W0
	for nfs@lists.sourceforge.net; Mon, 13 Aug 2007 10:42:12 -0700
Received: from pat.uio.no ([129.240.10.15]
	ident=[U2FsdGVkX1/35X/NK2P9GC0NhkByrxdy6OdyO4/baNE=])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IKdvh-0002lD-Ef
	for nfs@lists.sourceforge.net; Mon, 13 Aug 2007 10:42:16 -0700
In-Reply-To: <46C06655.6030706@oracle.com>
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

On Mon, 2007-08-13 at 10:10 -0400, Chuck Lever wrote:
> Trond Myklebust wrote:
> > On Mon, 2007-08-06 at 11:56 -0400, Chuck Lever wrote:
> >> Currently these are not harmful because the range of "len" is less than the
> >> size of a page.
> > 
> > NACK. It is always safe to test an unsigned quantity against a signed
> > quantity for equality, _provided_ that the two quantities are the same
> > size. Since we're comparing an unsigned int to an int, that is clearly
> > the case here.
> > 
> > The explicit cast is not only unnecessary, but it is actually bad, since
> > it may obscure any future comparison errors should we ever for some
> > reason decide to change the size of err.
> 
> As an aside, the purpose of the patches fixing these casts is not just 
> to correct run-time bugs, but also to eliminate compiler and sparse 
> warnings, which in some cases are simply extraneous noise due to 
> compiler pickiness, but can sometimes be nasty bugs (as we found out in 
> fs/nfs/direct.c, recently).
> 
> Eventually I think we should use sparse as part of a check-in test 
> suite, and -Wall all the time for building both fs/nfs and net/sunrpc, 
> as this setting does catch valid bugs.  In that event, eliminating 
> spurious compiler and sparse warnings will cut down on noise and make it 
> easy to spot new problems as we are developing.

With which sparse options are you seeing complaints? I've been running
the latest version of sparse from the git tree with -Wall on both x86_64
and i686 without seeing any reports of a problem with that code.

Anyhow, the policy should be that explicit casts are used only as a last
resort in order to fix a bug. Since we're doing a comparison for
equality on two objects that are guaranteed by the C spec to be the same
size, I can't see why we should have a bug.

Trond


-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
