From: Chris Wright <chrisw@sous-sol.org>
Subject: [patch 18/69] knfsd: rpc: fix server-side wrapping of krb5i replies
Date: Mon, 21 May 2007 12:16:30 -0700
Message-ID: <20070521191714.531390000@sous-sol.org>
References: <20070521191612.800400000@sous-sol.org>
Cc: Justin Forbes <jmforbes@linuxtx.org>,
	Zwane Mwaikambo <zwane@arm.linux.org.uk>,
	"Theodore Ts'o" <tytso@mit.edu>,
	Randy Dunlap <rdunlap@xenotime.net>,
	Dave Jones <davej@redhat.com>,
	Chuck Wolber <chuckw@quantumlinux.com>,
	Chris Wedgwood <reviews@ml.cw.f00f.org>,
	Michael Krufky <mkrufky@linuxtv.org>,
	Chuck Ebbert <cebbert@redhat.com>,
	torvalds@linux-foundation.org, alan@lxorguk.ukuu.org.uk,
	NeilBrown <neilb@suse.de>,
	"J. Bruce Fields" <bfields@citi.umich.edu>,
	nfs@lists.sourceforge.net
To: linux-kernel@vger.kernel.org, stable@kernel.org,
	Andrew Morton <akpm@linux-foundation.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1765979AbXEUTg5@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

-stable review patch.  If anyone has any objections, please let us know.
---------------------

From: NeilBrown <neilb@suse.de>

It's not necessarily correct to assume that the xdr_buf used to hold the
server's reply must have page data whenever it has tail data.

And there's no need for us to deal with that case separately anyway.

Acked-by: "J. Bruce Fields" <bfields@citi.umich.edu>
Signed-off-by: Neil Brown <neilb@suse.de>
Signed-off-by: Chris Wright <chrisw@sous-sol.org>
---

 net/sunrpc/auth_gss/svcauth_gss.c |    8 +-------
 1 file changed, 1 insertion(+), 7 deletions(-)

diff .prev/net/sunrpc/auth_gss/svcauth_gss.c ./net/sunrpc/auth_gss/svcauth_gss.c
--- linux-2.6.21.1.orig/net/sunrpc/auth_gss/svcauth_gss.c
+++ linux-2.6.21.1/net/sunrpc/auth_gss/svcauth_gss.c
@@ -1196,13 +1196,7 @@ svcauth_gss_wrap_resp_integ(struct svc_r
 	if (xdr_buf_subsegment(resbuf, &integ_buf, integ_offset,
 				integ_len))
 		BUG();
-	if (resbuf->page_len == 0
-			&& resbuf->head[0].iov_len + RPC_MAX_AUTH_SIZE
-			< PAGE_SIZE) {
-		BUG_ON(resbuf->tail[0].iov_len);
-		/* Use head for everything */
-		resv = &resbuf->head[0];
-	} else if (resbuf->tail[0].iov_base == NULL) {
+	if (resbuf->tail[0].iov_base == NULL) {
 		if (resbuf->head[0].iov_len + RPC_MAX_AUTH_SIZE > PAGE_SIZE)
 			goto out_err;
 		resbuf->tail[0].iov_base = resbuf->head[0].iov_base

-- 
