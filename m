From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: NFSERR_EAGAIN
Date: Fri, 11 Jul 2003 12:13:42 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <16142.36310.296330.116819@charged.uio.no>
References: <3F0DB088.303@cinesite.co.uk>
	<shsbrw20zue.fsf@charged.uio.no>
	<3F0E8975.2000009@cinesite.co.uk>
Reply-To: trond.myklebust@fys.uio.no
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs <nfs@lists.sourceforge.net>,
    Iain Irwin-Powell <Iain@cinesite.co.uk>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19auuY-0001sw-00
	for <nfs@lists.sourceforge.net>; Fri, 11 Jul 2003 03:13:55 -0700
To: Danny Smith <dannys@cinesite.co.uk>
In-Reply-To: <3F0E8975.2000009@cinesite.co.uk>
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
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

>>>>> " " == Danny Smith <dannys@cinesite.co.uk> writes:

     > I really want to know how it got into the source in the first
     > place?

That's a question for Olaf Kirch. I've never touched that entry.

     > If the server is broken, but we can work with it anyway without
     > upsetting anything else, this would be a "good thing" in my
     > book (of course, we would take it up with SGI too).

Depends what it is. If it *is* jukebox, then we might as well just
recommend that people use NFSv3 (NFSv2 is legacy anyway). Jukebox is
only used for slow media (tape, cd-exchangers,...), so it's not going
ever going to be a common case.

cheers,
  Trond




-------------------------------------------------------
This SF.Net email sponsored by: Parasoft
Error proof Web apps, automate testing & more.
Download & eval WebKing and get a free book.
www.parasoft.com/bulletproofapps1
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
