From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: Re: [autofs] VFS: Busy inodes after unmount on 2 way SMP
Date: Tue, 30 Sep 2003 09:31:58 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <16249.34254.779135.990955@charged.uio.no>
References: <Pine.LNX.4.44.0309290757580.21173-100000@guppy.limebrokerage.com>
	<shsr81z8q73.fsf@charged.uio.no>
	<20030930125005.GI11571@suse.de>
Reply-To: trond.myklebust@fys.uio.no
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ion Badulescu <lists@news.cs.columbia.edu>,
    nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 1A4KcO-0000m4-00
	for <nfs@lists.sourceforge.net>; Tue, 30 Sep 2003 06:32:44 -0700
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.22)
	id 1A4KcO-00024o-0w
	for nfs@lists.sourceforge.net; Tue, 30 Sep 2003 06:32:44 -0700
To: Olaf Kirch <okir@suse.de>
In-Reply-To: <20030930125005.GI11571@suse.de>
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

>>>>> " " == Olaf Kirch <okir@suse.de> writes:

     > On Mon, Sep 29, 2003 at 10:22:40AM -0700, Trond Myklebust

    >> That said, I agree that a full fix would be preferable. I'm
    >> working on other projects right now, that's why I'm being slow
    >> about this issue (plus the fact that it's not exactly easy to
    >> reproduce). I'll get onto it soon...

     > I've had no luck reproducing it either in a controlled
     > environment.  However the bug is common enough to crash a few
     > of our build machines over a weekend...

     > I took your patch, Trond, and modified it a little to not crash
     > if the user ctrl-c's the unlink. Still not pretty - maybe it
     > should zap the cached attributes:

Alternatively, we should perhaps make fsync_super() sync out all dirty
inodes and readaheads, then wait on all pending RPC ops. That would be
cleaner, I think...

Cheers,
  Trond


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
