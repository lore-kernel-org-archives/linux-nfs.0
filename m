From: Peter Staubach <staubach@redhat.com>
Subject: Re: [PATCH] make NFS client side WRITE more defensive
Date: Wed, 29 Jun 2005 16:36:07 -0400
Message-ID: <42C30637.1010705@redhat.com>
References: <42C2C7AC.5070405@redhat.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------060009060204080809040401"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from [10.3.1.92] (helo=sc8-sf-mx2-new.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DnjLe-00035v-7M
	for nfs@lists.sourceforge.net; Wed, 29 Jun 2005 13:39:54 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by sc8-sf-mx2-new.sourceforge.net with esmtp (Exim 4.44)
	id 1DnjLd-0003Py-7v
	for nfs@lists.sourceforge.net; Wed, 29 Jun 2005 13:39:54 -0700
Received: from int-mx1.corp.redhat.com (int-mx1.corp.redhat.com [172.16.52.254])
	by mx1.redhat.com (8.12.11/8.12.11) with ESMTP id j5TKdqot003429
	for <nfs@lists.sourceforge.net>; Wed, 29 Jun 2005 16:39:52 -0400
To: Peter Staubach <staubach@redhat.com>
In-Reply-To: <42C2C7AC.5070405@redhat.com>
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

This is a multi-part message in MIME format.
--------------060009060204080809040401
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Peter Staubach wrote:

> Hi.
>
> Attached are same changes to make the NFS client side WRITE processing 
> a little
> more defensive.  Currently, a response which indicates that the server 
> wrote
> more data than actually requested could cause bad things to happen.  
> Such a
> response could come from a broken or malicious server or from network 
> corruption
> that the normal checksumming fails to catch. 


Chuck Lever correctly pointed out that this patch did not address all of the
WRITE cases.  I hadn't incuded the direct I/O case.  The new, attached patch
should address it in addition to the sync and async cases already covered.

    Thanx...

       ps

--------------060009060204080809040401
Content-Type: text/plain;
 name="devel"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="devel"

