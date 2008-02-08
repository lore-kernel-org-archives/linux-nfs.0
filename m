From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 00/11] RFC: Kconfig changes for NFS_FS and NFSD
Date: Fri, 08 Feb 2008 12:51:24 -0500
Message-ID: <20080208174437.16261.60381.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from flpi102.sbcis.sbc.com ([207.115.20.71]:7451 "EHLO
	flpi102.prodigy.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753246AbYBHRv2 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 8 Feb 2008 12:51:28 -0500
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Scratching my head to find an appropriate mailing list for review of some
proposed NFS-related Kconfig changes.  These have already seen some light
on linux-nfs, but Herbert Xu suggested lkml for review by Kconfig experts.

In addition to updating the help text, I've tried to untangle the entry
dependencies somewhat.  I'm not really a Kconfig expert, so I'd appreciate
some review of these patches by those more knowlegeable than me.

-- 
corporate:    <chuck dot lever at oracle dot com>
