Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-yw0-f171.google.com ([209.85.161.171]:33246 "EHLO
	mail-yw0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751562AbcFPLtL (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 16 Jun 2016 07:49:11 -0400
Received: by mail-yw0-f171.google.com with SMTP id g20so40343749ywb.0
        for <linux-nfs@vger.kernel.org>; Thu, 16 Jun 2016 04:49:10 -0700 (PDT)
Message-ID: <1466077747.3079.0.camel@redhat.com>
Subject: Re: [PATCH v3 0/3] Deal with lost delegations and EKEYEXPIRED
From: Jeff Layton <jlayton@redhat.com>
To: Andrew Elble <aweits@rit.edu>, linux-nfs@vger.kernel.org,
        bfields@fieldses.org
Date: Thu, 16 Jun 2016 07:49:07 -0400
In-Reply-To: <1466009529-3421-1-git-send-email-aweits@rit.edu>
References: <1466009529-3421-1-git-send-email-aweits@rit.edu>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 2016-06-15 at 12:52 -0400, Andrew Elble wrote:
> The majority of our lost delegation problems come from the inability
> to return the delegations when the credentials that obtained them
> have expired (conundrum mentioned in RFC 5661 18.35.3)
> 
> ObMemoryJog:
> 
> http://www.spinics.net/lists/linux-nfs/msg56230.html
> 
> v3: removal of OP_IS_PUTFH_LIKE checks
>     added clarification of addressing the conundrum
> 
> Andrew Elble (3):
>   nfs/nfsd: Move useful bitfield ops to a commonly accessible place
>   nfsd: allow mach_creds_match to be used more broadly
>   nfsd: implement machine credential support for some operations
> 
>  fs/nfsd/export.c        | 10 ++++++++++
>  fs/nfsd/nfs4proc.c      | 39 +++++++++++++++++++++++++++++++++++++
>  fs/nfsd/nfs4state.c     | 32 ++++++++++++++++++++++++-------
>  fs/nfsd/nfs4xdr.c       | 51 ++++++++++++++++++++++-----------------
> ----------
>  fs/nfsd/nfsd.h          |  5 +++++
>  fs/nfsd/state.h         |  1 +
>  fs/nfsd/xdr4.h          |  5 +++++
>  include/linux/nfs4.h    | 11 +++++++++++
>  include/linux/nfs_xdr.h | 11 -----------
>  9 files changed, 119 insertions(+), 46 deletions(-)
> 

All look good to me.

Reviewed-by: Jeff Layton <jlayton@redhat.com>