--- ./fs/nfs/write.c.org	2005-06-27 16:20:02.000000000 -0400
+++ ./fs/nfs/write.c	2005-06-27 17:07:52.000000000 -0400
@@ -197,15 +197,21 @@ static int nfs_writepage_sync(struct nfs
 
 		result = NFS_PROTO(inode)->write(wdata);
 
-		if (result < 0) {
+		if (result <= 0) {
 			/* Must mark the page invalid after I/O error */
 			ClearPageUptodate(page);
 			goto io_error;
 		}
-		if (result < wdata->args.count)
-			printk(KERN_WARNING "NFS: short write, count=%u, result=%d\n",
-					wdata->args.count, result);
-
+		if (result > wdata->args.count) {
+			dprintk("NFS: faulty NFS server %s:"
+				" (requested = %u) != (result = %d)\n",
+				NFS_SERVER(inode)->hostname,
+				wdata->args.count, result);
+			/* Treat as I/O error */
+			ClearPageUptodate(page);
+			result = -EIO;
+			goto io_error;
+		}
 		wdata->args.offset += result;
 	        wdata->args.pgbase += result;
 		written += result;
@@ -1165,32 +1171,50 @@ void nfs_writeback_done(struct rpc_task 
 		}
 	}
 #endif
-	/* Is this a short write? */
-	if (task->tk_status >= 0 && resp->count < argp->count) {
+	if (task->tk_status >= 0 && resp->count != argp->count) {
 		static unsigned long    complain;
 
-		/* Has the server at least made some progress? */
-		if (resp->count != 0) {
-			/* Was this an NFSv2 write or an NFSv3 stable write? */
-			if (resp->verf->committed != NFS_UNSTABLE) {
-				/* Resend from where the server left off */
-				argp->offset += resp->count;
-				argp->pgbase += resp->count;
-				argp->count -= resp->count;
-			} else {
-				/* Resend as a stable write in order to avoid
-				 * headaches in the case of a server crash.
+		/* Is this a short write? */
+		if (resp->count < argp->count) {
+			/* Has the server at least made some progress? */
+			if (resp->count != 0) {
+				/*
+				 * Was this an NFSv2 write or an NFSv3
+				 * stable write?
 				 */
-				argp->stable = NFS_FILE_SYNC;
+				if (resp->verf->committed != NFS_UNSTABLE) {
+					/*
+					 * Resend from where the server
+					 * left off
+					 */
+					argp->offset += resp->count;
+					argp->pgbase += resp->count;
+					argp->count -= resp->count;
+				} else {
+					/*
+					 * Resend as a stable write in
+					 * order to avoid headaches in
+					 * the case of a server crash.
+					 */
+					argp->stable = NFS_FILE_SYNC;
+				}
+				rpc_restart_call(task);
+				return;
 			}
-			rpc_restart_call(task);
-			return;
-		}
-		if (time_before(complain, jiffies)) {
-			printk(KERN_WARNING
-			       "NFS: Server wrote zero bytes, expected %u.\n",
+			if (time_before(complain, jiffies)) {
+				dprintk("NFS: Server wrote zero bytes,"
+				       " expected %u.\n",
 					argp->count);
-			complain = jiffies + 300 * HZ;
+				complain = jiffies + 300 * HZ;
+			}
+		} else {
+		/* Or an oversized write? */
+			if (time_before(complain, jiffies)) {
+				dprintk("NFS: Server wrote more than requested,"
+				       " expected %u.\n",
+					argp->count);
+				complain = jiffies + 300 * HZ;
+			}
 		}
 		/* Can't do anything about it except throw an error. */
 		task->tk_status = -EIO;
--- ./fs/nfs/direct.c.org	2005-06-27 16:20:02.000000000 -0400
+++ ./fs/nfs/direct.c	2005-06-29 14:29:29.833983712 -0400
@@ -469,28 +469,39 @@ retry:
 		result = NFS_PROTO(inode)->write(wdata);
 		unlock_kernel();
 
-		if (result <= 0) {
-			if (tot_bytes > 0)
-				break;
-			goto out;
+		/*
+		 * If an error occurred or the server did not write any
+		 * data, then stop looping.  Any data already written
+		 * which needs to be committed will be committed.  If
+		 * data was written, then return the amount of data
+		 * written, else return either the error or zero indicating
+		 * that no data was written.
+		 */
+		if (result <= 0)
+			break;
+
+		/*
+		 * The response indicated that more data was written
+		 * then was sent.  Oops.  It is unknown what the server
+		 * might have done, so stop looping and handle this as
+		 * an error as described above.
+		 */
+		if (result > wdata->args.count) {
+			result = -EIO;
+			break;
 		}
 
 		if (tot_bytes == 0)
 			memcpy(&first_verf.verifier, &wdata->verf.verifier,
 						sizeof(first_verf.verifier));
 		if (wdata->verf.committed != NFS_FILE_SYNC) {
-			need_commit = 1;
 			if (memcmp(&first_verf.verifier, &wdata->verf.verifier,
-					sizeof(first_verf.verifier)));
+					sizeof(first_verf.verifier)) != 0)
 				goto sync_retry;
+			need_commit = 1;
 		}
 
 		tot_bytes += result;
-
-		/* in case of a short write: stop now, let the app recover */
-		if (result < wdata->args.count)
-			break;
-
 		wdata->args.offset += result;
 		wdata->args.pgbase += result;
 		curpage += wdata->args.pgbase >> PAGE_SHIFT;
@@ -514,9 +525,10 @@ retry:
 					 sizeof(first_verf.verifier)) != 0)
 			goto sync_retry;
 	}
-	result = tot_bytes;
 
-out:
+	if (tot_bytes)
+		result = tot_bytes;
+
 	nfs_end_data_update(inode);
 	nfs_writedata_free(wdata);
 	return result;

--------------060009060204080809040401--


-------------------------------------------------------
SF.Net email is sponsored by: Discover Easy Linux Migration Strategies
from IBM. Find simple to follow Roadmaps, straightforward articles,
informative Webcasts and more! Get everything you need to get up to
speed, fast. http://ads.osdn.com/?ad_id=7477&alloc_id=16492&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
