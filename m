Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:56487 "EHLO
	daytona.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754665Ab1BWSnM (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 23 Feb 2011 13:43:12 -0500
Message-ID: <4D655541.4020200@panasas.com>
Date: Wed, 23 Feb 2011 10:43:13 -0800
From: Benny Halevy <bhalevy@panasas.com>
To: "J. Bruce Fields" <bfields@redhat.com>
CC: linux-nfs@vger.kernel.org
Subject: Re: [PATCH] NFSD: fix decode_cb_sequence4resok
References: <1298414602-17029-1-git-send-email-bhalevy@panasas.com> <EEB9D74B-D547-4C43-AC8B-B8B58EBD9A54@oracle.com> <4D653F12.8090101@panasas.com> <20110223172957.GA6238@pad.home.fieldses.org> <4D654CD7.3020000@panasas.com>
In-Reply-To: <4D654CD7.3020000@panasas.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 2011-02-23 10:07, Benny Halevy wrote:
> On 2011-02-23 09:29, J. Bruce Fields wrote:
>> On Wed, Feb 23, 2011 at 09:08:34AM -0800, Benny Halevy wrote:
>>> On 2011-02-23 08:48, Chuck Lever wrote:
>>>>
>>>> On Feb 22, 2011, at 2:43 PM, Benny Halevy wrote:
>>>>
>>>>> Fix bug introduced in patch
>>>>> 85a56480 NFSD: Update XDR decoders in NFSv4 callback client
>>>>>
>>>>> Although decode_cb_sequence4resok ignores highest slotid and target highest slotid
>>>>> it must account for their space in their xdr stream when calling xdr_inline_decode
>>>>
>>>> The real problem is that decoding for the next operation in the compound will start too early in the buffer, because we didn't account for the ignored 8 bytes here, yes?
>>>
>>> Right on the spot.
>>
>> So actually I guess there is another bug here, which is a subset of
>>
>> 	http://wiki.linux-nfs.org/wiki/index.php/Server_4.0_and_4.1_issues#Callback_error_handling
>>
>> The server should be setting the appropriate sequence flag when it
>> (rightly or wrongly) things that a cb reply is garbage (not sure which
>> flag off the top of my head), and pynfs should be insisting that the
>> flag be set on any further sequence flags.
>>
>> --b.
> 
>    SEQ4_STATUS_BACKCHANNEL_FAULT
>       The server has encountered an unrecoverable fault with the
>       backchannel (e.g., it has lost track of the sequence ID for a slot
>       in the backchannel).  The client MUST stop sending more requests
>       on the session's fore channel, wait for all outstanding requests
>       to complete on the fore and back channel, and then destroy the
>       session.
> 
> Right?
> --

How about this patch?

>From c5b856eaab1e17f3d67b6fd0964d0803318ec342 Mon Sep 17 00:00:00 2001
From: Benny Halevy <bhalevy@panasas.com>
Date: Wed, 23 Feb 2011 10:38:19 -0800
Subject: [PATCH] nfsd41: use SEQ4_STATUS_BACKCHANNEL_FAULT when cb_sequence is invalid

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfsd/nfs4callback.c |   10 ++++++++++
 fs/nfsd/nfs4state.c    |    8 +++++++-
 fs/nfsd/state.h        |    1 +
 3 files changed, 18 insertions(+), 1 deletions(-)

diff --git a/fs/nfsd/nfs4callback.c b/fs/nfsd/nfs4callback.c
index d046bdb..b914fb1 100644
--- a/fs/nfsd/nfs4callback.c
+++ b/fs/nfsd/nfs4callback.c
@@ -39,6 +39,8 @@
 
 #define NFSDDBG_FACILITY                NFSDDBG_PROC
 
+static void nfsd4_mark_cb_fault(struct nfs4_client *, int reason);
+
 #define NFSPROC4_CB_NULL 0
 #define NFSPROC4_CB_COMPOUND 1
 
@@ -620,6 +622,8 @@ static int decode_cb_sequence4resok(struct xdr_stream *xdr,
 	 */
 	status = 0;
 out:
+	if (status)
+		nfsd4_mark_cb_fault(cb->cb_clp, status);
 	return status;
 out_overflow:
 	print_overflow_msg(__func__, xdr);
@@ -935,6 +939,12 @@ static void nfsd4_mark_cb_down(struct nfs4_client *clp, int reason)
 	warn_no_callback_path(clp, reason);
 }
 
+static void nfsd4_mark_cb_fault(struct nfs4_client *clp, int reason)
+{
+	clp->cl_cb_state = NFSD4_CB_FAULT;
+	warn_no_callback_path(clp, reason);
+}
+
 static void nfsd4_cb_probe_done(struct rpc_task *task, void *calldata)
 {
 	struct nfs4_client *clp = container_of(calldata, struct nfs4_client, cl_cb_null);
diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index e8df39f..2188c16 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -1856,8 +1856,14 @@ out:
 
 		nfsd4_get_session(cstate->session);
 		atomic_inc(&clp->cl_refcount);
-		if (clp->cl_cb_state == NFSD4_CB_DOWN)
+		switch (clp->cl_cb_state) {
+		case NFSD4_CB_DOWN:
 			seq->status_flags |= SEQ4_STATUS_CB_PATH_DOWN;
+			break;
+		case NFSD4_CB_FAULT:
+			seq->status_flags |= SEQ4_STATUS_BACKCHANNEL_FAULT;
+			break;
+		}
 	}
 	kfree(conn);
 	spin_unlock(&client_lock);
diff --git a/fs/nfsd/state.h b/fs/nfsd/state.h
index c934e1c..95ddf7a 100644
--- a/fs/nfsd/state.h
+++ b/fs/nfsd/state.h
@@ -235,6 +235,7 @@ struct nfs4_client {
 #define NFSD4_CB_UP		0
 #define NFSD4_CB_UNKNOWN	1
 #define NFSD4_CB_DOWN		2
+#define NFSD4_CB_FAULT		3
 	int			cl_cb_state;
 	struct nfsd4_callback	cl_cb_null;
 	struct nfsd4_session	*cl_cb_session;
-- 
1.7.3.4

