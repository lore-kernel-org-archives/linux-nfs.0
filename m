From: Greg KH <gregkh@suse.de>
Subject: [31/50] Correctly close old nfsd/lockd sockets.
Date: Mon, 24 Sep 2007 09:21:46 -0700
Message-ID: <20070924162146.GF13510@kroah.com>
References: <20070924161246.983665021@mini.kroah.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Justin Forbes <jmforbes@linuxtx.org>,
	Zwane Mwaikambo <zwane@arm.linux.org.uk>,
	Theodore Ts'o <tytso@mit.edu>,
	Randy Dunlap <rdunlap@xenotime.net>,
	Dave Jones <davej@redhat.com>,
	Chuck Wolber <chuckw@quantumlinux.com>,
	Chris Wedgwood <reviews@ml.cw.f00f.org>,
	Michael Krufky <mkrufky@linuxtv.org>,
	Chuck Ebbert <cebbert@redhat.com>,
	Domenico Andreoli <cavokz@gmail.com>,
	akpm@linux-foundation.org, alan@lxorguk.ukuu.org.uk,
	Neil Brown <neilb@suse.de>, nfs@lists.sourceforge.net,
	trond.myklebust@fys.uio.no,
	Wolfgang Walter <wolfgang.walter@studentenwerk.mhn.de>,
	"J. Bruce Fields" <bfields@citi.umich.edu>
To: linux-kernel@vger.kernel.org, stable@kernel.org,
	Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1762330AbXIXQg0@vger.kernel.org>
In-Reply-To: <20070924161733.GA13510@kroah.com>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

From: Neil Brown <neilb@suse.de>

commit 7a1fa065a0264f6b3d3003ba5635289f6583c478 in mainline.

Commit aaf68cfbf2241d24d46583423f6bff5c47e088b3 added a bias
to sk_inuse, so this test for an unused socket now fails.  So no
sockets get closed because they are old (they might get closed
if the client closed them).

This bug has existed since 2.6.21-rc1.

Thanks to Wolfgang Walter for finding and reporting the bug.

Cc: Wolfgang Walter <wolfgang.walter@studentenwerk.mhn.de>
Signed-off-by: Neil Brown <neilb@suse.de>
Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
Signed-off-by: Linus Torvalds <torvalds@linux-foundation.org>
Signed-off-by: Greg Kroah-Hartman <gregkh@suse.de>

---
 net/sunrpc/svcsock.c |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

--- a/net/sunrpc/svcsock.c
+++ b/net/sunrpc/svcsock.c
@@ -1573,7 +1573,8 @@ svc_age_temp_sockets(unsigned long closu
 
 		if (!test_and_set_bit(SK_OLD, &svsk->sk_flags))
 			continue;
-		if (atomic_read(&svsk->sk_inuse) || test_bit(SK_BUSY, &svsk->sk_flags))
+		if (atomic_read(&svsk->sk_inuse) > 1
+		    || test_bit(SK_BUSY, &svsk->sk_flags))
 			continue;
 		atomic_inc(&svsk->sk_inuse);
 		list_move(le, &to_be_aged);

-- 
