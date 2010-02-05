Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:16541 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932282Ab0BERJf (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 5 Feb 2010 12:09:35 -0500
From: andros@netapp.com
To: pnfs@linux-nfs.org
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 0/5] pnfs DLM cluster only use read iomode layouts
Date: Fri,  5 Feb 2010 12:10:08 -0500
Message-Id: <1265389813-6823-1-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0


Applies against 2.6.33-rc6 pnfs-all branch.

In a DLM cluster, writing to a node other than the node where the open call
occurred and where meta data is cached will have performance implications when
the write causes meta data changes that need to be propagated to the open call
node.

Return NFS4ERR_BADIOMODE for LAYOUTGET requests with LAYOUTIOMODE4_RW iomode.

Plus a couple of error code fixes.

0001-pnfsd-fix-NFS4ERR_BADIOMODE-in-layoutget.patch
0002-pnfsd-fix-pnfs_export_operations-layoutget-valid-err.patch
0003-pnfsd-DLM-file-layout-only-support-read-iomode-layou.patch
0004-pnfsd-fix-DLM-file-layout-no-device-return.patch

Allow the client to fail a RW iomode layout and still grab a RO iomode layout.
0005-pnfs-set-failed-layout-bit-per-iomode.patch


Testing: Connectathon tests pass. Basic test shows RW iomode layout for
'bigfile' fails with NFS4ERR_BADIOMODE with writes going through the MDS,
and RO layout for 'bigfile' is obtained with reads going to the DS.


-->Andy

