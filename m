Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f67.google.com ([209.85.214.67]:54424 "EHLO
        mail-it0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753253AbeDBVMq (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 2 Apr 2018 17:12:46 -0400
Received: by mail-it0-f67.google.com with SMTP id h143-v6so20524579ita.4
        for <linux-nfs@vger.kernel.org>; Mon, 02 Apr 2018 14:12:46 -0700 (PDT)
Received: from hut.sorensonfamily.com (198-0-247-150-static.hfc.comcastbusiness.net. [198.0.247.150])
        by smtp.gmail.com with ESMTPSA id 17sm579330iom.73.2018.04.02.14.12.45
        for <linux-nfs@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 02 Apr 2018 14:12:45 -0700 (PDT)
To: linux-nfs@vger.kernel.org
From: Frank Sorenson <sorenson@redhat.com>
Subject: [PATCH] NFS: advance nfs_entry cookie only after decoding completes
 successfully
Message-ID: <6ce3a0df-b9f1-e839-4e55-097f2f3b8c2b@redhat.com>
Date: Mon, 2 Apr 2018 16:12:45 -0500
MIME-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Author: Frank Sorenson <sorenson@redhat.com>
Date:   2018-04-02 15:56:02 -0500

    NFS: advance nfs_entry cookie only after decoding completes successfully
    
    In nfs[34]_decode_dirent, the cookie is advanced as soon as it is
    read, but decoding may still fail later in the function, returning
    an error.  Because the cookie has been advanced, the failing entry
    is not re-requested from the server, resulting in a missing directory
    entry.
    
    In addition, nfs v3 and v4 read the cookie at different locations
    in the xdr_stream, so the behavior of the two can be inconsistent.
    
    Fix these by reading the cookie into a temporary variable, and
    only advancing the cookie once the entire entry has been decoded
    from the xdr_stream successfully.
    
    Signed-off-by: Frank Sorenson <sorenson@redhat.com>
---
 fs/nfs/nfs3xdr.c | 7 +++++--
 fs/nfs/nfs4xdr.c | 7 +++++--
 2 files changed, 10 insertions(+), 4 deletions(-)

diff --git a/fs/nfs/nfs3xdr.c b/fs/nfs/nfs3xdr.c
index 6cd33bd5da87..09ee36dd8426 100644
--- a/fs/nfs/nfs3xdr.c
+++ b/fs/nfs/nfs3xdr.c
@@ -1997,6 +1997,7 @@ int nfs3_decode_dirent(struct xdr_stream *xdr, struct nfs_entry *entry,
 	struct nfs_entry old = *entry;
 	__be32 *p;
 	int error;
+	u64 new_cookie;
 
 	p = xdr_inline_decode(xdr, 4);
 	if (unlikely(p == NULL))
@@ -2019,8 +2020,7 @@ int nfs3_decode_dirent(struct xdr_stream *xdr, struct nfs_entry *entry,
 	if (unlikely(error))
 		return error;
 
-	entry->prev_cookie = entry->cookie;
-	error = decode_cookie3(xdr, &entry->cookie);
+	error = decode_cookie3(xdr, &new_cookie);
 	if (unlikely(error))
 		return error;
 
@@ -2054,6 +2054,9 @@ int nfs3_decode_dirent(struct xdr_stream *xdr, struct nfs_entry *entry,
 			zero_nfs_fh3(entry->fh);
 	}
 
+	entry->prev_cookie = entry->cookie;
+	entry->cookie = new_cookie;
+
 	return 0;
 
 out_overflow:
diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index 65c9c4175145..1d7119a25c3a 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -7536,6 +7536,7 @@ int nfs4_decode_dirent(struct xdr_stream *xdr, struct nfs_entry *entry,
 	unsigned int savep;
 	uint32_t bitmap[3] = {0};
 	uint32_t len;
+	uint64_t new_cookie;
 	__be32 *p = xdr_inline_decode(xdr, 4);
 	if (unlikely(!p))
 		goto out_overflow;
@@ -7552,8 +7553,7 @@ int nfs4_decode_dirent(struct xdr_stream *xdr, struct nfs_entry *entry,
 	p = xdr_inline_decode(xdr, 12);
 	if (unlikely(!p))
 		goto out_overflow;
-	entry->prev_cookie = entry->cookie;
-	p = xdr_decode_hyper(p, &entry->cookie);
+	p = xdr_decode_hyper(p, &new_cookie);
 	entry->len = be32_to_cpup(p);
 
 	p = xdr_inline_decode(xdr, entry->len);
@@ -7587,6 +7587,9 @@ int nfs4_decode_dirent(struct xdr_stream *xdr, struct nfs_entry *entry,
 	if (entry->fattr->valid & NFS_ATTR_FATTR_TYPE)
 		entry->d_type = nfs_umode_to_dtype(entry->fattr->mode);
 
+	entry->prev_cookie = entry->cookie;
+	entry->cookie = new_cookie;
+
 	return 0;
 
 out_overflow:
