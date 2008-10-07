From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 00/30] What's in the NFS queue for 2.6.27
Date: Tue, 07 Oct 2008 18:19:52 -0400
Message-ID: <20081007221952.20945.69529.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:52974 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756113AbYJGWct (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 7 Oct 2008 18:32:49 -0400
Received: from svlexrs02.hq.netapp.com (svlexrs02.corp.netapp.com [10.57.156.154])
	by smtp2.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id m97MWk1C025782
	for <linux-nfs@vger.kernel.org>; Tue, 7 Oct 2008 15:32:46 -0700 (PDT)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Most of the following patches are bugfixes:
  There are a couple of spin locking fixes to follow up the BKL removal.
  There are some attribute update fixups, mainly to make the spin
  locking more efficient
  A fix for the problem of autobind on cloned RPC clients

The one feature that has been added is the lookup revalidation mount
option to allow clients to specify that they might not want to cache
negative dentries, and that they might want strict dentry revalidation.

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com
