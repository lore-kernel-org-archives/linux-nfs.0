Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:40313 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752147Ab0H3QeX (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 30 Aug 2010 12:34:23 -0400
Message-ID: <4C7BDD8C.40509@panasas.com>
Date: Mon, 30 Aug 2010 19:34:20 +0300
From: Benny Halevy <bhalevy@panasas.com>
To: NFS list <linux-nfs@vger.kernel.org>
Subject: pnfs git tree status pnfs-all-2.6.36-rc3-2010-08-30
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

This is the first rebased version of the tree over 2.6.36-rc*.
The tree's branches are structured the same (see details below).

Cumulative patches can be generated from
git://linux-nfs.org/~bhalevy/linux-pnfs.git
using
git diff v2.6.36-rc3 pnfs-all-2.6.36-rc3-2010-08-30
git diff v2.6.35 pnfs-all-2.6.35-2010-08-24

Or, they can be downloaded from the wiki at:
http://wiki.linux-nfs.org/wiki/index.php/PNFS_Development_Git_tree

Latest patches (since pnfs-all-2.6.35-2010-08-24):
pnfs-submit:
  Benny Halevy     32fb90a SQUASHME: pnfs-submit: do not use NIPQUAD in nfs4_callback_layoutrecall dprintk
  Benny Halevy     133b759 SQUASHME: pnfs-submit: get machince creds for getdeviceinfo

pnfs:
  Benny Halevy     247fe09 SQUASHME: pnfs: get machince creds for getdevicelist

pnfs-obj-all:
  Benny Halevy     c384327 SQUASHME: pnfs-obj use REQ flags rather than BIO flags

The full tree structure is:
master (v2.6.36-rc3)
	nfsd-upstream
		nfsd41-all
			nfs-upstream
				nfs41-all
					nfs41-all-latest
					pnfs-submit
						pnfs
							pnfs-block
					pnfsd-files
						pnfsd
							spnfs
								spnfs-block
							pnfsd-lexp
								pnfs-submit-all
									pnfs-all
										pnfs-obj-all
											pnfs-exofs-all
												pnfs-block-all
													spnfs-all
														spnfs-block-all
															pnfs-all-latest

Benny
