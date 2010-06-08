Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:4879 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750743Ab0FHETn (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 8 Jun 2010 00:19:43 -0400
Received: from localhost.localdomain (navitha-lxp.hq.netapp.com [10.58.53.227] (may be forged))
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id o584JOPp014203
	for <linux-nfs@vger.kernel.org>; Mon, 7 Jun 2010 21:19:25 -0700 (PDT)
From: Fred Isaman <iisaman@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 00/24] LAYOUTGET invocation (rebased) 
Date: Tue,  8 Jun 2010 00:18:57 -0400
Message-Id: <1275970761-31806-1-git-send-email-iisaman@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

This patch series limits LAYOUTGET invocation to the beginning of the
IO paths.  It applies atop Alexandros's recent patchset submission,
but is otherwise basically the same as the previous submission.  It is
intended for the pnfs_submit branch, without reversion in a
post_submit branch.

Patches 1-4 revert direct IO.  Commit is already broken, and this
series breaks them further.  The problem is that the direct IO
redefines data->wb_req and data->pages, so that it can only work with
the pnfs code if we don't look at those fields. The reverted code
should be saved somewhere.  I tend to agree with Boaz that keeping it
in git is preferable, but I can supply a patch which returns the code
ifdef'ed out if tht is preferred.

Patches 5-9 do some code cleanup in preperation for the real work.

Patches 10-21 implement the change.  NOTE that patch 20 changes the
calling convention of the layout drivers commit calls.  There is no
longer a universal lseg for the commit, instead each nfs_page has an
lseg attached, with NULL meaning to go through the MDS.

Patches 21-24 rework the filelayout commit function, and then do some
code cleanup this enables.



The basic idea of these patches is as follows:

We attempt to grab a lseg (possibly invoking LAYOUTGET) early in the
IO.  If we succeed, we refcount and stash it, using it through the
rest of the io.  If we fail, we revert to straight nfs, even if the
area becomes covered by a layout due to other io.

The tricky, though hopefully anomalous, case is when we start without
the layout, but have it at this particular stage of the IO.  We ignore
this for the moment at write_pages, which will cause block and object
to issue CB_LAYOUTRECALL.  At commit, it is tricky to handle, but
since block doesn't use commit, and file needs to handle complicated
splitting anyway, I just push all complicated decisions of splitting
commit between nfs (for IO started without layout) and pnfs to the
driver.

Fred

