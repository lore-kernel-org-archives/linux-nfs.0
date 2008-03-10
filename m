From: Jeff Layton <jlayton@redhat.com>
Subject: [PATCH 0/2] NFS: reduce false cache invalidations due to our own writes
Date: Mon, 10 Mar 2008 13:08:44 -0400
Message-ID: <1205168926-14373-1-git-send-email-jlayton@redhat.com>
Cc: linux-nfs@vger.kernel.org
To: Trond.Myklebust@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:35063 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751185AbYCJRJD (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 10 Mar 2008 13:09:03 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

We've had a couple of customers complain about a performance regression
in a newer kernel on one of our older products. After some work we've
tracked it down to the fact that while fixing some cache consistency
problems, we erred on the side of too many cache invalidations. The
client is being too aggressive about invalidating its caches...

We have a patch in mainline kernels that adds the
nfs_post_op_update_inode_force_wcc() function to fake pre_op_attrs on
write operations. This works fairly well when the server doesn't return
pre_op_attrs. What I've found though is that when servers do return
pre_op_attrs on write calls, that they often return to the client poorly
ordered. This fools the client into thinking that there are other
writers on the file, even though it's the only one.

The following two patches attempt to fix this by:

1) faking pre_op_attrs on writes even when the server has actually
   returned a valid set

2) not allowing post_op_attrs to update mtimes backward when we are
   faking pre_op_attrs

I've tested this for performance with a simple iozone test on NFSv3. On
the client, mounting an older NetApp server, I'm running:

     # time /opt/iozone/bin/iozone -ac -g 64M

Without these patches:

real    46m6.959s
user    0m1.509s
sys     23m40.880s

Client nfs v3:
null         getattr      setattr      lookup       access       readlink     
0         0% 1867      0% 198       0% 199       0% 319       0% 0         0% 
read         write        create       mkdir        symlink      mknod        
83232    29% 195633   69% 198       0% 0         0% 0         0% 0         0% 
remove       rmdir        rename       link         readdir      readdirplus  
198       0% 0         0% 0         0% 0         0% 0         0% 2         0% 
fsstat       fsinfo       pathconf     commit       
0         0% 2         0% 0         0% 0         0% 


...with these patches:

real    33m57.375s
user    0m1.471s
sys     12m59.619s

Client nfs v3:
null         getattr      setattr      lookup       access       readlink     
0         0% 1802      0% 198       0% 201       0% 206       0% 0         0% 
read         write        create       mkdir        symlink      mknod        
0         0% 195836   98% 198       0% 0         0% 0         0% 0         0% 
remove       rmdir        rename       link         readdir      readdirplus  
198       0% 0         0% 0         0% 0         0% 0         0% 0         0% 
fsstat       fsinfo       pathconf     commit       
0         0% 2         0% 0         0% 0         0% 


...no read calls on the second set, indicating that the patches drop
the number of cache invalidations to 0. Before that, reads accounted
for 29% of the calls and added over 12 mins to the run time.

I've also done a bit of light regression testing and haven't noticed
any major problems.

I suppose that this technically violates the RFC (esp patch 1), but
given that we're already faking pre_op_attrs when we don't have them,
is there any real harm in always doing this?

Thoughts?

Signed-off-by: Jeff Layton <jlayton@redhat.com>

