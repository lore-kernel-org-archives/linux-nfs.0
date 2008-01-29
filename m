From: Jens Axboe <jens.axboe@oracle.com>
Subject: Re: atimes not updated over NFS
Date: Tue, 29 Jan 2008 21:12:11 +0100
Message-ID: <20080129201211.GY15220@kernel.dk>
References: <20080121210925.GQ17468@fieldses.org> <20080122171717.GD24697@fieldses.org> <20080129025940.GI16785@fieldses.org> <20080129041411.GC1190@fieldses.org> <20080129083402.GN15220@kernel.dk> <20080129182721.GB28032@fieldses.org> <20080129183042.GH15220@kernel.dk> <20080129194508.GG28032@fieldses.org> <20080129195155.GS15220@kernel.dk> <20080129200901.GI28032@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Frank van Maarseveen <frankvm@frankvm.com>,
	Trond Myklebust <trond.myklebust@fys.uio.no>,
	Andre Majorel <aym-xunil-Bi/FLWfhfolQFI55V6+gNQ@public.gmane.org>, linux-nfs@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from brick.kernel.dk ([87.55.233.238]:7725 "EHLO kernel.dk"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753907AbYA2UMQ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 29 Jan 2008 15:12:16 -0500
In-Reply-To: <20080129200901.GI28032@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Jan 29 2008, J. Bruce Fields wrote:
> On Tue, Jan 29, 2008 at 08:51:55PM +0100, Jens Axboe wrote:
> > On Tue, Jan 29 2008, J. Bruce Fields wrote:
> > > Hm.  It's still missing a case.  I've confirmed that the following fixes
> > > the problem.  (Or maybe it would be better to have them "goto" a common
> > > out with the file_accessed() check?)
> > 
> > Indeed it is, insert standard disclaimer here on the evil of multiple
> > returns. So can we agree that this then fixes both cases?
> 
> Yep, thanks!  And I ran one more test just to make sure.  Looks fine.

Super, thanks a lot for testing and confirming! Patch is committed.

-- 
Jens Axboe

