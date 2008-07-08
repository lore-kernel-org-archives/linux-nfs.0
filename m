From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH] nfsd: take file and mnt write in nfs4_upgrade_open
Date: Tue, 8 Jul 2008 10:35:36 -0400
Message-ID: <20080708143535.GA7032@fieldses.org>
References: <486E18C3.1040703@panasas.com> <1215175121-18665-1-git-send-email-bhalevy@panasas.com> <20080707192543.GG14291@fieldses.org> <48732271.4080206@panasas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: Benny Halevy <bhalevy@panasas.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:33781 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750888AbYGHOfi (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 8 Jul 2008 10:35:38 -0400
In-Reply-To: <48732271.4080206@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Jul 08, 2008 at 11:16:49AM +0300, Benny Halevy wrote:
> On Jul. 07, 2008, 22:25 +0300, "J. Bruce Fields" <bfields@fieldses.org> wrote:
> > Yes, this looks correct, at least for the immediate fix; thanks!
> > 
> > Eventually I think we should move to opening a new file descriptor when
> > upgrading, and keeping two file descriptors with the stateid; I think
> > this business of trying to use a file descriptor for write when we
> > opened it for read is probably wrong.
> 
> That could work, though they need to be associated in some way
> for open_downgrade/close processing.

Yes.  I think it would work just to keep up to one read-only open and
one write-only open and then close one or the other as necessary on the
downgrade.

--b.
