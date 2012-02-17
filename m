Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:56980 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751769Ab2BQWFu (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 17 Feb 2012 17:05:50 -0500
Date: Fri, 17 Feb 2012 17:05:49 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Tigran Mkrtchyan <kofemann@googlemail.com>
Cc: linux-nfs@vger.kernel.org, Tigran Mkrtchyan <kofemann@gmail.com>
Subject: Re: [PATH v8 00/10] handle curruent stateid
Message-ID: <20120217220549.GA3551@fieldses.org>
References: <1328461679-4108-1-git-send-email-tigran.mkrtchyan@desy.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1328461679-4108-1-git-send-email-tigran.mkrtchyan@desy.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, Feb 05, 2012 at 06:07:49PM +0100, Tigran Mkrtchyan wrote:
> From: Tigran Mkrtchyan <kofemann@gmail.com>
> 
> This is ready-to-go patch set. Rebased to Bruce's nfsd-next.

These are all applied and pushed out to for-3.4 now, thanks.

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
