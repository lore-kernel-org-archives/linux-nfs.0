From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [patch] flock/fcntl bug
Date: Wed, 15 Dec 2004 19:34:55 -0500
Message-ID: <1103157295.1236.70.camel@lade.trondhjem.org>
References: <OF89CDCE7F.4F36F059-ON88256F6B.00820187-88256F6B.008315EF@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CejcO-0008E5-11
	for nfs@lists.sourceforge.net; Wed, 15 Dec 2004 16:35:44 -0800
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.41)
	id 1CejcN-0003OI-2L
	for nfs@lists.sourceforge.net; Wed, 15 Dec 2004 16:35:43 -0800
To: Marc Eshel <eshel@almaden.ibm.com>
In-Reply-To: <OF89CDCE7F.4F36F059-ON88256F6B.00820187-88256F6B.008315EF@us.ibm.com>
Sender: nfs-admin@lists.sourceforge.net
Errors-To: nfs-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

on den 15.12.2004 Klokka 15:51 (-0800) skreiv Marc Eshel:

> > Right. Which may now be a bug...
> 
> So how would you fix it? Call the filesystem to unlock what? If you have no
> information on what is locked how can you unlock it, and having an extra
> call to the filesystem (that can be remote for NFS) when there is no lock
> held is very wasteful.

So please tell me why I should be forced to keep all this information:

struct file_lock {
        struct file_lock *fl_next;      /* singly linked list for this
inode  */        struct list_head fl_link;       /* doubly linked list
of all locks */
        struct list_head fl_block;      /* circular list of blocked
processes */        fl_owner_t fl_owner;
        unsigned int fl_pid;
        wait_queue_head_t fl_wait;
        struct file *fl_file;
        unsigned char fl_flags;
        unsigned char fl_type;
        loff_t fl_start;
        loff_t fl_end;

        struct fasync_struct *  fl_fasync; /* for lease break
notifications */
        unsigned long fl_break_time;    /* for nonblocking lease breaks
*/

        struct file_lock_operations *fl_ops;    /* Callbacks for
filesystems */
        struct lock_manager_operations *fl_lmops;       /* Callbacks for
lockmanagers */
        union {
                struct nfs_lock_info    nfs_fl;
        } fl_u;
};

for each and every byte range lock if all I'm interested in is deciding
whether or not one lock held by me exists? A minimum implementation for
that could be done within the filesystem as

struct foo {
	fl_owner_t fl_owner;
	struct foo *next;
};

If you don't believe me, look at your own patch. AFAICS the above is the
only information you are actually using.

> > And? The fact that lockd uses inode->i_flock does not mean that the
> > filesystem has to.
> 
> That is the only why that lockd knows what to clean up when it is
> terminated

No! lockd keeps its own books entirely. It uses the VFS bookkeeping for
convenience, but it in no way relies on the filesystem to use the same
bookkeeping.

> > What is the point of forcing it to do that if it can do its own
> > bookkeeping? Why should the VFS need to care?
> 
> It would be nice if it didn't have to care but the fact is that right now
> there is dependency on the lock state to be in the VFS too for correct
> operation.

Then fix the VFS to do the right thing. Move the decision about whether
or not to do an RPC call or whatever into the filesystem where it
belongs.

Cheers,
  Trond

-- 
Trond Myklebust <trond.myklebust@fys.uio.no>



-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now. 
http://productguide.itmanagersjournal.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
