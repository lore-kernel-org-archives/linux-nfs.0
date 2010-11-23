Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:59046 "EHLO
	daytona.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752627Ab0KWOVj (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 23 Nov 2010 09:21:39 -0500
Message-ID: <4CEBCDF1.4010705@panasas.com>
Date: Tue, 23 Nov 2010 16:21:37 +0200
From: Benny Halevy <bhalevy@panasas.com>
To: NFS list <linux-nfs@vger.kernel.org>
Subject: pnfs git tree status pnfs-all-2.6.37-rc3-2010-11-23
References: <4CD17FC4.6090906@panasas.com> <4CE1604E.1070902@panasas.com>
In-Reply-To: <4CE1604E.1070902@panasas.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

This is a minor update to the linux-pnfs tree.
Rebased over v2.6.37-rc3, and dropped old version of
Trond's patch 88ce1e4 NFS: Fix a couple of regressions in readdir.
in favor of the new version merged in v2.6.37-rc3.

On 2010-11-15 18:31, Benny Halevy wrote:

Cumulative patches can be generated from
git://linux-nfs.org/~bhalevy/linux-pnfs.git
using
git diff v2.6.37-rc3 pnfs-all-2.6.37-rc3-2010-11-23

Or, they can be downloaded from the wiki at:
http://wiki.linux-nfs.org/wiki/index.php/PNFS_Development_Git_tree

Latest patches that went in since pnfs-all-2.6.37-rc1-2010-11-03:

pnfs:
  Benny Halevy     f272cdf SQUASHME: pnfs: move synchronize_rcu out side of spin_lock
