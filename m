From: Greg KH <gregkh@suse.de>
Subject: [NFS] [patch 59/73] knfsd: Allow NFSv2/3 WRITE calls to succeed
	when	krb5i etc is used.
Date: Wed, 6 Feb 2008 15:54:05 -0800
Message-ID: <20080206235405.GH13121__4678.20981652967$1202346255$gmane$org@suse.de>
References: <20080206234302.769849277@mini.kroah.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Peter Staubach <staubach@redhat.com>,
	Theodore Ts'o <tytso@mit.edu>,
	Zwane Mwaikambo <zwane@arm.linux.org.uk>,
	NeilBrown <neilb@suse.de>,
	"J. Bruce Fields" <bfields@citi.umich.edu>,
	Justin Forbes <jmforbes-a5Mqy2EUIFVAfugRpC6u6w@public.gmane.org>,
	Domenico Andreoli <cavokz@gmail.com>,
	Chris Wedgwood <reviews-vFB7bnJMxjixIvdkapsUdQ@public.gmane.org>,
	Randy Dunlap <rdunlap@xenotime.net>,
	Michael Krufky <mkrufky-dJidKbW2IEtAfugRpC6u6w@public.gmane.org>,
	Chuck Ebbert <cebbert@redhat.com>,
	Dave Jones <davej@redhat.com>,
	Chuck Wolber <chuckw-lrwSPXAIdEw7YuNMryXyOw@public.gmane.org>,
	akpm@linux-foundation.org, alan@lxorguk.ukuu.org.uk,
	nfs@lists.sourceforge.net
To: linux-kernel@vger.kernel.org, stable@kernel.org,
	Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from neil.brown.name ([220.233.11.133]:45214 "EHLO neil.brown.name"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758092AbYBGBDb (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 6 Feb 2008 20:03:31 -0500
Received: from brown by neil.brown.name with local (Exim 4.63)
	(envelope-from <nfs-bounces@lists.sourceforge.net>)
	id 1JMvAm-0000f7-2F
	for linux-nfs@vger.kernel.org; Thu, 07 Feb 2008 12:03:28 +1100
In-Reply-To: <20080206235015.GA13121@suse.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


2.6.23-stable review patch.  If anyone has any objections, please let us know.
------------------
From: NeilBrown <neilb@suse.de>

patch ba67a39efde8312e386c6f603054f8945433d91f in mainline.

When RPCSEC/GSS and krb5i is used, requests are padded, typically to a multiple
of 8 bytes.  This can make the request look slightly longer than it
really is.

As of

	f34b95689d2ce001c "The NFSv2/NFSv3 server does not handle zero
		length WRITE request correctly",

the xdr decode routines for NFSv2 and NFSv3 reject requests that aren't
the right length, so krb5i (for example) WRITE requests can get lost.

This patch relaxes the appropriate test and enhances the related comment.

Signed-off-by: Neil Brown <neilb@suse.de>
Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
Cc: Peter Staubach <staubach@redhat.com>
Signed-off-by: Linus Torvalds <torvalds@linux-foundation.org>
Signed-off-by: Greg Kroah-Hartman <gregkh@suse.de>

---
 fs/nfsd/nfs3xdr.c |    5 ++++-
 fs/nfsd/nfsxdr.c  |    5 ++++-
 2 files changed, 8 insertions(+), 2 deletions(-)

--- a/fs/nfsd/nfs3xdr.c
+++ b/fs/nfsd/nfs3xdr.c
@@ -396,8 +396,11 @@ nfs3svc_decode_writeargs(struct svc_rqst
 	 * Round the length of the data which was specified up to
 	 * the next multiple of XDR units and then compare that
 	 * against the length which was actually received.
+	 * Note that when RPCSEC/GSS (for example) is used, the
+	 * data buffer can be padded so dlen might be larger
+	 * than required.  It must never be smaller.
 	 */
-	if (dlen != XDR_QUADLEN(len)*4)
+	if (dlen < XDR_QUADLEN(len)*4)
 		return 0;
 
 	if (args->count > max_blocksize) {
--- a/fs/nfsd/nfsxdr.c
+++ b/fs/nfsd/nfsxdr.c
@@ -313,8 +313,11 @@ nfssvc_decode_writeargs(struct svc_rqst 
 	 * Round the length of the data which was specified up to
 	 * the next multiple of XDR units and then compare that
 	 * against the length which was actually received.
+	 * Note that when RPCSEC/GSS (for example) is used, the
+	 * data buffer can be padded so dlen might be larger
+	 * than required.  It must never be smaller.
 	 */
-	if (dlen != XDR_QUADLEN(len)*4)
+	if (dlen < XDR_QUADLEN(len)*4)
 		return 0;
 
 	rqstp->rq_vec[0].iov_base = (void*)p;

-- 

-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2008.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
_______________________________________________
Please note that nfs@lists.sourceforge.net is being discontinued.
Please subscribe to linux-nfs@vger.kernel.org instead.
    http://vger.kernel.org/vger-lists.html#linux-nfs

