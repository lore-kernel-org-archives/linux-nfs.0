Return-Path: linux-nfs-owner@vger.kernel.org
Received: from zimbra13.linbit.com ([212.69.166.240]:55819 "EHLO
	zimbra13.linbit.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752030Ab3LLTIk (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 12 Dec 2013 14:08:40 -0500
Date: Thu, 12 Dec 2013 20:08:38 +0100 (CET)
From: Andreas Gruenbacher <andreas.gruenbacher@linbit.com>
To: Christoph Hellwig <hch@infradead.org>
Cc: viro@zeniv.linux.org.uk, linux-fsdevel@vger.kernel.org,
        linux-btrfs@vger.kernel.org, linux-ext4@vger.kernel.org,
        linux-f2fs-devel@lists.sourceforge.net, linux-mtd@lists.infradead.org,
        Mark Fasheh <mfasheh@suse.com>, Joel Becker <jlbec@evilplan.org>,
        reiserfs-devel@vger.kernel.org, xfs@oss.sgi.com,
        jfs-discussion@lists.sourceforge.net, cluster-devel@redhat.com,
        linux-nfs@vger.kernel.org
Message-ID: <966512490.69128.1386875318581.JavaMail.zimbra@linbit.com>
In-Reply-To: <20131211104529.142731540@bombadil.infradead.org>
References: <20131211104243.148113893@bombadil.infradead.org> <20131211104529.142731540@bombadil.infradead.org>
Subject: Re: [PATCH 16/18] gfs2: use generic posix ACL infrastructure
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Christoph,

gfs2 has a left-over get_acl callback in gfs2_symlink_iops in
fs/gfs2/inode.c, from a long time ago, which should be removed
as well.

Andreas
