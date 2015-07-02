Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:52975 "EHLO
	ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753883AbbGBQta (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 2 Jul 2015 12:49:30 -0400
Date: Thu, 2 Jul 2015 17:49:26 +0100
From: Al Viro <viro@ZenIV.linux.org.uk>
To: Andrey Ryabinin <a.ryabinin@samsung.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
        LKML <linux-kernel@vger.kernel.org>,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>,
        "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>,
        Eric Van Hensbergen <ericvh@gmail.com>, linux-nfs@vger.kernel.org
Subject: Re: running out of tags in 9P (was Re: [git pull] vfs part 2)
Message-ID: <20150702164926.GN17109@ZenIV.linux.org.uk>
References: <20150701184408.GF17109@ZenIV.linux.org.uk>
 <20150702032042.GA32613@ZenIV.linux.org.uk>
 <20150702041046.GG17109@ZenIV.linux.org.uk>
 <CAPAsAGzZVy3-D4J1ZGsUZU4RRQ36NtprZg_Uvfi5=46=1_rpWA@mail.gmail.com>
 <20150702075932.GI17109@ZenIV.linux.org.uk>
 <CAPAsAGzJW1C-4rd9myZOsiA9dLp2d420PTePaguK=y2RWjrz2A@mail.gmail.com>
 <20150702082529.GJ17109@ZenIV.linux.org.uk>
 <20150702084208.GK17109@ZenIV.linux.org.uk>
 <55952C6D.50805@samsung.com>
 <20150702164332.GL17109@ZenIV.linux.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20150702164332.GL17109@ZenIV.linux.org.uk>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Jul 02, 2015 at 05:43:32PM +0100, Al Viro wrote:
>  	req->tc->tag = tag-1;
> +	if (req->status != REQ_STATUS_IDLE)
> +		pr_err("using tag %d with odd status (%d)", tag, req->status);

Should be tag - 1 here, actually.

diff --git a/net/9p/client.c b/net/9p/client.c
index 6f4c4c8..9719886 100644
--- a/net/9p/client.c
+++ b/net/9p/client.c
@@ -248,6 +248,9 @@ p9_tag_alloc(struct p9_client *c, u16 tag, unsigned int max_size)
 		/* check again since original check was outside of lock */
 		while (tag >= c->max_tag) {
 			row = (tag / P9_ROW_MAXTAG);
+
+			WARN_ON_ONCE(c->reqs[row]);	// are we about to leak?
+
 			c->reqs[row] = kcalloc(P9_ROW_MAXTAG,
 					sizeof(struct p9_req_t), GFP_ATOMIC);
 
@@ -286,6 +289,8 @@ p9_tag_alloc(struct p9_client *c, u16 tag, unsigned int max_size)
 	p9pdu_reset(req->rc);
 
 	req->tc->tag = tag-1;
+	if (req->status != REQ_STATUS_IDLE)
+		pr_err("using tag %d with odd status (%d)", tag - 1, req->status);
 	req->status = REQ_STATUS_ALLOC;
 
 	return req;
@@ -425,6 +430,8 @@ void p9_client_cb(struct p9_client *c, struct p9_req_t *req, int status)
 	 * the other thread wakes up will indeed be seen by the waiting side.
 	 */
 	smp_wmb();
+	if (req->status == REQ_STATUS_IDLE)
+		pr_err("late delivery, tag %d already freed", req->tc->tag);
 	req->status = status;
 
 	wake_up(req->wq);
@@ -693,6 +700,10 @@ static struct p9_req_t *p9_client_prepare_req(struct p9_client *c,
 		tag = p9_idpool_get(c->tagpool);
 		if (tag < 0)
 			return ERR_PTR(-ENOMEM);
+		if (WARN_ON_ONCE(tag != (u16)tag)) {	// wrapped around?
+			p9_idpool_put(tag, c->tagpool);
+			return ERR_PTR(-ENOMEM);
+		}
 	}
 
 	req = p9_tag_alloc(c, tag, req_size);
@@ -1647,7 +1658,10 @@ p9_client_write(struct p9_fid *fid, u64 offset, struct iov_iter *from, int *err)
 		if (*err) {
 			trace_9p_protocol_dump(clnt, req->rc);
 			p9_free_req(clnt, req);
+			break;
 		}
+		if (rsize < count)
+			pr_err("mismatched reply [tag = %d]\n", req->tc->tag);
 
 		p9_debug(P9_DEBUG_9P, "<<< RWRITE count %d\n", count);
 
