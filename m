Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-iw0-f197.google.com ([209.85.223.197]:40661 "EHLO
	mail-iw0-f197.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752623Ab0DLT5K (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 12 Apr 2010 15:57:10 -0400
Received: by iwn35 with SMTP id 35so1414538iwn.21
        for <linux-nfs@vger.kernel.org>; Mon, 12 Apr 2010 12:57:08 -0700 (PDT)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 0/2] Two small mountd IPv6 patches
To: steved@redhat.com
Cc: linux-nfs@vger.kernel.org
Date: Mon, 12 Apr 2010 15:57:05 -0400
Message-ID: <20100412195538.9839.76495.stgit@localhost.localdomain>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Steve-

Two quick clean-ups that prepare for mountd/exportfs IPv6 support.

---

Chuck Lever (2):
      libexport.a: Add helper for populating m_addrlist[]
      libexport.a: Reduce code duplication in client_init()


 support/export/client.c |   41 ++++++++++++++++++++++-------------------
 1 files changed, 22 insertions(+), 19 deletions(-)

-- 
Chuck Lever
