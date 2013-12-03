Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:38957 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752372Ab3LCKtA (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 3 Dec 2013 05:49:00 -0500
Date: Tue, 3 Dec 2013 02:48:54 -0800
From: Christoph Hellwig <hch@infradead.org>
To: Jan Kara <jack@suse.cz>
Cc: Christoph Hellwig <hch@infradead.org>, viro@zeniv.linux.org.uk,
        linux-fsdevel@vger.kernel.org, linux-btrfs@vger.kernel.org,
        linux-ext4@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net,
        linux-mtd@lists.infradead.org, Mark Fasheh <mfasheh@suse.com>,
        Joel Becker <jlbec@evilplan.org>, reiserfs-devel@vger.kernel.org,
        xfs@oss.sgi.com, jfs-discussion@lists.sourceforge.net,
        cluster-devel@redhat.com, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 12/18] ocfs2: use generic posix ACL infrastructure
Message-ID: <20131203104854.GA3223@infradead.org>
References: <20131201115903.910559036@bombadil.infradead.org>
 <20131201120655.852590677@bombadil.infradead.org>
 <20131202230007.GK12253@quack.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20131202230007.GK12253@quack.suse.cz>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Dec 03, 2013 at 12:00:07AM +0100, Jan Kara wrote:
>   Hum, this changes the cluster locking. Previously ocfs2_acl_get() used
> from ocfs2_acl_chmod() grabbed cluster wide inode lock. Now getting of ACL
> isn't protected by the inode lock. That being said the cluster locking
> around setattr looks fishy anyway - if two processes on different
> nodes are changing attributes of the same file, changing ACLs post fact
> after dropping inode lock could cause interesting effects. Also I'm
> wondering how inode_change_ok() can ever be safe without holding inode
> lock... Until we grab that other node is free to change e.g. owner of the
> inode thus leading even to security implications. But maybe I'm missing
> something. Mark, Joel?

Hmm, indeed.  How does ocfs2_iop_get_acl get away without that lock?

Btw, ocfs2 changes will need careful testing as I couldn't find any easy
way to run xfstests on ocfs2 out of the box.

