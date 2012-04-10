Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:41100 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757353Ab2DJV4f (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 10 Apr 2012 17:56:35 -0400
Date: Tue, 10 Apr 2012 17:56:34 -0400
To: Kevin Coffman <kwc@umich.edu>
Cc: NFS list <linux-nfs@vger.kernel.org>, Steve Dickson <SteveD@redhat.com>
Subject: Re: RFC: Handling GSS rotated data
Message-ID: <20120410215633.GL18465@fieldses.org>
References: <CAKnQG+dVhQ3JSXJnQihzs0FnS_aeyUKftDX7j7X6iJTjRGMzPQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <CAKnQG+dVhQ3JSXJnQihzs0FnS_aeyUKftDX7j7X6iJTjRGMzPQ@mail.gmail.com>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Apr 04, 2012 at 06:28:47PM -0400, Kevin Coffman wrote:
> This bug points out a deficiency in the GSS code previously added to the kernel:
> 
> https://bugzilla.redhat.com/show_bug.cgi?id=796992
> 
> The spec (RFC 4121 section 4.2.5) says, "The receiver MUST be able to
> interpret all possible rotation count values, including rotation
> counts greater than the length of the token."  Note that an
> implementation is never required to send rotated data.  However it is
> required to be able to handle receiving rotated data.  Windows is the
> only implementation that I am aware of that currently sends tokens
> with rotated data.
> 
> Attached is a patch (with way too much debugging) to handle the
> rotated data we have seen from Microsoft clients.  Admittedly, it does
> not handle all cases, which is required to be fully compliant with the
> spec.  I will not have the time to devote to making it fully
> compliant.  I submit this patch as an RFC and for someone else to
> complete!  Also note that I may have over-complicating things!!

Thanks!

But I'm not going to agree to implementing another subset of the
cases--we already fell into that trap once, let's not do it again.

Even if it means we have to do something slow and stupid as the first
pass, I'd rather have something complete....

--b.

diff --git a/net/sunrpc/auth_gss/gss_krb5_wrap.c b/net/sunrpc/auth_gss/gss_krb5_wrap.c
index 2763e3e..b824067 100644
--- a/net/sunrpc/auth_gss/gss_krb5_wrap.c
+++ b/net/sunrpc/auth_gss/gss_krb5_wrap.c
@@ -384,7 +384,6 @@ gss_unwrap_kerberos_v1(struct krb5_ctx *kctx, int offset, struct xdr_buf *buf)
  * We cannot currently handle tokens with rotated data.  We need a
  * generalized routine to rotate the data in place.  It is anticipated
  * that we won't encounter rotated data in the general case.
- */
 static u32
 rotate_left(struct krb5_ctx *kctx, u32 offset, struct xdr_buf *buf, u16 rrc)
 {
@@ -397,6 +396,139 @@ rotate_left(struct krb5_ctx *kctx, u32 offset, struct xdr_buf *buf, u16 rrc)
 		"rrc %u, realrrc %u\n", __func__, rrc, realrrc);
 	return 1;
 }
