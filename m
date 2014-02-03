Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qa0-f43.google.com ([209.85.216.43]:57783 "EHLO
	mail-qa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751114AbaBCUpE (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 3 Feb 2014 15:45:04 -0500
Date: Mon, 3 Feb 2014 15:45:00 -0500
From: Tejun Heo <tj@kernel.org>
To: "J. Bruce Fields" <bfields@fieldses.org>, linux-nfs@vger.kernel.org
Cc: Li Zefan <lizefan@huawei.com>, containers@lists.linux-foundation.org,
        cgroups@vger.kernel.org,
        Trond Myklebust <trond.myklebust@primarydata.com>
Subject: Re: [PATCH] nfs: include xattr.h from fs/nfs/nfs3proc.c
Message-ID: <20140203204500.GJ30250@htj.dyndns.org>
References: <20140203193107.GH30250@htj.dyndns.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20140203193107.GH30250@htj.dyndns.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Feb 03, 2014 at 02:31:07PM -0500, Tejun Heo wrote:
> fs/nfs/nfs3proc.c is making use of xattr but was getting linux/xattr.h
> indirectly through linux/cgroup.h, which will soon drop the inclusion
> of xattr.h.  Explicitly include linux/xattr.h from nfs3proc.c so that
> compilation doesn't fail when linux/cgroup.h drops linux/xattr.h.
> 
> As the following cgroup changes will depend on these changes, it
> probably would be easier to route this through cgroup branch.  Would
> that be okay?
> 
> Signed-off-by: Tejun Heo <tj@kernel.org>
> Cc: "J. Bruce Fields" <bfields@fieldses.org>
> Cc: linux-nfs@vger.kernel.org

Applied to cgroup/for-3.14-fixes w/ Trond's ack added.

Thanks.

-- 
tejun
