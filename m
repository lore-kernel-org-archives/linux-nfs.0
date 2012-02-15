Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:38544 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754387Ab2BOSzr (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 15 Feb 2012 13:55:47 -0500
Date: Wed, 15 Feb 2012 13:55:46 -0500
To: Tigran Mkrtchyan <kofemann@googlemail.com>
Cc: linux-nfs@vger.kernel.org, Tigran Mkrtchyan <kofemann@gmail.com>
Subject: Re: [PATH v9 00/10] handle curruent stateid
Message-ID: <20120215185546.GA14687@fieldses.org>
References: <1329170132-7081-1-git-send-email-tigran.mkrtchyan@desy.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1329170132-7081-1-git-send-email-tigran.mkrtchyan@desy.de>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Feb 13, 2012 at 10:55:22PM +0100, Tigran Mkrtchyan wrote:
> From: Tigran Mkrtchyan <kofemann@gmail.com>
> 
> With Benny's comments.
> 
> This is ready-to-go patch set. Rebased to Bruce's nfsd-next.

All applied.  Thanks again, Tigran!

--b.

> 
> Implemented for:
> 
>  OPEN
>  OPENDOWNGRADE
>  CLOSE
>  LOCK
>  LOCKU
>  DELEGRETURN
>  FREE_STATEID
>  SETATTR
>  READ
>  WRITE
>  SAVEFH
>  RESTOREFH
>  PUTFH
>  PUTROOTFH
>  PUTPUBFH
>  LOOKUP
>  CREATE
> 
> 
> Coresponding pynfs test already submited.
> 
> Tigran.
> Tigran Mkrtchyan (10):
>   nfsd4: initialize current stateid at compile time
>   nfsd41: handle current stateid in open and close
>   nfsd41: handle current stateid on lock and locku
>   nfsd41: consume current stateid on read and write
>   nfsd41: mark PUTFH, PUTPUBFH and PUTROOTFH to clear current stateid
>   nfsd41: save and restore current stateid with current fh
>   nfsd41: mark LOOKUP, LOOKUPP and CREATE to invalidate current stateid
>   nfsd41: handle current stateid in SETATTR and FREE_STATEID
>   nfsd41: consume current stateid on DELEGRETURN and OPENDOWNGRADE
>   nfsd41: use current stateid by value
> 
>  fs/nfsd/current_stateid.h |   28 ++++++++++++
>  fs/nfsd/nfs4proc.c        |   61 +++++++++++++++++++++----
>  fs/nfsd/nfs4state.c       |  107 ++++++++++++++++++++++++++++++++++++++++++++-
>  fs/nfsd/xdr4.h            |   11 +++++
>  4 files changed, 196 insertions(+), 11 deletions(-)
>  create mode 100644 fs/nfsd/current_stateid.h
> 
> -- 
> 1.7.7.6
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
