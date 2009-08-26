Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mta1.dreamworks.com ([208.71.56.12]:6792 "EHLO
	michael.anim.dreamworks.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1755617AbZHZE7X (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 26 Aug 2009 00:59:23 -0400
Received: from pinkboy.anim.dreamworks.com ([192.168.249.112])
	by michael.anim.dreamworks.com (8.13.1/8.13.1) with ESMTP id n7Q4xN2G014274
	for <linux-nfs@vger.kernel.org>; Tue, 25 Aug 2009 21:59:23 -0700
Message-ID: <4A94C133.8030904@dreamworks.com>
Date: Tue, 25 Aug 2009 21:59:31 -0700
From: Lans Carstensen <Lans.Carstensen@dreamworks.com>
To: NFS list <linux-nfs@vger.kernel.org>
Subject: [PATCH 2/4] nfs-utils: nfs-iostat.py autofs cleanup and option to
 sort by ops/s
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

commit d3bb692a8c26c2d4e0dc70d7d0359daf79090e1e
Author: Lans Carstensen <Lans.Carstensen@dreamworks.com>
Date:   Tue Aug 25 21:52:03 2009 -0700

     Bump nfs-iostat.py version up to 0.3 to reflect new features.

diff --git a/tools/nfs-iostat/nfs-iostat.py b/tools/nfs-iostat/nfs-iostat.py
index ea02db4..6ce31fc 100644
--- a/tools/nfs-iostat/nfs-iostat.py
+++ b/tools/nfs-iostat/nfs-iostat.py
@@ -22,7 +22,7 @@ Foundation, Inc., 59 Temple Place, Suite 330, Boston, 
MA 02111-1307 USA

  import sys, os, time

-Iostats_version = '0.2'
+Iostats_version = '0.3'

  def difference(x, y):
      """Used for a map() function


