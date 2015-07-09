Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:59666 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751125AbbGINwq (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 9 Jul 2015 09:52:46 -0400
Date: Thu, 9 Jul 2015 09:52:46 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: Kinglong Mee <kinglongmee@gmail.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 1/3] nfsd: Set lc_size_chg before ops->proc_layoutcommit
Message-ID: <20150709135246.GA29703@fieldses.org>
References: <559B3573.4090307@gmail.com>
 <20150708184431.GB19084@fieldses.org>
 <20150709080419.GA19291@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20150709080419.GA19291@infradead.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Jul 09, 2015 at 01:04:20AM -0700, Christoph Hellwig wrote:
> On Wed, Jul 08, 2015 at 02:44:31PM -0400, J. Bruce Fields wrote:
> > On Tue, Jul 07, 2015 at 10:12:03AM +0800, Kinglong Mee wrote:
> > > After proc_layoutcommit success, i_size_read(inode) always >= new_size.
> > > Just set lc_size_chg before proc_layoutcommit, if proc_layoutcommit
> > > failed, nfsd will skip the lc_size_chg, so it's no harm.
> > 
> > Looks right to me, though could probably use an ACK from Christoph.
> > 
> > (But looking at the spec I'm confused about how the client is supposed
> > to use this information.)
> 
> I don;t think its possible to use, as there it is inherently racy.
> 
> If the test passes xfstests I'm fine with it.

OK, thanks.--b.
