From: Neil Brown <neilb@cse.unsw.edu.au>
Subject: Re: max number of NFS mounts
Date: Tue, 8 Apr 2003 20:50:30 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <16018.43382.626936.933137@notabene.cse.unsw.edu.au>
References: <20030408035925.GB19119@marmot.cita.utoronto.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.28] ident=root)
	by sc8-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 192qgm-0005rU-00
	for <nfs@lists.sourceforge.net>; Tue, 08 Apr 2003 03:50:52 -0700
Received: From
	notabene.cse.unsw.edu.au ([129.94.242.45] == bartok.orchestra.cse.unsw.EDU.AU)
	(for <rjh@cita.utoronto.ca>) (for <nfs@lists.sourceforge.net>) By
	tone With Smtp ; Tue, 8 Apr 2003 20:50:46 +1000
To: Robin Humble <rjh@cita.utoronto.ca>
In-Reply-To: message from Robin Humble on Monday April 7
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

On Monday April 7, rjh@cita.utoronto.ca wrote:
> 
> Hi,
> 
> We have a large linux cluster with 256 backend nodes, 10 development
> nodes, plus a few other mounts/machines of various sorts.
> 
> When using autofs in an attempt to mount all backend disks at once we
> hit the 256 mounts limitation and only get to about 246 backend disks
> mounted - this is a pain :-/
> 
> so yes, your message (that I eventually found via Neil Brown) was most
> helpful and please add it to the FAQ and also into linux/Documentation/*
> somewhere.
>   http://sourceforge.net/mailarchive/message.php?msg_id=4215392

I think it isn't that hard to raise the limit.  The attached patch,
which is entirely untested, should increase it to 2560.

The issue is that a unique device number must be allocated for each
nfs mount, and the code will currently only allocate from the 256
device number with MAJOR number 0.  This patch allows it to also use
major numbers 238, 237, 236,.... which aren't used.

I don't think this patch would (or should) get into main-line, but it
ought to work.
> 
> also, can you guess whether 2.5/2.6 will lift the lame 256 mounts
> limit... ??

If the 32bit device number stuff really gets in (which is very
likely), then there should be no trouble raising the limit, though we
might need a better data structure to record "in-use" device numbers.


NeilBrown



diff ./fs/super.c~current~ ./fs/super.c
--- ./fs/super.c~current~	2003-04-08 20:36:25.000000000 +1000
+++ ./fs/super.c	2003-04-08 20:38:22.000000000 +1000
@@ -572,7 +572,7 @@ int do_remount_sb(struct super_block *sb
  * filesystems which don't use real block-devices.  -- jrs
  */
 
-enum {Max_anon = 256};
+enum {Max_anon = 2560};
 static unsigned long unnamed_dev_in_use[Max_anon/(8*sizeof(unsigned long))];
 static spinlock_t unnamed_dev_lock = SPIN_LOCK_UNLOCKED;/* protects the above */
 
@@ -643,6 +643,7 @@ retry:
 	set_bit(dev, unnamed_dev_in_use);
 	spin_unlock(&unnamed_dev_lock);
 
+	if (dev>=256) dev = (239*256+255)-dev;
 	s->s_dev = dev;
 	insert_super(s, type);
 	return s;


-------------------------------------------------------
This SF.net email is sponsored by: ValueWeb: 
Dedicated Hosting for just $79/mo with 500 GB of bandwidth! 
No other company gives more support or power for your dedicated server
http://click.atdmt.com/AFF/go/sdnxxaff00300020aff/direct/01/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
