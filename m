From: Wendy Cheng <wcheng@redhat.com>
Subject: Re: [NFS] [RFC] NLM lock failover admin interface
Date: Mon, 12 Jun 2006 11:44:55 -0400
Message-ID: <448D8BF7.7010105@redhat.com>
References: <1150089943.26019.18.camel@localhost.localdomain>
	<20060612150053.GC31596@fieldses.org>
Reply-To: linux clustering <linux-cluster@redhat.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="------------070400020506070406000205"
Cc: nfs@lists.sourceforge.net,
	linux clustering <linux-cluster@redhat.com>
Return-path: <linux-cluster-bounces@redhat.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
In-Reply-To: <20060612150053.GC31596@fieldses.org>
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

This is a multi-part message in MIME format.
--------------070400020506070406000205
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

J. Bruce Fields wrote:

>On Mon, Jun 12, 2006 at 01:25:43AM -0400, Wendy Cheng wrote:
>  
>
>>2. Adding a new flag into "exportfs" command, say "h", such that
>>
>>   "exportfs -uh *:/export_path"
>>
>>would un-export the entry and drop the NLM locks associated with the
>>entry.
>>    
>>
>
>What does the kernel interface end up looking like in that case?
>
>  
>
Happy to see this new exportfs command gets positive response - it was 
our original pick too.

Uploaded is part of a draft version of 2.4 base kernel patch - we're 
cleaning up 2.6 patches at this moment. It basically adds a new export 
flag (NFSEXP_FOLOCK - note that ex_flags is an int but is currently only 
defined up to 16 bits) so nfs-util and kernel can communicate.

The nice thing about this approach is the recovery part - the take-over 
server can use the counter part command to export and set grace period 
for one particular interface within the same system call.

-- Wendy

--------------070400020506070406000205
Content-Type: text/plain;
 name="gfs_nlm.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="gfs_nlm.patch"

--- linux-2.4.21-43.EL/fs/nfsd/export.c	2006-05-14 17:16:21.000000000 -0400
+++ linux/fs/nfsd/export.c	2006-05-29 02:13:29.000000000 -0400
@@ -388,6 +388,10 @@ exp_unexport(struct nfsctl_export *nxp)
 			exp_do_unexport(exp);
 			err = 0;
 		}
+		if (nxp->ex_flags & NFSEXP_FOLOCK) {
+			dprintk("exp_unexport: nfsd_lockd_unexport called\n");
+			nfsd_lockd_unexport(clp);
+		}
 	}
 
 	exp_unlock();
--- linux-2.4.21-43.EL/include/linux/nfsd/export.h	2006-05-14 17:23:57.000000000 -0400
+++ linux/include/linux/nfsd/export.h	2006-05-29 02:12:07.000000000 -0400
@@ -42,7 +42,7 @@
 #define NFSEXP_FSID			0x2000
 #define NFSEXP_NOACL			0x8000	/* turn off acl support */
 #define NFSEXP_ALLFLAGS		0xFFFF
-
+#define NFSEXP_FOLOCK			0x00010000	/* NLM lock failover */
 
 #ifdef __KERNEL__
 

--------------070400020506070406000205
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline


--------------070400020506070406000205--
