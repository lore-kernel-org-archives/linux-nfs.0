From: Ion Badulescu <lists@cs.columbia.edu>
Subject: Re: VFS: Busy inodes after unmount on 2 way SMP
Date: Fri, 12 Sep 2003 20:16:27 -0400 (EDT)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.LNX.4.44.0309122013380.9830-100000@moisil.badula.org>
References: <3F62601A.5000105@intel.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: nfs@lists.sourceforge.net, <autofs@linux.kernel.org>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 19xy6I-0004qF-00
	for <nfs@lists.sourceforge.net>; Fri, 12 Sep 2003 17:17:18 -0700
Received: from ool-43524450.dyn.optonline.net ([67.82.68.80] helo=buggy.badula.org)
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.22)
	id 19xy6H-0007u2-IJ
	for nfs@lists.sourceforge.net; Fri, 12 Sep 2003 17:17:17 -0700
To: Arun Sharma <arun.sharma@intel.com>
In-Reply-To: <3F62601A.5000105@intel.com>
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

On Fri, 12 Sep 2003, Arun Sharma wrote:

> Ion Badulescu wrote:
> > 
> > I don't know if it's the same issue, but I've seen it many many times 
> > while testing amd's autofs functionality. It occurs when a non-empty 
> > autofs filesystem is unmounted, e.g. if it has some leftover 
> > subdirectories from previous mounts. Therefore I'd say it's quite 
> > clearly an autofs issue, at least in my case.
> 
> Do you have a case that can deterministically reproduce the issue ? 

Oh yeah, easily. Kill the automounter while some things are mounted,
unmount everything by hand but do not rmdir the mountpoints. When you
unmount the autofs filesystem itself, you will get the self destruct
message.

> Everytime I've seen it, it's during an unmount by /usr/sbin/automount
> after the mount has expired. It's usually coupled with a temporarily
> unreachable NFS server.

So maybe this is a different issue than the one I am describing...

Ion

-- 
  It is better to keep your mouth shut and be thought a fool,
            than to open it and remove all doubt.



-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
