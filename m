Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ig0-f181.google.com ([209.85.213.181]:63010 "EHLO
	mail-ig0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932761AbaDIONA convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 9 Apr 2014 10:13:00 -0400
Received: by mail-ig0-f181.google.com with SMTP id h18so2453951igc.8
        for <linux-nfs@vger.kernel.org>; Wed, 09 Apr 2014 07:13:00 -0700 (PDT)
Content-Type: text/plain; charset=windows-1252
Mime-Version: 1.0 (Mac OS X Mail 7.2 \(1874\))
Subject: Re: commit 1bc49d83c37c (nfsd4: fix nfs4err_resource in 4.1 case)
From: Trond Myklebust <trond.myklebust@primarydata.com>
In-Reply-To: <20140409135625.GA22938@fieldses.org>
Date: Wed, 9 Apr 2014 10:12:58 -0400
Cc: NFS <linux-nfs@vger.kernel.org>
Message-Id: <924781E0-38DB-4623-821C-4FB7C9AF52C8@primarydata.com>
References: <ED8FB66B-E2A5-4BD5-95DE-160C9717D9AB@primarydata.com> <20140409135625.GA22938@fieldses.org>
To: Dr Fields James Bruce <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Apr 9, 2014, at 9:56, Dr Fields James Bruce <bfields@fieldses.org> wrote:

> On Wed, Apr 09, 2014 at 09:41:28AM -0400, Trond Myklebust wrote:
>> According to RFC5661, NFS4ERR_REP_TOO_BIG/NFS4ERR_REP_TOO_BIG_TO_CACHE
>> are only appropriate if "The reply to a Compound would exceed the
>> channel's negotiated maximum response size.”.  Given that the callers
>> of nfsd4_encode_fattr appear to all pass in ‘buffer’ and ‘buflen’
>> arguments that are limited to single page, doesn’t this mean that you
>> can end up returning nfs4err_resource in cases where
>> nfserr_rep_too_big/nfserr_rep_too_big_to_cache are simply not
>> appropriate?
> 
> Yes, you're right.  This will be fixed by later patches which remove
> those arbitrary single-page limits, but for now it's a bug.
> 
> This was probably a bad way to sequence those patches.
> 
> That said, all that patch is doing in those cases is replacing one
> useless error by another, so in practice I don't think reverting the
> patch would help anyone--so I'm inclined to leave this alone and wait
> for the real bug to be fixed (which is that we're imposing limits other
> than the session limits).
> 
> Is this causing some problem right now?
> 

I’m not aware of any bug reports yet, but I did want to make sure that it was on your radar.

That said, one immediate consequence of this patch will be that NFSv4.1 clients will now report EIO instead of EREMOTEIO if they hit the problem. That may make debugging a little less obvious.
Another consequence will be that if we ever do try to add client side handling of NFS4ERR_REP_TOO_BIG, then we now have to deal with the “handle existing buggy server” syndrome.

>> Either way, the NFS client will handle this badly. There is no
>> recovery for NFS4ERR_RESOURCE. and we do not ever expect to hit
>> NFSERR_REP_TOO_BIG/TOO_BIG_TO_CACHE. The latter two can presumably
>> only be recovered by renegotiating the session and then retrying the
>> request, which won’t work here...
> 
> 

_________________________________
Trond Myklebust
Linux NFS client maintainer, PrimaryData
trond.myklebust@primarydata.com

