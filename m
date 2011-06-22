Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mpc-26.sohonet.co.uk ([193.203.82.251]:56021 "EHLO
	moving-picture.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753372Ab1FVLO0 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 22 Jun 2011 07:14:26 -0400
Received: from cassini.mpc.local ([172.16.15.37] helo=moving-picture.com)
	by moving-picture.com with esmtp (Exim 4.43)
	id 1QZLO5-0003JH-FI
	for linux-nfs@vger.kernel.org; Wed, 22 Jun 2011 12:14:25 +0100
Message-ID: <4E01CE91.50203@moving-picture.com>
Date: Wed, 22 Jun 2011 12:14:25 +0100
From: James Pearson <james-p@moving-picture.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH] nfs-utils: remove possibly false statement from exports.man
Content-Type: text/plain; charset=us-ascii; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

A very minor change suggested by J. Bruce Fields <bfields@fieldses.org> 
to remove the statement that exporting to a single host or IP address is 
the "most common format" - as it probably isn't.

Signed-off-by: James Pearson <james-p@moving-picture.com>

--- a/utils/exportfs/exports.man        2011-06-22 11:37:41.228238000 +0100
+++ b/utils/exportfs/exports.man        2011-06-22 11:38:51.012894000 +0100
@@ -45,7 +45,7 @@
  .SS Machine Name Formats
  NFS clients may be specified in a number of ways:
  .IP "single host
-This is the most common format. You may specify a host either by an
+You may specify a host either by an
  abbreviated name recognized be the resolver, the fully qualified domain
  name, or an IP address.
  .IP "IP networks
