Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:55504 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754660AbeFNTVf (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 14 Jun 2018 15:21:35 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 0/2] knfsd change_attr_type & time_delta improvements
Date: Thu, 14 Jun 2018 15:21:31 -0400
Message-Id: <1529004093-5866-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

Implement change_attr_type, and fix time_delta.

I don't think the client currently uses either, I'm just assuming
they'll be useful some day, especially now that (thanks to jlayton) the
change attribute should be a real change attribute now in the
IS_I_VERSION() case.


J. Bruce Fields (2):
  nfsd: fix NFSv4 time_delta attribute
  nfsd4: support change_attr_type attribute

 fs/nfsd/nfs4xdr.c    | 39 ++++++++++++++++++++++++++++++++++++---
 fs/nfsd/nfsd.h       |  1 +
 include/linux/nfs4.h |  8 ++++++++
 3 files changed, 45 insertions(+), 3 deletions(-)

-- 
2.17.1
