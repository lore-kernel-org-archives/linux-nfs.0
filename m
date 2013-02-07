Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-gh0-f175.google.com ([209.85.160.175]:37456 "EHLO
	mail-gh0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757809Ab3BGOvq (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 7 Feb 2013 09:51:46 -0500
Received: by mail-gh0-f175.google.com with SMTP id g18so630781ghb.20
        for <linux-nfs@vger.kernel.org>; Thu, 07 Feb 2013 06:51:45 -0800 (PST)
From: Jeff Layton <jlayton@redhat.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v3 0/2] nfsd: checksum first 256 bytes of request to guard against XID collisions in the DRC
Date: Thu,  7 Feb 2013 09:51:39 -0500
Message-Id: <1360248701-23963-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This patchset is a respin of the ones that Bruce has not yet committed
of my DRC overhaul. The main difference is the first patch, which adds a
routine to strip the trailing checksum off of decrypted or
integrity-verified buffer.

I've tested both the client and server with different krb5 flavors (and
using both the v1 and v2 codepaths) and it seems to work fine with those
checksum blobs stripped off.

I think we should consider this for 3.9 since XID collisions are a lot
more likely now with the new DRC code in place.

Jeff Layton (2):
  sunrpc: trim off trailing checksum before returning decrypted or
    integrity authenticated buffer
  nfsd: keep a checksum of the first 256 bytes of request

 fs/nfsd/cache.h                     |  5 ++++
 fs/nfsd/nfscache.c                  | 53 ++++++++++++++++++++++++++++++++++---
 include/linux/sunrpc/xdr.h          |  1 +
 net/sunrpc/auth_gss/gss_krb5_wrap.c |  2 ++
 net/sunrpc/auth_gss/svcauth_gss.c   | 10 +++++--
 net/sunrpc/xdr.c                    | 42 +++++++++++++++++++++++++++++
 6 files changed, 107 insertions(+), 6 deletions(-)

-- 
1.7.11.7