+ */
+
+#include <linux/ctype.h>
+void print_xdrbuf(const char *msg, struct xdr_buf *x);
+void print_xdrbuf_data(const char *msg, struct xdr_buf *x, unsigned int offset);
+
+#define LOCAL_BUF_LEN 32
+
+static u32
+rotate_left(struct krb5_ctx *kctx, u32 offset, struct xdr_buf *buf, u16 rrc)
+{
+	unsigned int realhead, realpage, realtail;
+	unsigned int remainder;
+	unsigned int rot_len = buf->len - offset - 16;
+	unsigned int realrrc = rrc % rot_len;
+	struct kvec *head, *tail;
+	void *headstart;    /* start of data past rpc header */
+	u32 err;
+
+	printk("%s: rrc %u, buf->len %u, offset %u, rot_len %u, realrrc %u\n",
+		__func__, rrc, buf->len, offset, rot_len, realrrc);
+	print_xdrbuf("in rotate_left", buf);
+	print_xdrbuf_data("BEFORE: ", buf, offset);
+
+	if (realrrc == 0)
+		return 0;
+
+	/*
+	 * At the time this function is called, the only length
+	 * values we can absolutely trust are buf->len (the length
+	 * of data actually read off the network) and buf->buflen
+	 * (the total available buffer space).
+	 *
+	 * The head, tail, and page lengths are the available
+	 * buffer space for each, not how much data is actually
+	 * available in each.  We know that data is read to fill
+	 * up the head, then page data, and then tail; so we can
+	 * calculate the *real* lengths of each.
+	 */
+	realhead = realpage = realtail = 0;
+	remainder = buf->len;
+	head = &buf->head[0];
+	tail = &buf->tail[0];
+
+	if (remainder) {
+		realhead = min_t(unsigned int, buf->len, head->iov_len);
+		remainder -= realhead;
+	}
+	if (remainder) {
+		realpage = min_t(unsigned int, remainder, buf->page_len);
+		remainder -= realpage;
+	}
+	if (remainder) {
+		realtail = min_t(unsigned int, remainder, tail->iov_len);
+		remainder -= realtail;
+	}
+	BUG_ON(remainder);
+	printk("%s: realhead %u, realpage %u, realtail %u\n",
+		__func__, realhead, realpage, realtail);
+
+	headstart = head->iov_base + offset + 16;
+
+	if (realpage == 0 && realtail == 0) {
+		/*
+		 * All the data is in the head.  Therefore all
+		 * the data to be moved is in the head
+		 */
+		char localbuf[LOCAL_BUF_LEN];
+		unsigned int amtleft = realrrc;
+		unsigned int thismove;
+		printk("%s: We are lucky! (moving %u within head)\n",
+			__func__, realrrc);
+		while (amtleft != 0) {
+			thismove = min_t(unsigned int, amtleft, LOCAL_BUF_LEN);
+			memcpy(localbuf, headstart, thismove);
+			memmove(headstart, headstart + thismove,
+				realhead - offset - 16 - thismove);
+			memcpy(head->iov_base + realhead - thismove,
+				localbuf, thismove);
+			amtleft -= thismove;
+		}
+	} else if (realhead - offset - 16 < realrrc) {
+		/*
+		 * The part to be moved is split between the head and
+		 * page data or tail
+		 */
+		printk("%s: We are not lucky.  All the realrrc data (%u) "
+			" is not in the head!\n", __func__, realrrc);
+		return 1;
+	} else if (realtail != 0 && tail->iov_len - realtail >= realrrc) {
+		/*
+		 * We are lucky enough to simply move rrc bytes
+		 * from the head to the end of the tail
+		 */
+		printk("%s: We are lucky! (moving %u from head to tail)\n",
+			__func__, realrrc);
+		memcpy(tail->iov_base + realtail,
+		       head->iov_base + offset + 16,
+		       realrrc);
+		tail->iov_len = realtail + realrrc;
+		memmove(headstart, headstart + realrrc,
+			realhead - offset - 16 - realrrc);
+		head->iov_len -= realrrc;
+	} else if (realpage != 0 && realtail == 0) {
+		/*
+		 * There is page data and no existing tail
+		 */
+		printk("%s: We are lucky! (moving %u from head to pages)\n",
+			__func__, realrrc);
+		buf->page_len += realrrc;
+		err = write_bytes_to_xdr_buf(buf, realhead + realpage,
+					     headstart, realrrc);
+		if (err) {
+			printk("%s: We are not lucky getting err %d while "
+				"writing %u bytes to xdr_buf\n",
+				__func__, err, realrrc);
+			return 1;
+		}
+		memmove(headstart, headstart + realrrc,
+			realhead - offset - 16 - realrrc);
+		head->iov_len -= realrrc;
+	} else {
+		/*
+		 * None of the quick fixes works.  Do it the "hard way".
+		 */
+		printk("%s: We are not lucky with realrrc %u\n",
+			__func__, realrrc);
+		return 1;
+	}
+
+	print_xdrbuf_data("AFTER : ", buf, offset);
+	return 0;
+}
 
 static u32
 gss_wrap_kerberos_v2(struct krb5_ctx *kctx, u32 offset,
@@ -585,3 +717,74 @@ gss_unwrap_kerberos(struct gss_ctx *gctx, int offset, struct xdr_buf *buf)
 	}
 }
 
+void
+print_hexl(const char *title, u8 *p, u_int length, u_int offset)
+{
+	u_int i, j, jm;
+	u8 c, *cp;
+
+	printk("RPC:       %s: length %d: %p\n", title, length, p);
+	cp = (u8 *) p;
+
+	for (i = 0; i < length; i += 0x10) {
+	        printk("  %04x: ", (u_int)(i + offset));
+	        jm = length - i;
+	        jm = jm > 16 ? 16 : jm;
+
+	        for (j = 0; j < jm; j++) {
+	                if ((j % 2) == 1)
+	                        printk("%02x ", (u_int)cp[i+j]);
+	                else
+	                        printk("%02x", (u_int)cp[i+j]);
+	        }
+	        for (; j < 16; j++) {
+	                if ((j % 2) == 1)
+	                        printk("   ");
+	                else
+	                        printk("  ");
+	        }
+	        printk(" ");
+
+	        for (j = 0; j < jm; j++) {
+	                c = cp[i+j];
+	                c = isprint(c) ? c : '.';
+	                printk("%c", c);
+	        }
+	        printk("\n");
+	}
+	printk("\n");
+}
+EXPORT_SYMBOL(print_hexl);
+
+void print_xdrbuf(const char *msg, struct xdr_buf *x)
+{
+	printk("---------- xdr_buf at %p: %s ----------\n", x, msg);
+	printk("  head[0].iov_base %p, iov_len %zu\n",
+	        x->head[0].iov_base, x->head[0].iov_len);
+	printk("  tail[0].iov_base %p, iov_len %zu\n",
+	        x->tail[0].iov_base, x->tail[0].iov_len);
+	printk("  pages %p\n", x->pages);
+	printk("  page_base %u, page_len %u, flags %u\n",
+	        x->page_base, x->page_len, x->flags);
+	printk("  buflen %u, len %u\n", x->buflen, x->len);
+}
+EXPORT_SYMBOL(print_xdrbuf);
+
+//extern void print_hexl(const char *title, u8 *p, u_int length, u_int offset);
+void print_xdrbuf_data(const char *msg, struct xdr_buf *x, unsigned int offset)
+{
+	printk("========== xdr_buf %p offset %u: %s ==========\n",
+	        x, offset, msg);
+	if (offset < x->head[0].iov_len)
+	        print_hexl("head data", x->head[0].iov_base + offset,
+	                                x->head[0].iov_len - offset, 0);
+	if (x->page_len) {
+	        int plen = (x->page_len > 512) ? 512 : x->page_len;
+	        print_hexl("page data",
+	                page_address(x->pages[0]) + x->page_base, plen, 0);
+	}
+	if (x->tail[0].iov_base != NULL && x->tail[0].iov_len != 0)
+	        print_hexl("tail data", x->tail[0].iov_base,
+	                                x->tail[0].iov_len, 0);
+}
+EXPORT_SYMBOL(print_xdrbuf_data);
