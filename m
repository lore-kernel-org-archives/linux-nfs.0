From: Lans Carstensen <Lans.Carstensen-hCDZnVt6e3JSwrhanM7KvQ@public.gmane.org>
Subject: [PATCH 1/4] nfs-utils: nfs-iostat.py autofs cleanup and option to
 sort by ops/s
Date: Mon, 14 Sep 2009 21:57:37 -0700
Message-ID: <4AAF1EC1.8040301@dreamworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
To: NFS list <linux-nfs@vger.kernel.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mta1.dreamworks.com ([208.71.56.12]:11136 "EHLO
	michael.anim.dreamworks.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751471AbZIOE5g (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 15 Sep 2009 00:57:36 -0400
Received: from pinkboy.anim.dreamworks.com ([192.168.249.78])
	by michael.anim.dreamworks.com (8.13.1/8.13.1) with ESMTP id n8F4veIR013575
	for <linux-nfs@vger.kernel.org>; Mon, 14 Sep 2009 21:57:40 -0700
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Conforms Python path to the LSB 3.2+ standard of /usr/bin/python
http://refspecs.freestandards.org/LSB_3.2.0/LSB-Languages/LSB-Languages/pylocation.html
Per SteveD this is also required for proper rpm dep resolution during builds

Signed-off-by: Lans Carstensen <Lans.Carstensen-hCDZnVt6e3JSwrhanM7KvQ@public.gmane.org>
---
  tools/nfs-iostat/nfs-iostat.py |    2 +-
  1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/tools/nfs-iostat/nfs-iostat.py b/tools/nfs-iostat/nfs-iostat.py
index 9626d42..ea02db4 100644
--- a/tools/nfs-iostat/nfs-iostat.py
+++ b/tools/nfs-iostat/nfs-iostat.py
@@ -1,4 +1,4 @@
-#!/usr/bin/env python
+#!/usr/bin/python
  # -*- python-mode -*-
  """Emulate iostat for NFS mount points using /proc/self/mountstats
  """
-- 
1.5.5.6


