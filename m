From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: Re: [autofs] VFS: Busy inodes after unmount on 2 way SMP
Date: 29 Sep 2003 10:22:40 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <shsr81z8q73.fsf@charged.uio.no>
References: <Pine.LNX.4.44.0309290757580.21173-100000@guppy.limebrokerage.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 1A4JIE-0002iM-00
	for <nfs@lists.sourceforge.net>; Tue, 30 Sep 2003 05:07:50 -0700
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.22)
	id 1A4JID-000382-7A
	for nfs@lists.sourceforge.net; Tue, 30 Sep 2003 05:07:49 -0700
To: Ion Badulescu <lists@news.cs.columbia.edu>
In-Reply-To: <Pine.LNX.4.44.0309290757580.21173-100000@guppy.limebrokerage.com>
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

>>>>> " " == Ion Badulescu <lists@news.cs.columbia.edu> writes:

    >> People expect the "intr" flag to work if they set it.

     > People also expect the supported "intr" flag not to cause
     > security problems and would gladly take an unkillable process
     > over a kernel oops...


You'd have to be extremely unlucky to kill the process and hit the
window for the Oops. I defy you to come up with an exploit for it.

That said, I agree that a full fix would be preferable. I'm working on
other projects right now, that's why I'm being slow about this issue
(plus the fact that it's not exactly easy to reproduce). I'll get onto
it soon...

Cheers,
  Trond


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
