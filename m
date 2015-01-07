Return-Path: linux-kernel-owner@vger.kernel.org
Date: Wed, 7 Jan 2015 15:06:24 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Holger =?utf-8?Q?Hoffst=C3=A4tte?=
	<holger.hoffstaette@googlemail.com>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: [PATCH] nfsd4: tweak rd_dircount accounting
Message-ID: <20150107200624.GA8119@fieldses.org>
References: <alpine.OSX.2.19.9992.1412180955000.62182@planck.local>
 <20141218151914.GB18179@fieldses.org>
 <pan.2014.12.18.15.42.53@googlemail.com>
 <20141218163254.GF18179@fieldses.org>
 <549303FC.9090604@googlemail.com>
 <20141218170653.GG18179@fieldses.org>
 <54932EA5.9090803@googlemail.com>
 <20141220180243.GA10273@fieldses.org>
 <pan.2015.01.07.00.25.06@googlemail.com>
 <20150107182141.GA7066@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20150107182141.GA7066@fieldses.org>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

RFC 3530 14.2.24 says

	This value represents the length of the names of the directory
	entries and the cookie value for these entries.  This length
	represents the XDR encoding of the data (names and cookies)...

The "xdr encoding" of the name should probably include the 4 bytes for
the length.

But this is all just a hint so not worth e.g. backporting to stable.

Also reshuffle some lines to more clearly group together the
dircount-related code.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/nfs4xdr.c | 7 ++++---
 1 file changed, 4 insertions(+), 3 deletions(-)

On Wed, Jan 07, 2015 at 01:21:41PM -0500, bfields wrote:
> But anyway that reproducer worked and confirmed the following which I'll
> probably pass along upstream today or tomorrow....

I also noticed this nit while I was there.  I'm planning to queue this
up for 3.20.--b.

diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index 15f7b73e0c0f..91f7a3644ffb 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -2768,16 +2768,17 @@ nfsd4_encode_dirent(void *ccdv, const char *name, int namlen,
 	if (entry_bytes > cd->rd_maxcount)
 		goto fail;
 	cd->rd_maxcount -= entry_bytes;
-	if (!cd->rd_dircount)
-		goto fail;
 	/*
 	 * RFC 3530 14.2.24 describes rd_dircount as only a "hint", so
 	 * let's always let through the first entry, at least:
 	 */
-	name_and_cookie = 4 * XDR_QUADLEN(namlen) + 8;
+	if (!cd->rd_dircount)
+		goto fail;
+	name_and_cookie = 4 + 4 * XDR_QUADLEN(namlen) + 8;
 	if (name_and_cookie > cd->rd_dircount && cd->cookie_offset)
 		goto fail;
 	cd->rd_dircount -= min(cd->rd_dircount, name_and_cookie);
+
 	cd->cookie_offset = cookie_offset;
 skip_entry:
 	cd->common.err = nfs_ok;
-- 
1.9.3

