From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 00/15] Patches to be added to the 'remove-bkl' branch
Date: Thu, 12 Jun 2008 15:28:17 -0400
Message-ID: <20080612192817.24916.52065.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:33108 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752070AbYFLTtU (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 12 Jun 2008 15:49:20 -0400
Received: from sacexrs01.hq.netapp.com (sacexrs01.hq.netapp.com [10.99.190.105])
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id m5CJnK1e008536
	for <linux-nfs@vger.kernel.org>; Thu, 12 Jun 2008 12:49:20 -0700 (PDT)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The following series of patches will be added to the 'bkl-removal' branch
today. This is a new experimental branch dedicated to getting rid of BKL
usage in the NFS code.

The patchset is pretty complete, and appears to test out very well. It
applies on top of the patches from the 'devel' branch.

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com
