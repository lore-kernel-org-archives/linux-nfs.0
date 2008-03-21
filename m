From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 0/5] Improvements to NFS debugging infrastructure
Date: Fri, 21 Mar 2008 19:01:54 -0400
Message-ID: <20080321230019.23627.89680.stgit@ingres.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: trond.myklebust@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from flpi185.sbcis.sbc.com ([207.115.20.187]:12312 "EHLO
	flpi185.prodigy.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758248AbYCUXCc (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 21 Mar 2008 19:02:32 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Trond-

Last set for now.

Here's a handful of patches that clean up NFS client debugging a little.  The
last patch in the series is optional, but I've found it helpful.  Please
consider these for 2.6.26.

-- 
corporate:    <chuck dot lever at oracle dot com>
