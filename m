Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mta1.dreamworks.com ([208.71.56.12]:6790 "EHLO
	michael.anim.dreamworks.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1755594AbZHZE7X (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 26 Aug 2009 00:59:23 -0400
Received: from pinkboy.anim.dreamworks.com ([192.168.249.112])
	by michael.anim.dreamworks.com (8.13.1/8.13.1) with ESMTP id n7Q4xMkJ014270
	for <linux-nfs@vger.kernel.org>; Tue, 25 Aug 2009 21:59:22 -0700
Message-ID: <4A94C12E.4050505@dreamworks.com>
Date: Tue, 25 Aug 2009 21:59:26 -0700
From: Lans Carstensen <Lans.Carstensen@dreamworks.com>
To: NFS list <linux-nfs@vger.kernel.org>
Subject: [PATCH 1/4] nfs-utils: nfs-iostat.py autofs cleanup and option to
 sort by ops/s
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

commit 1da314fc4e0548e30516e6140e98ad56d2150048
Author: Lans Carstensen <Lans.Carstensen@dreamworks.com>
Date:   Tue Aug 25 21:50:29 2009 -0700

     Conforms Python path to the LSB 3.2+ standard of /usr/bin/python
 
http://refspecs.freestandards.org/LSB_3.2.0/LSB-Languages/LSB-Languages/pylocation.html
     Per SteveD this is also required for proper rpm dep resolution 
during builds

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


