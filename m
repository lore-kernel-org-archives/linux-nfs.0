From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: connectathon test failures
Date: Wed, 8 Oct 2008 22:03:00 -0400
Message-ID: <20081009020300.GA17896@fieldses.org>
References: <20081008225543.GG14527@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: Trond Myklebust <trond@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:41321 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751595AbYJICDC (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 8 Oct 2008 22:03:02 -0400
In-Reply-To: <20081008225543.GG14527@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Oct 08, 2008 at 06:55:43PM -0400, bfields wrote:
> I'm getting connectathon test failures with the latest merge of code
> from both our trees, linux-to-linux over v3 and v4.
> 
> I just got this a moment ago, so haven't tried to track it down at all
> yet--but I seem to recall in the past this sort of failure has been an
> attribute revalidation problem (usually with the ext3 ctime resolution
> at least partly to blame).

The failure first happens with d65f557f3 "NFS: Fix
nfs_post_op_update_inode_force_wcc()".
 
--b.
