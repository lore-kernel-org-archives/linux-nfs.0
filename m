Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:55382 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932601Ab0HDGuk (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 4 Aug 2010 02:50:40 -0400
From: Neil Brown <neilb@suse.de>
To: Chuck Lever <chuck.lever@oracle.com>, Steve Dickson <steved@redhat.com>
Date: Wed, 04 Aug 2010 16:49:45 +1000
Subject: [PATCH 0/3] Some IPv6 enhancements for nfs-utils
Cc: linux-nfs@vger.kernel.org
Message-ID: <20100804064553.16641.92857.stgit@localhost.localdomain>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hi Chuck et al,
 I've been playing with IPv6 server support and offer these patches
 which get us a little bit closer.
 I realise that you may already have similar patches queued in which
 case feel free to ignore these.

 With these plus a couple of #defines of IPV6_SUPPORTED I can export
 with NFSv4 over IPv6 quite successfully.

NeilBrown

---

Neil Brown (3):
      Make buffers large enough for IPv6 addresses
      Give hostname.c more support for IPv6
      Allow check_fqdn to compare IPv6 addresses


 support/export/client.c   |   23 +----------------------
 support/export/hostname.c |   28 +++++++++++++++++++---------
 utils/mountd/cache.c      |    6 +++---
 utils/mountd/rmtab.c      |    2 +-
 4 files changed, 24 insertions(+), 35 deletions(-)

-- 
Signature

