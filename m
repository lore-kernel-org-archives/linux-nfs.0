From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 0/8] RFC: Kconfig updates and fixes for NFS
Date: Thu, 14 Feb 2008 15:57:56 -0500
Message-ID: <20080214205121.11765.44857.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from flpi185.sbcis.sbc.com ([207.115.20.187]:15558 "EHLO
	flpi185.prodigy.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1765861AbYBNU6A (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 14 Feb 2008 15:58:00 -0500
Received: from manray.1015granger.net (adsl-76-241-169-38.dsl.sfldmi.sbcglobal.net [76.241.169.38])
	by flpi185.prodigy.net (8.13.8 out.dk.spool/8.13.8) with ESMTP id m1EKvvLI009056
	for <linux-nfs@vger.kernel.org>; Thu, 14 Feb 2008 12:57:58 -0800
Received: from manray.1015granger.net (manray.1015granger.net [127.0.0.1])
	by manray.1015granger.net (8.14.1/8.14.1) with ESMTP id m1EKvuEo011787
	for <linux-nfs@vger.kernel.org>; Thu, 14 Feb 2008 15:57:57 -0500
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Another Request For Comments.

This series updates the help text and dependencies for NFS and SUNRPC-related
entries in fs/Kconfig.

I've attempted to address recent concerns with some new changes.  The PROC_FS
related patches have been split to identify acceptable changes and changes
which need further refinement.  I've proposed a new patch which attempts to
address the problem with selecting visible entries that have dependencies.
I've replaced the patch which added a dependency between SYSCTL and LOCKD.
And, any patches which Bruce has already accepted have been culled from this
series.

-- 
corporate:    <chuck dot lever at oracle dot com>
