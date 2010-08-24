Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-gw0-f46.google.com ([74.125.83.46]:33754 "EHLO
	mail-gw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755687Ab0HXQfQ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 24 Aug 2010 12:35:16 -0400
Received: by gwj17 with SMTP id 17so2591720gwj.19
        for <linux-nfs@vger.kernel.org>; Tue, 24 Aug 2010 09:35:15 -0700 (PDT)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 0/5] Support IPv6 in libexport.a
To: steved@redhat.com
Cc: linux-nfs@vger.kernel.org
Date: Tue, 24 Aug 2010 12:35:11 -0400
Message-ID: <20100824162926.2433.7535.stgit@matisse.1015granger.net>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hi Steve-

This patch set should encapsulate IPv6-related changes needed in
support/export/client.c .  It updates logic that parses presentation
addresses and netmasks, and logic that compares socket addresses.

---

Chuck Lever (5):
      libexport.a: IPv6 support in client_check()
      libexport.a: IPv6 support for client_init_subnet()
      libexport.a: Prepare init_subnetwork() for IPv6 support
      libexport.a: Use host helper to parse address in client_init()
      libexport.a: Prepare to recognize IPv6 addresses in client_gettype()


 support/export/client.c |  208 +++++++++++++++++++++++++++++++++++------------
 1 files changed, 153 insertions(+), 55 deletions(-)

-- 
Chuck Lever
