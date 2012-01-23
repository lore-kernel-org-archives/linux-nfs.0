Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:41080 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754236Ab2AWVMr (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 23 Jan 2012 16:12:47 -0500
Date: Mon, 23 Jan 2012 16:12:47 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Tigran Mkrtchyan <kofemann@googlemail.com>
Cc: linux-nfs@vger.kernel.org, Tigran Mkrtchyan <kofemann@gmail.com>
Subject: Re: [PATH v7 00/10] handle curruent stateid
Message-ID: <20120123211247.GA1452@fieldses.org>
References: <1327257968-14522-1-git-send-email-tigran.mkrtchyan@desy.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1327257968-14522-1-git-send-email-tigran.mkrtchyan@desy.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, Jan 22, 2012 at 07:45:59PM +0100, Tigran Mkrtchyan wrote:
> From: Tigran Mkrtchyan <kofemann@gmail.com>
> 
> The same as v6, expect that the last patch changes current_stateid 
> in compoind from reference to a value. As patches have to be squashed
> anyway

Why?

If it's really only possible as a single big patch I'd actually rather
have it submitted that way....

> this aproach is simple that re-write all.

Fine, but #10 doesn't seem to have made it to my mailbox or to the list?

--b.

> 
> This is ready-to-go patch set. Rebased to Bruce's nfsd-next.
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
> 
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
>  fs/nfsd/current_stateid.h |   28 +++++++++++
>  fs/nfsd/nfs4proc.c        |   61 +++++++++++++++++++++----
>  fs/nfsd/nfs4state.c       |  110 ++++++++++++++++++++++++++++++++++++++++++++-
>  fs/nfsd/xdr4.h            |    4 ++
>  4 files changed, 192 insertions(+), 11 deletions(-)
>  create mode 100644 fs/nfsd/current_stateid.h
> 
> -- 
> 1.7.7.5
> 
