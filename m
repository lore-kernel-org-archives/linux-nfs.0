Return-Path: <SRS0=Psyw=RE=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIM_ADSP_CUSTOM_MED,
	DKIM_INVALID,DKIM_SIGNED,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D8CA6C43381
	for <linux-nfs@archiver.kernel.org>; Fri,  1 Mar 2019 21:10:01 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 985CD20818
	for <linux-nfs@archiver.kernel.org>; Fri,  1 Mar 2019 21:10:01 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="r31y0bPW"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1725996AbfCAVKA (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 1 Mar 2019 16:10:00 -0500
Received: from mail-it1-f196.google.com ([209.85.166.196]:51992 "EHLO
        mail-it1-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1725982AbfCAVKA (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 1 Mar 2019 16:10:00 -0500
Received: by mail-it1-f196.google.com with SMTP id e24so22330382itl.1
        for <linux-nfs@vger.kernel.org>; Fri, 01 Mar 2019 13:09:59 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:from:to:cc:subject:date:message-id:mime-version
         :content-transfer-encoding;
        bh=wcCSYaqIWt1wbNTXxuflK/WqqUw3sFUiobMQ3IOGrys=;
        b=r31y0bPWGfBgluVf36IejYaVO4t5BIJmuhBKl7xYsZCXyfZowFEPIQtrpUQ70eMAPv
         UDdvc5pzF7h04b37nUbgcx+nEuwRXZ56B8YKGi7THSlNZQHNZemlsqqcSc8QC5ik/ARb
         2vAySxrNEMxAxsf/k2DeFGeV7KxSJoT6xdyX9Kh+ooLZiW4xmwLl6Qa0gtlQzASNuJbT
         sNqm+TdRRqIiDtZtaAV7sip3pBQQy+PGYauIBXQto0c4wYNXcotNNTRgI4O+NhFG5nWv
         mTb+Omd3vyv/Gg1GtSKXAZFYXdbh+sUCn/v+sjTOzlCTNZ5sAxdpEdsCMth/H6nw9VZF
         uqTw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:sender:from:to:cc:subject:date:message-id
         :mime-version:content-transfer-encoding;
        bh=wcCSYaqIWt1wbNTXxuflK/WqqUw3sFUiobMQ3IOGrys=;
        b=Rjew9cgM92apxSG+ejQgfNetudOQfOP79i7OFUujieQjMh8Rm+5zOXb85DhF0LB2zt
         tiof3kp7+zzqtHSmMsI7V/TKJ+gppv6/LaJJW7EqO4p3IZtL1FS0vz3hEf/xqp/ZRxtu
         URcmhz3HHwgoHcOTkdiCHknBsHgtQwgaBcBhH1jjQ6Ks5eCmsahLHPQsSP4nrFpztG2F
         F73a/5oOdPL0IuyNYDGxMFH7q8IcA00vKD3KBI3WqqzxZB8KUrV0D8eqKVK/vFZhN2Fu
         kIbUOPbNMq2NWxF+2uv97huvTt9P/oDidXZ2YLbQkoL/bNHHE7gVZG7u0Z88kEWgpVQO
         e/Cg==
X-Gm-Message-State: APjAAAXCB5YkLZ/Rib10KJyXdW1GAxjZ/oGcS7obZ2lJKm4yskiodTdK
        3irXMdcKlDgjiwM6xsFPUhAWISKZk2w=
X-Google-Smtp-Source: APXvYqzwfqdvDVMh2bxnBlCIetAWLTAyqTZbjLKmMsr6IA5BAMY4e7cnnBFLcG7kiDv73VyehPPN2g==
X-Received: by 2002:a24:9982:: with SMTP id a124mr881628ite.79.1551474598977;
        Fri, 01 Mar 2019 13:09:58 -0800 (PST)
Received: from gouda.nowheycreamery.com.nowheycreamery.com (d28-23-121-75.dim.wideopenwest.com. [23.28.75.121])
        by smtp.gmail.com with ESMTPSA id c26sm2541057itd.4.2019.03.01.13.09.57
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 01 Mar 2019 13:09:58 -0800 (PST)
From:   schumaker.anna@gmail.com
X-Google-Original-From: Anna.Schumaker@Netapp.com
To:     Trond.Myklebust@hammerspace.com, linux-nfs@vger.kernel.org
Cc:     Anna.Schumaker@Netapp.com
Subject: [PATCH] NFS: Add missing encode / decode sequence_maxsz to v4.2 operations
Date:   Fri,  1 Mar 2019 16:09:56 -0500
Message-Id: <20190301210956.13259-1-Anna.Schumaker@Netapp.com>
X-Mailer: git-send-email 2.21.0
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

From: Anna Schumaker <Anna.Schumaker@Netapp.com>

These really should have been there from the beginning, but we never
noticed because there was enough slack in the RPC request for the extra
bytes. Chuck's recent patch to use au_cslack and au_rslack to compute
buffer size shrunk the buffer enough that this was now a problem for
SEEK operations on my test client.

Fixes: f4ac1674f5da4 ("nfs: Add ALLOCATE support")
Fixes: 2e72448b07dc3 ("NFS: Add COPY nfs operation")
Fixes: cb95deea0b4aa ("NFS OFFLOAD_CANCEL xdr")
Fixes: 624bd5b7b683c ("nfs: Add DEALLOCATE support")
Fixes: 1c6dcbe5ceff8 ("NFS: Implement SEEK")
Signed-off-by: Anna Schumaker <Anna.Schumaker@Netapp.com>
---
 fs/nfs/nfs42xdr.c | 10 ++++++++++
 1 file changed, 10 insertions(+)

diff --git a/fs/nfs/nfs42xdr.c b/fs/nfs/nfs42xdr.c
index 22b3425df08f..7d596e8a0941 100644
--- a/fs/nfs/nfs42xdr.c
+++ b/fs/nfs/nfs42xdr.c
@@ -59,43 +59,53 @@
 #define decode_clone_maxsz		(op_decode_hdr_maxsz)
 
 #define NFS4_enc_allocate_sz		(compound_encode_hdr_maxsz + \
+					 encode_sequence_maxsz + \
 					 encode_putfh_maxsz + \
 					 encode_allocate_maxsz + \
 					 encode_getattr_maxsz)
 #define NFS4_dec_allocate_sz		(compound_decode_hdr_maxsz + \
+					 decode_sequence_maxsz + \
 					 decode_putfh_maxsz + \
 					 decode_allocate_maxsz + \
 					 decode_getattr_maxsz)
 #define NFS4_enc_copy_sz		(compound_encode_hdr_maxsz + \
+					 encode_sequence_maxsz + \
 					 encode_putfh_maxsz + \
 					 encode_savefh_maxsz + \
 					 encode_putfh_maxsz + \
 					 encode_copy_maxsz + \
 					 encode_commit_maxsz)
 #define NFS4_dec_copy_sz		(compound_decode_hdr_maxsz + \
