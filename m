Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([198.137.202.9]:43497 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752747AbbJZDjd (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 25 Oct 2015 23:39:33 -0400
Date: Sun, 25 Oct 2015 20:39:25 -0700
From: Christoph Hellwig <hch@infradead.org>
To: P??draig Brady <P@draigBrady.com>
Cc: Anna Schumaker <Anna.Schumaker@netapp.com>, linux-nfs@vger.kernel.org,
        linux-btrfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-api@vger.kernel.org, zab@zabbo.net, viro@zeniv.linux.org.uk,
        clm@fb.com, darrick.wong@oracle.com, mtk.manpages@gmail.com,
        andros@netapp.com, hch@infradead.org
Subject: Re: [PATCH v7 5/4] copy_file_range.2: New page documenting
 copy_file_range()
Message-ID: <20151026033925.GA9945@infradead.org>
References: <1445628736-13058-1-git-send-email-Anna.Schumaker@Netapp.com>
 <1445628736-13058-6-git-send-email-Anna.Schumaker@Netapp.com>
 <562B734D.50800@draigBrady.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=unknown-8bit
In-Reply-To: <562B734D.50800@draigBrady.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, Oct 24, 2015 at 01:02:21PM +0100, P??draig Brady wrote:
> I'm a bit worried about the sparse expansion and default reflinking
> which might preclude cp(1) from using this call in most cases, but I will
> test and try to use it. coreutils has heuristics for determining if files
> are remote, which we might use to restrict to that use case.

Can you explain why reflinking and hole expansion are an issue if done
locally and not if done remotely?  I'd really like to make the call as
usable as possible for everyone, but we really need clear semåntics for
that.

Also note that Annas current series allows for hole filling - any decent
implementation should not do them, but that's really a quality of
implementation and not an interface issue.
