Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:47611 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755294AbbIVLti (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 22 Sep 2015 07:49:38 -0400
Date: Tue, 22 Sep 2015 13:48:43 +0200
From: David Sterba <dsterba@suse.cz>
To: Anna Schumaker <Anna.Schumaker@netapp.com>
Cc: linux-nfs@vger.kernel.org, linux-btrfs@vger.kernel.org,
        linux-fsdevel@vger.kernel.org, linux-api@vger.kernel.org,
        zab@zabbo.net, viro@zeniv.linux.org.uk, clm@fb.com,
        darrick.wong@oracle.com, mtk.manpages@gmail.com, andros@netapp.com,
        hch@infradead.org
Subject: Re: [PATCH v2 5/9] vfs: Copy shouldn't forbid ranges inside the same
 file
Message-ID: <20150922114843.GH8891@twin.jikos.cz>
Reply-To: dsterba@suse.cz
References: <1442003423-6884-1-git-send-email-Anna.Schumaker@Netapp.com>
 <1442003423-6884-6-git-send-email-Anna.Schumaker@Netapp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1442003423-6884-6-git-send-email-Anna.Schumaker@Netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Sep 11, 2015 at 04:30:18PM -0400, Anna Schumaker wrote:
> This is perfectly valid for BTRFS and XFS, so let's leave this up to
> filesystems to check.
> 
> Signed-off-by: Anna Schumaker <Anna.Schumaker@Netapp.com>

For the btrfs part,

Reviewed-by: David Sterba <dsterba@suse.com>
