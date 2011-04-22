Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:5156 "EHLO
	daytona.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751746Ab1DVGWh (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 22 Apr 2011 02:22:37 -0400
Message-ID: <4DB11EA9.5080900@panasas.com>
Date: Fri, 22 Apr 2011 09:22:33 +0300
From: Benny Halevy <bhalevy@panasas.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
CC: linux-nfs@vger.kernel.org
Subject: Re: [RFC 01/27] pnfs: CB_NOTIFY_DEVICEID
References: <4DAF0DE1.6020609@panasas.com>	 <1303320368-20990-1-git-send-email-bhalevy@panasas.com> <1303328485.23206.13.camel@lade.trondhjem.org>
In-Reply-To: <1303328485.23206.13.camel@lade.trondhjem.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 2011-04-20 22:41, Trond Myklebust wrote:
> On Wed, 2011-04-20 at 20:26 +0300, Benny Halevy wrote:
>> From: Marc Eshel <eshel@almaden.ibm.com>
>> +struct cb_devicenotifyargs {
>> +	struct sockaddr			*addr;
> 
> No sockaddr_size parameter?
> 

Actually, it can be safely removed altogether.

>> +	int				 ndevs;
>> +	struct cb_devicenotifyitem	 devs[NFS4_DEV_NOTIFY_MAXENTRIES];
>> +};
> 
> Why can't we make this dynamic at this time?
> 

Will do.
How about the following patch?
(while at it I fixed the error codes in decode_devicenotify_args)

---
 fs/nfs/callback.h      |    5 +----
 fs/nfs/callback_proc.c |    1 +
 fs/nfs/callback_xdr.c  |   30 +++++++++++++++---------------
 3 files changed, 17 insertions(+), 19 deletions(-)

diff --git a/fs/nfs/callback.h b/fs/nfs/callback.h
index 892128f..b257383 100644
--- a/fs/nfs/callback.h
+++ b/fs/nfs/callback.h
@@ -175,12 +175,9 @@ struct cb_devicenotifyitem {
 	uint32_t		cbd_immediate;
 };

-/* XXX: Should be dynamic up to max compound size */
-#define NFS4_DEV_NOTIFY_MAXENTRIES 10
 struct cb_devicenotifyargs {
-	struct sockaddr			*addr;
 	int				 ndevs;
-	struct cb_devicenotifyitem	 devs[NFS4_DEV_NOTIFY_MAXENTRIES];
+	struct cb_devicenotifyitem	 *devs;
 };

 extern __be32 nfs4_callback_devicenotify(
diff --git a/fs/nfs/callback_proc.c b/fs/nfs/callback_proc.c
index 96f35f2..964c416 100644
--- a/fs/nfs/callback_proc.c
+++ b/fs/nfs/callback_proc.c
@@ -286,6 +286,7 @@ __be32 nfs4_callback_devicenotify(struct
cb_devicenotifyargs *args,
 	}

 out:
+	kfree(args->devs);
 	dprintk("%s: exit with status = %u\n",
 		__func__, res);
 	return cpu_to_be32(res);
diff --git a/fs/nfs/callback_xdr.c b/fs/nfs/callback_xdr.c
index 5ec2c12..c6c86a7 100644
--- a/fs/nfs/callback_xdr.c
+++ b/fs/nfs/callback_xdr.c
@@ -296,23 +296,20 @@ __be32 decode_devicenotify_args(struct svc_rqst
*rqstp,
 	int n, i;
 	args->ndevs = 0;

-	args->addr = svc_addr(rqstp);
-
 	/* Num of device notifications */
 	p = read_buf(xdr, sizeof(uint32_t));
 	if (unlikely(p == NULL)) {
-		status = htonl(NFS4ERR_RESOURCE);
+		status = htonl(NFS4ERR_BADXDR);
 		goto out;
 	}
 	n = ntohl(*p++);
 	if (n <= 0)
 		goto out;

-	/* XXX: need to possibly return error in this case */
-	if (n > NFS4_DEV_NOTIFY_MAXENTRIES) {
-		dprintk("%s: Processing (%d) notifications out of (%d)\n",
-			__func__, NFS4_DEV_NOTIFY_MAXENTRIES, n);
-		n = NFS4_DEV_NOTIFY_MAXENTRIES;
+	args->devs = kmalloc(n * sizeof(*args->devs), GFP_KERNEL);
+	if (!args->devs) {
+		status = htonl(NFS4ERR_DELAY);
+		goto out;
 	}

 	/* Decode each dev notification */
@@ -321,20 +318,20 @@ __be32 decode_devicenotify_args(struct svc_rqst
*rqstp,

 		p = read_buf(xdr, (4 * sizeof(uint32_t)) + NFS4_DEVICEID4_SIZE);
 		if (unlikely(p == NULL)) {
-			status = htonl(NFS4ERR_RESOURCE);
-			goto out;
+			status = htonl(NFS4ERR_BADXDR);
+			goto err;
 		}

 		tmp = ntohl(*p++);	/* bitmap size */
 		if (tmp != 1) {
 			status = htonl(NFS4ERR_INVAL);
-			goto out;
+			goto err;
 		}
 		dev->cbd_notify_type = ntohl(*p++);
 		if (dev->cbd_notify_type != NOTIFY_DEVICEID4_CHANGE &&
 		    dev->cbd_notify_type != NOTIFY_DEVICEID4_DELETE) {
 			status = htonl(NFS4ERR_INVAL);
-			goto out;
+			goto err;
 		}

 		tmp = ntohl(*p++);	/* opaque size */
@@ -343,7 +340,7 @@ __be32 decode_devicenotify_args(struct svc_rqst *rqstp,
 		    ((dev->cbd_notify_type == NOTIFY_DEVICEID4_DELETE) &&
 		     (tmp != NFS4_DEVICEID4_SIZE + 4))) {
 			status = htonl(NFS4ERR_INVAL);
-			goto out;
+			goto err;
 		}
 		dev->cbd_layout_type = ntohl(*p++);
 		memcpy(dev->cbd_dev_id.data, p, NFS4_DEVICEID4_SIZE);
@@ -352,8 +349,8 @@ __be32 decode_devicenotify_args(struct svc_rqst *rqstp,
 		if (dev->cbd_layout_type == NOTIFY_DEVICEID4_CHANGE) {
 			p = read_buf(xdr, sizeof(uint32_t));
 			if (unlikely(p == NULL)) {
-				status = htonl(NFS4ERR_DELAY);
-				goto out;
+				status = htonl(NFS4ERR_BADXDR);
+				goto err;
 			}
 			dev->cbd_immediate = ntohl(*p++);
 		} else {
@@ -370,6 +367,9 @@ out:
 	dprintk("%s: status %d ndevs %d\n",
 		__func__, ntohl(status), args->ndevs);
 	return status;
+err:
+	kfree(args->devs);
+	goto out;
 }

 static __be32 decode_sessionid(struct xdr_stream *xdr,
-- 
1.7.3.4



