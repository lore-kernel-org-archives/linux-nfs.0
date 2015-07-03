Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:33938 "EHLO
	ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755600AbbGCPAF (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 3 Jul 2015 11:00:05 -0400
Date: Fri, 3 Jul 2015 16:00:01 +0100
From: Al Viro <viro@ZenIV.linux.org.uk>
To: Andrey Ryabinin <a.ryabinin@samsung.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
        LKML <linux-kernel@vger.kernel.org>,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>,
        "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>,
        Eric Van Hensbergen <ericvh@gmail.com>, linux-nfs@vger.kernel.org
Subject: [PATCH] forgetting to cancel request in interrupted zero-copy 9P RPC
 (was Re: [git pull] vfs part 2)
Message-ID: <20150703150000.GS17109@ZenIV.linux.org.uk>
References: <CAPAsAGzZVy3-D4J1ZGsUZU4RRQ36NtprZg_Uvfi5=46=1_rpWA@mail.gmail.com>
 <20150702075932.GI17109@ZenIV.linux.org.uk>
 <CAPAsAGzJW1C-4rd9myZOsiA9dLp2d420PTePaguK=y2RWjrz2A@mail.gmail.com>
 <20150702082529.GJ17109@ZenIV.linux.org.uk>
 <20150702084208.GK17109@ZenIV.linux.org.uk>
 <55952C6D.50805@samsung.com>
 <20150702164332.GL17109@ZenIV.linux.org.uk>
 <20150702164926.GN17109@ZenIV.linux.org.uk>
 <55964593.1070507@samsung.com>
 <20150703094210.GR17109@ZenIV.linux.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20150703094210.GR17109@ZenIV.linux.org.uk>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Jul 03, 2015 at 10:42:10AM +0100, Al Viro wrote:

> AFAICS, we get occasional stray responses from somewhere.  And no, it doesn't
> seem to be related to flushes or to dropping chan->lock in req_done() (this
> run had been with chan->lock taken on the outside of the loop).
> 
> What I really don't understand is WTF is it playing with p9_tag_lookup() -
> it's stashing req->tc via virtqueue_add_sgs() opaque data argument, fetches
> it back in req_done(), then picks ->tag from it and uses p9_tag_lookup() to
> find req.  Why not simply pass req instead?  I had been wrong about that
> p9_tag_lookup() being able to return NULL, but why bother with it at all?


Got it.  What happens is that on zero-copy path a signal hitting in the
end of p9_virtio_zc_request() is treated as "it hadn't been sent, got
an error, fuck off and mark the tag ready for reuse".  No TFLUSH issued,
etc.  As the result, when reply finally *does* arrive (we had actually
sent the request), it plays hell on the entire thing - tag might very
well have been reused by then and an unrelated request sent with the
same tag.  Depending on the timing, results can get rather ugly.

There are still other bogosities found in this thread, and at the very
least we need to cope with genuine corrupted response from server, but
the patch below fixes the problem with stray responses here and stops the
"what do you mean, you'd written 4K?  I've only sent 30 bytes!" problems
here.  10 minutes of trinity running without triggering it, while without
that patch it triggers in 2-3 minutes.

Could you verify that the patch below deals with your setup as well?
If it does, I'm going to put it into tonight's pull request, after I get
some sleep...  Right now I'm about to crawl in direction of bed - 25 hours
of uptime is a bit too much... ;-/

diff --git a/net/9p/client.c b/net/9p/client.c
index 6f4c4c8..8c4941d 100644
--- a/net/9p/client.c
+++ b/net/9p/client.c
@@ -843,7 +843,8 @@ static struct p9_req_t *p9_client_zc_rpc(struct p9_client *c, int8_t type,
 	if (err < 0) {
 		if (err == -EIO)
 			c->status = Disconnected;
-		goto reterr;
+		if (err != -ERESTARTSYS)
+			goto reterr;
 	}
 	if (req->status == REQ_STATUS_ERROR) {
 		p9_debug(P9_DEBUG_ERROR, "req_status error %d\n", req->t_err);
@@ -1647,7 +1648,10 @@ p9_client_write(struct p9_fid *fid, u64 offset, struct iov_iter *from, int *err)
 		if (*err) {
 			trace_9p_protocol_dump(clnt, req->rc);
 			p9_free_req(clnt, req);
+			break;
 		}
+		if (rsize < count)
+			pr_err("mismatched reply [tag = %d]\n", req->tc->tag);
 
 		p9_debug(P9_DEBUG_9P, "<<< RWRITE count %d\n", count);
 
