Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qk0-f174.google.com ([209.85.220.174]:33085 "EHLO
	mail-qk0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753530AbbKQLxo (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 17 Nov 2015 06:53:44 -0500
Received: by qkas77 with SMTP id s77so1714136qka.0
        for <linux-nfs@vger.kernel.org>; Tue, 17 Nov 2015 03:53:43 -0800 (PST)
From: Jeff Layton <jlayton@poochiereds.net>
To: bfields@fieldses.org, trond.myklebust@primarydata.com
Cc: linux-nfs@vger.kernel.org, Eric Paris <eparis@parisplace.org>,
        Alexander Viro <viro@zeniv.linux.org.uk>,
        linux-fsdevel@vger.kernel.org
Subject: [PATCH v1 25/38] nfsd: add errno mapping for EREMOTEIO
Date: Tue, 17 Nov 2015 06:52:47 -0500
Message-Id: <1447761180-4250-26-git-send-email-jeff.layton@primarydata.com>
In-Reply-To: <1447761180-4250-1-git-send-email-jeff.layton@primarydata.com>
References: <1447761180-4250-1-git-send-email-jeff.layton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

...map to NFSERR_IO.

Signed-off-by: Jeff Layton <jeff.layton@primarydata.com>
---
 fs/nfsd/nfsproc.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/fs/nfsd/nfsproc.c b/fs/nfsd/nfsproc.c
index 9893095cbee1..5a82d20a50b4 100644
--- a/fs/nfsd/nfsproc.c
+++ b/fs/nfsd/nfsproc.c
@@ -794,6 +794,7 @@ nfserrno (int errno)
 		{ nfserr_toosmall, -ETOOSMALL },
 		{ nfserr_serverfault, -ESERVERFAULT },
 		{ nfserr_serverfault, -ENFILE },
+		{ nfserr_io, -EREMOTEIO },
 	};
 	int	i;
 
-- 
2.4.3

