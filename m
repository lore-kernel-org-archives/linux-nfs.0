From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 0/5] RFC: NFS Kconfig clean up
Date: Mon, 04 Feb 2008 19:04:13 -0500
Message-ID: <20080205000045.18602.9168.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: bfields@citi.umich.edu
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from flpi195.sbcis.sbc.com ([207.115.20.197]:27471 "EHLO
	flpi195.prodigy.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756482AbYBEAEQ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 4 Feb 2008 19:04:16 -0500
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Bruce-

Here's a proposal for cleaning up the NFS-related entries in fs/Kconfig.
The last patch is partial, and tries to address the PROC_FS dependency
problems in NFSD.  It also identifies a similar issue with selecting
RPCSEC_GSS_KRB5 from the NFSV4 and NFSD_V4 entries.

These are works-in-progress. 

-- 
corporate:    <chuck dot lever at oracle dot com>
