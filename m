Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([198.137.202.9]:59583 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751575AbbJKOXs (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 11 Oct 2015 10:23:48 -0400
Date: Sun, 11 Oct 2015 07:23:47 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Anna Schumaker <Anna.Schumaker@netapp.com>
Cc: linux-nfs@vger.kernel.org, linux-btrfs@vger.kernel.org,
        linux-fsdevel@vger.kernel.org, linux-api@vger.kernel.org,
        zab@zabbo.net, viro@zeniv.linux.org.uk, clm@fb.com,
        darrick.wong@oracle.com, mtk.manpages@gmail.com, andros@netapp.com,
        hch@infradead.org
Subject: Re: [PATCH v5 7/9] vfs: Remove copy_file_range mountpoint checks
Message-ID: <20151011142347.GD31867@infradead.org>
References: <1443634014-3026-1-git-send-email-Anna.Schumaker@Netapp.com>
 <1443634014-3026-8-git-send-email-Anna.Schumaker@Netapp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1443634014-3026-8-git-send-email-Anna.Schumaker@Netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Sep 30, 2015 at 01:26:51PM -0400, Anna Schumaker wrote:
> I still want to do an in-kernel copy even if the files are on different
> mountpoints, and NFS has a "server to server" copy that expects two
> files on different mountpoints.  Let's have individual filesystems
> implement this check instead.

NAK.  I thing this is a bad idea in general and will only be convinced
by a properly audited actual implementation.  And even then with a flag
where the file system specificly needs to opt into this behavior instead
of getting it by default.
