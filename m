Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([198.137.202.9]:45403 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752060AbbJNS0A (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 14 Oct 2015 14:26:00 -0400
Date: Wed, 14 Oct 2015 11:25:59 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Anna Schumaker <Anna.Schumaker@netapp.com>
Cc: Christoph Hellwig <hch@infradead.org>, linux-nfs@vger.kernel.org,
        linux-btrfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-api@vger.kernel.org, zab@zabbo.net, viro@zeniv.linux.org.uk,
        clm@fb.com, darrick.wong@oracle.com, mtk.manpages@gmail.com,
        andros@netapp.com
Subject: Re: [PATCH v5 7/9] vfs: Remove copy_file_range mountpoint checks
Message-ID: <20151014182559.GB31225@infradead.org>
References: <1443634014-3026-1-git-send-email-Anna.Schumaker@Netapp.com>
 <1443634014-3026-8-git-send-email-Anna.Schumaker@Netapp.com>
 <20151011142347.GD31867@infradead.org>
 <561E93C3.2090507@Netapp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <561E93C3.2090507@Netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Oct 14, 2015 at 01:41:23PM -0400, Anna Schumaker wrote:
> > NAK.  I thing this is a bad idea in general and will only be convinced
> > by a properly audited actual implementation.  And even then with a flag
> > where the file system specificly needs to opt into this behavior instead
> > of getting it by default.
> > 
> 
> So I should drop this patch even with the pagecache copy?  Andy
> Adamson will have to add it in later as part of his server-to-server patches.

Yes.  Let him do the proof it works alright then.
