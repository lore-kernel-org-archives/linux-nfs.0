From: Theodore Ts'o <tytso@mit.edu>
Subject: Re: [PATCH] better RPC statistics
Date: Tue, 8 Oct 2002 18:04:50 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20021008220450.GC9807@think.thunk.org>
References: <Pine.LNX.4.44.0210081517370.1273-100000@dexter.citi.umich.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linus Torvalds <torvalds@transmeta.com>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Linux NFS List <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from thunk.org ([140.239.227.29] helo=thunker.thunk.org)
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17z2TH-0002Eh-00
	for <nfs@lists.sourceforge.net>; Tue, 08 Oct 2002 15:04:56 -0700
To: Chuck Lever <cel@citi.umich.edu>
In-Reply-To: <Pine.LNX.4.44.0210081517370.1273-100000@dexter.citi.umich.edu>
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
List-Archive: <http://sourceforge.net/mailarchives/forum.php?forum=nfs>

On Tue, Oct 08, 2002 at 03:20:07PM -0400, Chuck Lever wrote:
> hi Linus-
> 
> this is the only patch i have that probably should be in 2.5 before 
> October 20.  the rest i will save until things calm down.
> 
> this patch, against 2.5.41, adds some new statistics in the RPC layer.  
> these are similar to stats kept in reference client implementations, and 
> are designed to help sysadmins track down NFS client issues more quickly.
> since this changes a "kernel interface" it should go in now.

It's not just "kernel interfaces" which should go in before October
20th.  

If we really want the feature freeze to be real, we really will need
to be hard-nosed about what we accept after the freeze date.  (Said he
who is frantically trying to finish up a last couple of ext2/3
features in before 2.6.)

So I'd encourage folks to at least submit patches before Oct. 20th
when they are ready, and not try to save stuff for after feature
freeze....

						- Ted


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
