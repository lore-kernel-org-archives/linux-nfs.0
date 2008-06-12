From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 00/37] Patches to be added to the 'devel' branch
Date: Thu, 12 Jun 2008 15:22:00 -0400
Message-ID: <20080612192159.24528.43756.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:64822 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754647AbYFLTd6 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 12 Jun 2008 15:33:58 -0400
Received: from svlexrs01.hq.netapp.com (svlexrs01.corp.netapp.com [10.57.156.158])
	by smtp2.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id m5CJXvo2001505
	for <linux-nfs@vger.kernel.org>; Thu, 12 Jun 2008 12:33:57 -0700 (PDT)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The following series of patches will be added to the 'devel' branch
today. There are no major bugfixes or new features. Most of the
patches are just cleanups, and there are a few optimisations.

The only minor new feature to report is Jeff's patch to report an
error if we are unable to accommodate a remount request.

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com