+					 decode_sequence_maxsz + \
 					 decode_putfh_maxsz + \
 					 decode_savefh_maxsz + \
 					 decode_putfh_maxsz + \
 					 decode_copy_maxsz + \
 					 decode_commit_maxsz)
 #define NFS4_enc_offload_cancel_sz	(compound_encode_hdr_maxsz + \
+					 encode_sequence_maxsz + \
 					 encode_putfh_maxsz + \
 					 encode_offload_cancel_maxsz)
 #define NFS4_dec_offload_cancel_sz	(compound_decode_hdr_maxsz + \
+					 decode_sequence_maxsz + \
 					 decode_putfh_maxsz + \
 					 decode_offload_cancel_maxsz)
 #define NFS4_enc_deallocate_sz		(compound_encode_hdr_maxsz + \
+					 encode_sequence_maxsz + \
 					 encode_putfh_maxsz + \
 					 encode_deallocate_maxsz + \
 					 encode_getattr_maxsz)
 #define NFS4_dec_deallocate_sz		(compound_decode_hdr_maxsz + \
+					 decode_sequence_maxsz + \
 					 decode_putfh_maxsz + \
 					 decode_deallocate_maxsz + \
 					 decode_getattr_maxsz)
 #define NFS4_enc_seek_sz		(compound_encode_hdr_maxsz + \
+					 encode_sequence_maxsz + \
 					 encode_putfh_maxsz + \
 					 encode_seek_maxsz)
 #define NFS4_dec_seek_sz		(compound_decode_hdr_maxsz + \
+					 decode_sequence_maxsz + \
 					 decode_putfh_maxsz + \
 					 decode_seek_maxsz)
 #define NFS4_enc_layoutstats_sz		(compound_encode_hdr_maxsz + \
-- 
2.21.0

