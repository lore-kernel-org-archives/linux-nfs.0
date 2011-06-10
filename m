Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-gx0-f174.google.com ([209.85.161.174]:61209 "EHLO
	mail-gx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752340Ab1FJGcE (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 10 Jun 2011 02:32:04 -0400
Received: by gxk21 with SMTP id 21so1435137gxk.19
        for <linux-nfs@vger.kernel.org>; Thu, 09 Jun 2011 23:32:03 -0700 (PDT)
Date: Fri, 10 Jun 2011 14:32:03 +0800
Message-ID: <BANLkTikv_vi7eR8Xu-_K5F5D5Smrj=goog@mail.gmail.com>
Subject: [patch 1/1]: fix bug in CREATE_SESSION encoding
From: Sid Moore <learnmost@gmail.com>
To: linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hi

I think it might be an error when typing. see the patch below.


--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -1772,7 +1772,7 @@ static void encode_create_session(struct xdr_stream *xdr,
        *p++ = cpu_to_be32(0);                          /* rdmachannel_attrs */

        /* Back Channel */
-       *p++ = cpu_to_be32(args->fc_attrs.headerpadsz); /* header
padding size */
+       *p++ = cpu_to_be32(args->bc_attrs.headerpadsz); /* header
padding size */
        *p++ = cpu_to_be32(args->bc_attrs.max_rqst_sz); /* max req size */
        *p++ = cpu_to_be32(args->bc_attrs.max_resp_sz); /* max resp size */
        *p++ = cpu_to_be32(args->bc_attrs.max_resp_sz_cached);  /* Max
resp sz cached */

--
Sid
