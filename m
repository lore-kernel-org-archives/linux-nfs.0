From: Wendy Cheng <wcheng@redhat.com>
Subject: [RFC] NLM lock failover admin interface
Date: Mon, 12 Jun 2006 01:25:43 -0400
Message-ID: <1150089943.26019.18.camel@localhost.localdomain>
Reply-To: linux clustering <linux-cluster@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-cluster@redhat.com
Return-path: <linux-cluster-bounces@redhat.com>
To: nfs@lists.sourceforge.net
List-Unsubscribe: <https://www.redhat.com/mailman/listinfo/linux-cluster>,
	<mailto:linux-cluster-request@redhat.com?subject=unsubscribe>
List-Archive: <https://www.redhat.com/archives/linux-cluster>
List-Post: <mailto:linux-cluster@redhat.com>
List-Help: <mailto:linux-cluster-request@redhat.com?subject=help>
List-Subscribe: <https://www.redhat.com/mailman/listinfo/linux-cluster>,
	<mailto:linux-cluster-request@redhat.com?subject=subscribe>
Sender: linux-cluster-bounces@redhat.com
Errors-To: linux-cluster-bounces@redhat.com
List-ID: <nfs.lists.sourceforge.net>

NFS v2/v3 active-active NLM lock failover has been an issue with our
cluster suite. With current implementation, it (cluster suite) is trying
to carry the workaround as much as it can with user mode scripts where,
upon failover, on taken-over server, it:

1. Tear down virtual IP.
2. Unexport the subject NFS export.
3. Signal lockd to drop the locks.
4. Un-mount filesystem if needed.

There are many other issues (such as /var/lib/nfs/statd/sm file, etc)
but this particular post is to further refine step 3 to avoid the 50
second global (default) grace period for all NFS exports; i.e., we would
like to be able to selectively drop locks (only) associated with the
requested exports without disrupting other NFS services. 

We've done some prototype (coding) works but would like to search for
community consensus on the admin interface if possible. We've tried out
the following:

1. /proc interface, say writing the fsid into a /proc directory entry
would end up dropping all NLM locks associated with the NFS export that
has fsid in its /etc/exports file.

2. Adding a new flag into "exportfs" command, say "h", such that

   "exportfs -uh *:/export_path"

would un-export the entry and drop the NLM locks associated with the
entry.

3. Add a new nfsctl by re-using a 2.4 kernel flag (NFSCTL_FOLOCKS) where
it takes:

   struct nfsctl_folocks {
        int           type;
        unsigned int  fsid;
        unsigned int  devno;
   }

as input argument. Depending on "type", the kernel call would drop the
locks associated with either the fsid, or devno. 

The core of the implementation is a new cloned version of
nlm_traverse_files() where it searches the "nlm_files" list one by one
to compare the fsid (or devno) based on nlm_file.f_handle field. A
helper function is also implemented to extract the fsid (or devno) from
f_handle.

The new function is planned to allow failover to abort if the file can't
be closed. We may also put the file locks back if abort occurs.

Would appreciate comments on the above admin interface. As soon as the
external interface can be finalized, the code will be submitted for
review.

-- Wendy
