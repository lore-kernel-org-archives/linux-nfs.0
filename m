From: Frank van Maarseveen <frankvm@frankvm.com>
Subject: nfs-utils 1.1.2 + knfsd 2.6.27 (.5) breaks fsid= option
Date: Wed, 12 Nov 2008 11:48:11 +0100
Message-ID: <20081112104811.GA15011@janus>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: Linux NFS mailing list <linux-nfs@vger.kernel.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from frankvm.xs4all.nl ([80.126.170.174]:41620 "EHLO
	janus.localdomain" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751206AbYKLKsN (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 12 Nov 2008 05:48:13 -0500
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Tested on Debian lenny with nfs-kernel-server 1:1.1.2-6lenny1 and a
2.6.27.5 kernel. /etc/exports says:

	/mp @general(rw,sync,no_root_squash,no_subtree_check,mp,fsid=2886795869)

After actually using it /proc/fs/nfsd/exports says:

	/mp @general(rw,no_root_squash,sync,wdelay,no_subtree_check,fsid=-1408171427,uuid=db4387a6:bed949d0:8f5ef6a2:6a0c

(yes, 2886795869 == (ulong)-1408171427)
However, file handles over the wire now seem to have fsid_type=6
(FSID_UUID16) instead of 1 (FSID_NUM) due to this.

-- 
Frank
