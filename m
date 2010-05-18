From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 7/8] pnfs-submit: forgetful client model
Date: Tue, 18 May 2010 10:16:33 -0400
Message-ID: <20100518141633.GA17823@fieldses.org>
References: <1274119004-30213-1-git-send-email-batsakis@netapp.com> <1274119004-30213-2-git-send-email-batsakis@netapp.com> <1274119004-30213-3-git-send-email-batsakis@netapp.com> <1274119004-30213-4-git-send-email-batsakis@netapp.com> <1274119004-30213-5-git-send-email-batsakis@netapp.com> <1274119004-30213-6-git-send-email-batsakis@netapp.com> <1274119004-30213-7-git-send-email-batsakis@netapp.com> <1274119004-30213-8-git-send-email-batsakis@netapp.com> <20100517203851.GB5232@fieldses.org> <297C26EA-E5A1-411F-BC2B-76228887EE90@netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: bhalevy@panasas.com, linux-nfs@vger.kernel.org
To: Alexandros Batsakis <batsakis@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:60775 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753310Ab0EROQh (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 18 May 2010 10:16:37 -0400
In-Reply-To: <297C26EA-E5A1-411F-BC2B-76228887EE90@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, May 17, 2010 at 05:06:09PM -0700, Alexandros Batsakis wrote:
> Sure, I ll add the stuff below to the wiki and to the Documention folder.

Thanks!  Looks good.

> a) if stateid.seqid is not the expected one return NFS4ERR_DELAY.
> b) we set the specific segments as not valid (no more I/O to them)
> c) if there is pending I/O we return NFS4ERR_DELAY.

Up to you whether it's worth documenting, but: I remember there being
some disagreement about this, but don't remember the resolution.

> d) we return NFS4ERR_NOMATCHING_LAYOUT
> 
> Here you can find a simple flowchart that highlights the description above.
> https://docs.google.com/leaf?id=0B9egH40ld0WsMjg0ZmYzMTQtNDY5NC00ZjRjLTkwNzktNjFhZDFhYjJjYmFj&hl=en

That URL doesn't work for me.

--b.
