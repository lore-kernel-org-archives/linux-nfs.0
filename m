From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH 0/2] fix nfsd stateid encoding
Date: Mon, 11 Aug 2008 17:09:36 +0300
Message-ID: <48A04820.5000409@panasas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: NFS list <linux-nfs@vger.kernel.org>,
	pNFS Mailing List <pnfs@linux-nfs.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from wf-out-1314.google.com ([209.85.200.172]:54040 "EHLO
	wf-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753637AbYHKOJn (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 11 Aug 2008 10:09:43 -0400
Received: by wf-out-1314.google.com with SMTP id 27so3985625wfd.4
        for <linux-nfs@vger.kernel.org>; Mon, 11 Aug 2008 07:09:42 -0700 (PDT)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Bruce, in a couple locations the nfsd needs to encode the stateid.seqid
as a uint32_t rather than as opaque.

Patch #1 fixes that for cb_recall.
Patch #2 fixes the deleg stateid returned by open.

The patches should apply to linux-2.6/master 
commit 796aadeb1b2db9b5d463946766c5bbfd7717158c

Benny
