Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ig0-f182.google.com ([209.85.213.182]:41908 "EHLO
	mail-ig0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752203AbaC2UBT convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 29 Mar 2014 16:01:19 -0400
Received: by mail-ig0-f182.google.com with SMTP id uy17so2133696igb.3
        for <linux-nfs@vger.kernel.org>; Sat, 29 Mar 2014 13:01:18 -0700 (PDT)
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 7.2 \(1874\))
Subject: Re: [PATCH 2/2] nfsd: Don't return NFS4ERR_RESTOREFH for NFSv4.1+
From: Trond Myklebust <trond.myklebust@primarydata.com>
In-Reply-To: <CDBA9E4B-1C09-4952-B285-83B1580397D7@primarydata.com>
Date: Sat, 29 Mar 2014 16:01:15 -0400
Cc: Idan Kedar <idank@primarydata.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <54B21F4C-18EC-45B9-B89C-DD05A0922DDE@primarydata.com>
References: <1396118619-12771-1-git-send-email-trond.myklebust@primarydata.com> <1396118619-12771-2-git-send-email-trond.myklebust@primarydata.com> <20140329193456.GE11085@fieldses.org> <CDBA9E4B-1C09-4952-B285-83B1580397D7@primarydata.com>
To: Dr Fields James Bruce <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Mar 29, 2014, at 15:49, Trond Myklebust <trond.myklebust@primarydata.com> wrote:

> 
> On Mar 29, 2014, at 15:34, J. Bruce Fields <bfields@fieldses.org> wrote:
> 
>> On Sat, Mar 29, 2014 at 02:43:39PM -0400, Trond Myklebust wrote:
>>> RFC5661 obsoletes NFS4ERR_RESTOREFH in favour of NFS4ERR_NOFILEHANDLE.
>> 
>> Looks right.  Any objection to just making this nfserr_restorefh in the
>> 4.0 case as well?  Hard to imagine how that could cause a 4.0 client any
>> problem.
> 
> You mean make both cases return nfserr_nofilehandle (as per RFC5661), right? So, I agree that most clients should handle that, but the problem is that RFC3530bis does not allow it.

Either way, this is not a performance critical issue. Any time we get into this situation, it is because the client is utterly screwed up in the first place.

The NFS4ERR_STALE_STATEID is the critical one that really needs to be applied...

_________________________________
Trond Myklebust
Linux NFS client maintainer, PrimaryData
trond.myklebust@primarydata.com

