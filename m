Return-Path: linux-nfs-owner@vger.kernel.org
Received: from frankvm.xs4all.nl ([83.163.248.189]:53800 "EHLO
	janus.localdomain" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750952AbaLULtN (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 21 Dec 2014 06:49:13 -0500
Date: Sun, 21 Dec 2014 12:40:15 +0100
From: Frank van Maarseveen <frankvm@frankvm.com>
To: Linux NFS mailing list <linux-nfs@vger.kernel.org>
Subject: 3.17.x 3.18.x nfs_permission(): put_rpccred() missing?
Message-ID: <20141221114015.GA25387@janus>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

While updating the nfs-ngroups patch for 3.17 and 3.18 I noticed that
nfs_permission() seems to be missing a put_rpccred() call in the non
-ECHILD path.

-- 
Frank
