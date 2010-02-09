Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:24051 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755124Ab0BIRm6 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 9 Feb 2010 12:42:58 -0500
From: andros@netapp.com
To: pnfs@linux-nfs.org
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 0/6] pnfs DLM cluster only use read iomode layouts Version 2
Date: Tue,  9 Feb 2010 12:42:31 -0500
Message-Id: <1265737357-9405-1-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0


Responded to comments on error code fixes.

Applies against 2.6.33-rc6 pnfs-all branch.

In a DLM cluster, writing to a node other than the node where the open call
occurred (where meta data is cached) will have performance implications when
the write causes meta data changes that need to be propagated to the open call
node.

Return NFS4ERR_BADIOMODE for LAYOUTGET requests with LAYOUTIOMODE4_RW iomode.

0001-pnfsd-fix-file-system-API-layout_get-error-codes.patch
0002-pnfsd-fix-NFS4ERR_BADIOMODE-in-layoutget.patch
0003-pnfsd-DLM-file-layout-only-support-read-iomode-layou.patch
0004-pnfsd-fix-DLM-file-layout-no-device-return.patch

Allow the client to fail a RW iomode layout and still grab a RO iomode layout.
0005-pnfs-set-failed-layout-bit-per-iomode.patch

fix compile errors
0006-pnfsd-fix-compile-errors-when-CONFIG_PNFSD-is-not-se.patch

Testing: Connectathon tests pass. Basic test shows RW iomode layout for
'bigfile' fails with NFS4ERR_BADIOMODE with writes going through the MDS,
and RO layout for 'bigfile' is obtained with reads going to the DS.


-->Andy

