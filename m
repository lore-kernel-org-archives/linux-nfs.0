From: Christoph Hellwig <hch@infradead.org>
Subject: Re: Portmap - was Re: Does mountd/statd really need to listen
	on a privileged port??
Date: Fri, 27 Apr 2007 15:37:56 +0100
Message-ID: <20070427143756.GA15222@infradead.org>
References: <17958.48121.280256.493824@notabene.brown>
	<200704251056.03664.olaf.kirch@oracle.com>
	<46312615.2090307@RedHat.com>
	<200704270820.19718.olaf.kirch@oracle.com>
	<46320251.8050900@redhat.com> <20070427140931.GA9998@infradead.org>
	<463206D4.9050504@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Neil Brown <neilb@suse.de>, Steve Dickson <SteveD@redhat.com>,
	Christoph Hellwig <hch@infradead.org>,
	Matthias Koenig <mkoenig@novell.com>, nfs@lists.sourceforge.net,
	Javier Fern?ndez-Sanguino Pe?a <jfs@computer.org>,
	Olaf Kirch <olaf.kirch@oracle.com>, anibal@debian.org
To: Peter Staubach <staubach@redhat.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HhRaE-0002k5-KP
	for nfs@lists.sourceforge.net; Fri, 27 Apr 2007 07:38:02 -0700
Received: from pentafluge.infradead.org ([213.146.154.40])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1HhRaG-0003fH-KD
	for nfs@lists.sourceforge.net; Fri, 27 Apr 2007 07:38:05 -0700
In-Reply-To: <463206D4.9050504@redhat.com>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

On Fri, Apr 27, 2007 at 10:21:08AM -0400, Peter Staubach wrote:
> However, we are also looking at making fairly major changes to the
> support already.  I think that the situation will be more complex
> than we would ideally like, no matter what we do.  The IPv6 support
> is not trivial stuff and will most likely have an impact on the
> applications that use RPC no matter what we do.  There are other
> things that we can and perhaps should do as well to increase the
> usefulness of the support.  I suspect that there are things that
> we could do to reduce the number of UDP and TCP ports being used,
> for example.

All this would hopefully be optional so we can at least switch
back to the old behaviour for debugging purposed.

Anyway, back to the topic of codebases.  I'm not sure a 1993 codedrop
that went through a few hands since is a good start.   I suspect the
best that could be done (although it involves a lot of the work) is
the following:

 (1) split out the glibc rpc code into a library of it's own
 (2) reformat the latest sun tirpc code drop and the ex-glibc code
     the same way so it can actually be properly diffed
 (3) compare it and port important fixes and possibly features over
     from that codebase

Now there's some interesting differences between the two, not just
in the bug/feature categories Olaf already wrote a lot of notes.
For example I assume the latest Sun code still uses their own
threading package with the thr_ prefix functions that are quite
different from pthreads in many ways, while the glibc code currently
uses glibc's internal locking macros so both would need a conversion
to the proper pthreads interfaces first, etc.

(and the 2.3-based, ex-freebsd bull code uses a lot of ugly macros
 to convert freebsd internalish locking and other libc bits back to
 posix, that's not exactly maintainable either)

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
