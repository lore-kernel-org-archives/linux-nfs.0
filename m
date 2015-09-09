Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:36452 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754643AbbIIIkA (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 9 Sep 2015 04:40:00 -0400
Date: Wed, 9 Sep 2015 10:39:11 +0200
From: David Sterba <dsterba@suse.cz>
To: Anna Schumaker <Anna.Schumaker@netapp.com>
Cc: linux-nfs@vger.kernel.org, linux-btrfs@vger.kernel.org,
        linux-fsdevel@vger.kernel.org, linux-api@vger.kernel.org,
        zab@zabbo.net, viro@zeniv.linux.org.uk, clm@fb.com,
        darrick.wong@oracle.com, mtk.manpages@gmail.com, andros@netapp.com,
        hch@infradead.org
Subject: Re: [PATCH v1 3/8] btrfs: add .copy_file_range file operation
Message-ID: <20150909083911.GC8891@twin.jikos.cz>
Reply-To: dsterba@suse.cz
References: <1441397823-1203-1-git-send-email-Anna.Schumaker@Netapp.com>
 <1441397823-1203-4-git-send-email-Anna.Schumaker@Netapp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1441397823-1203-4-git-send-email-Anna.Schumaker@Netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Sep 04, 2015 at 04:16:57PM -0400, Anna Schumaker wrote:
> From: Zach Brown <zab@redhat.com>
> 
> This rearranges the existing COPY_RANGE ioctl implementation so that the
> .copy_file_range file operation can call the core loop that copies file
> data extent items.
> 
> The extent copying loop is lifted up into its own function.  It retains
> the core btrfs error checks that should be shared.
> 
> Signed-off-by: Zach Brown <zab@redhat.com>
> Signed-off-by: Anna Schumaker <Anna.Schumaker@Netapp.com>

Reviewed-by: David Sterba <dsterba@suse.com>
