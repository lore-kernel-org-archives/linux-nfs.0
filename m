Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f176.google.com ([209.85.223.176]:45875 "EHLO
	mail-ie0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1947146Ab3BHV1r (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 8 Feb 2013 16:27:47 -0500
Received: by mail-ie0-f176.google.com with SMTP id k13so5494300iea.7
        for <linux-nfs@vger.kernel.org>; Fri, 08 Feb 2013 13:27:46 -0800 (PST)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH v1 0/3] Improve server SECINFO robustness
To: linux-nfs@vger.kernel.org
Date: Fri, 08 Feb 2013 16:27:44 -0500
Message-ID: <20130208212007.2234.35721.stgit@seurat.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi-

This series addresses the concern I posted about here:

  http://marc.info/?l=linux-nfs&m=135975864104672&w=2

If a transient or permanent configuration error is introduced on a
Linux NFS server, it could cause the server to form an invalid reply
to a SECINFO request.  GSS flavors listed in the reply would appear
as their pseudoflavor numbers rather than as GSS triples.

This series applies on top of the series I posted last week:

  [PATCH v3 0/9] Dynamically load GSS pseudoflavors by OID

---

Chuck Lever (3):
      NFSD: Kill some mixed sign comparisons in fs/nfsd/nfs4xdr.c
      NFSD: SECINFO doesn't handle unsupported pseudoflavors correctly
      NFSD: Simplify GSS flavor encoding in nfsd4_do_encode_secinfo()


 fs/nfsd/nfs4xdr.c |   43 +++++++++++++++++++++++++------------------
 fs/nfsd/xdr4.h    |    2 +-
 2 files changed, 26 insertions(+), 19 deletions(-)

-- 
Chuck Lever
