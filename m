From: Benny Halevy <bhalevy@panasas.com>
Subject: [RFC 0/4] nfs-utils: nfsd support for minor version
Date: Mon, 13 Apr 2009 11:25:08 +0300
Message-ID: <49E2F6E4.2080501@panasas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: NFS list <linux-nfs@vger.kernel.org>,
	pNFS Mailing List <pnfs@linux-nfs.org>,
	"J. Bruce Fields" <bfields@citi.umich.edu>
To: Steve Dickson <steved@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from gw-ca.panasas.com ([209.116.51.66]:13899 "EHLO
	laguna.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752352AbZDMI0J (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 13 Apr 2009 04:26:09 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Steve, please review the following patch that add support
for controlling the nfsv4 minor version support via
/proc/fs/nfsd/versions.

[PATCH 1/4] utils/nfsd: fix -N optarg error printout
	This patch fixes an existing bug.

[RFC 2/4] utils/nfsd: add support for minorvers4
	Under-the-cover support for minorvers4

[RFC 3/4] utils/nfsd: add -n --nfs-version option
	Add a command line option to enable versions

[RFC 3/4] utils/nfsd: enable/disable minorvers4 via command line
	Extend -n/-N syntax to accept <version>.<minorversion>

Thanks,

Benny
