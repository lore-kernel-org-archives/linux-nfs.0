Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([198.137.202.9]:58039 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750876AbbJSVD2 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 19 Oct 2015 17:03:28 -0400
Date: Mon, 19 Oct 2015 14:03:22 -0700
From: Christoph Hellwig <hch@infradead.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Christoph Hellwig <hch@infradead.org>,
        Anna Schumaker <Anna.Schumaker@netapp.com>, linux-nfs@vger.kernel.org,
        linux-btrfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-api@vger.kernel.org, zab@zabbo.net, viro@zeniv.linux.org.uk,
        clm@fb.com, darrick.wong@oracle.com, mtk.manpages@gmail.com,
        andros@netapp.com
Subject: Re: [PATCH v6 5/4] copy_file_range.2: New page documenting
 copy_file_range()
Message-ID: <20151019210322.GA2420@infradead.org>
References: <1445029707-31549-1-git-send-email-Anna.Schumaker@Netapp.com>
 <1445029707-31549-6-git-send-email-Anna.Schumaker@Netapp.com>
 <20151018183013.GA11200@infradead.org>
 <20151019204503.GA15214@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20151019204503.GA15214@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Oct 19, 2015 at 04:45:03PM -0400, J. Bruce Fields wrote:
> So, continue to include a "flags" field but just error out if it's
> anything but zero for now?

Exactly!
