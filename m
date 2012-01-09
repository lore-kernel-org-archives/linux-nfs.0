Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:51543 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933483Ab2AIW4U (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 9 Jan 2012 17:56:20 -0500
Date: Mon, 9 Jan 2012 17:56:19 -0500
To: Tigran Mkrtchyan <kofemann@googlemail.com>
Cc: linux-nfs@vger.kernel.org, Tigran Mkrtchyan <kofemann@gmail.com>
Subject: Re: [PATH v5 0/8] process current stateid
Message-ID: <20120109225619.GA17604@fieldses.org>
References: <1325843116-20570-1-git-send-email-tigran.mkrtchyan@desy.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1325843116-20570-1-git-send-email-tigran.mkrtchyan@desy.de>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Jan 06, 2012 at 10:45:08AM +0100, Tigran Mkrtchyan wrote:
> From: Tigran Mkrtchyan <kofemann@gmail.com>
> 
> Yet another update (v5) of current stateid handling
> 
> re-based to Benny's git branch pnfs-all-latest ( to include PNFS operations ) 
> 
> Includes a patch from Bruce f32f3c2d3f09a586349ca9180885dc8741290fd9
> 
> I have tested:
> 
> OPEN+READ+CLOSE
> OPEN+WRITE+CLOSE
> OPEN+LOCK+WRITE+LOCKU+CLOSE
> OPEN+PUTROOTFH+CLOSE

Thanks, Tigran!

How far are we from being done?  I think some more operations still need
handling (as in e.g.

	http://article.gmane.org/gmane.linux.nfs/45593/match=current+stateid

).

I don't think we have to have pynfs tests for every single of of those,
as they're mostly pretty similar.

When it's ready to be merged, I'd like it rebased on my tree
(git://linux-nfs.org/~bfields/linux.git, for-next branch is fine),
without any of the pNFS bits initially.

--b.


> 
> 
> implemented but not tested
> OPEN+LAYOUTGET
> 
> Tigran.
> 
> Tigran Mkrtchyan (8):
>   nfsd4: initialize special stateid's at compile time
>   nfsd41: handle current stateid in open and close
>   nfsd41: handle current stateid on lock and locku
>   nfsd41: consume current stateid on read and write
>   nfsd41: mark PUTFH, PUTPUBFH and PUTROOTFH to clear current stateid
>   nfsd41: save and restore current stateid with current fh
>   nfsd41: mark LOOKUP, LOOKUPP and CREATE to invalidate current stateid
>   nfsv41: handle current stateid on LAYOUTGET
> 
>  fs/nfsd/current_stateid.h |   23 +++++++++++
>  fs/nfsd/nfs4proc.c        |   53 ++++++++++++++++++++-----
>  fs/nfsd/nfs4state.c       |   95 ++++++++++++++++++++++++++++++++++++++++++--
>  fs/nfsd/xdr4.h            |    2 +
>  4 files changed, 158 insertions(+), 15 deletions(-)
>  create mode 100644 fs/nfsd/current_stateid.h
> 
> -- 
> 1.7.7.5
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
