From: Olaf Kirch <okir@suse.de>
Subject: Re: Re: [autofs] VFS: Busy inodes after unmount on 2 way SMP
Date: Thu, 18 Sep 2003 10:26:58 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20030918082658.GA24464@suse.de>
References: <Pine.LNX.4.33.0309171251290.25153-100000@wombat.indigo.net.au> <3F689E40.6090802@intel.com> <3F68C6EB.2080706@zytor.com> <20030917210023.GA15099@suse.de> <shsd6dyabju.fsf@charged.uio.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Cc: Olaf Hering <olh@suse.de>, "H. Peter Anvin" <hpa@zytor.com>,
	Arun Sharma <arun.sharma@intel.com>, autofs@linux.kernel.org,
	nfs@lists.sourceforge.net, Ian Kent <raven@themaw.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 19zu7z-0004OJ-00
	for <nfs@lists.sourceforge.net>; Thu, 18 Sep 2003 01:27:03 -0700
Received: from ns.suse.de ([195.135.220.2] helo=Cantor.suse.de)
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.22)
	id 19zu7y-0006gR-KT
	for nfs@lists.sourceforge.net; Thu, 18 Sep 2003 01:27:02 -0700
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <shsd6dyabju.fsf@charged.uio.no>
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

On Thu, Sep 18, 2003 at 01:52:05AM -0400, Trond Myklebust wrote:
> ...and is indeed wrong... It does the exact opposite of what
> sillydelete should do. Instead of causing the last application that
> closes the file to perform the sillydelete, you are asking the *first*
> application that closes it to do so.

I know. I was not claiming it's perfectly right, what I'm interested
in whether it cures the oopses we're seeing. If that were true, one
could still look for The Right Solution...

> Sillydelete *has* to be tied to dentries. Not files, and not
> inodes. It is purely a namespace operation...
> 
> So exactly what are you trying to do, and why?

We have seen several reports of autofs+nfs leading to oopses, preceded by
"Busy inodes on umount, self-destruct in 5 seconds".
It's somewhat hard to reproduce, so I'm currently trying to come up with
possible patches by looking at the source.

You cannot umount if the vfsmount mnt_count is != 2.  So either something
hosed the mnt_count completely (by doing too many mntput() calls for
instance), or something holds dentry references without bumping mnt_count
along with it. Do you agree?

The only place in the nfs client code that actually does a dget is
the sillydelete stuff in unlink.c. So my idea in generating this patch
was that the nfs_complete_unlink was happening too late, when the file
is already closed and the vfsmount reference is gone.

It's a long shot admittedly...

Have a nice day,
Olaf
-- 
Olaf Kirch     |  Anyone who has had to work with X.509 has probably
okir@suse.de   |  experienced what can best be described as
---------------+  ISO water torture. -- Peter Gutmann


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
