Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qg0-f47.google.com ([209.85.192.47]:37176 "EHLO
	mail-qg0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753196AbaEUTOh (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 21 May 2014 15:14:37 -0400
Received: by mail-qg0-f47.google.com with SMTP id j107so3979358qga.34
        for <linux-nfs@vger.kernel.org>; Wed, 21 May 2014 12:14:36 -0700 (PDT)
Date: Wed, 21 May 2014 15:14:34 -0400
From: Jeff Layton <jeff.layton@primarydata.com>
To: "J. Bruce Fields" <bfields@redhat.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH 0/2] fix for find_lockowner_str crash
Message-ID: <20140521151434.3230b9d6@tlielax.poochiereds.net>
In-Reply-To: <1400688325-5345-1-git-send-email-bfields@redhat.com>
References: <1400688325-5345-1-git-send-email-bfields@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 21 May 2014 12:05:23 -0400
"J. Bruce Fields" <bfields@redhat.com> wrote:

> From: "J. Bruce Fields" <bfields@redhat.com>
> 
> This is for 3.15 and stable.
> 
> Jeff, cc'ing you since I seem to recall Trond's series changes to using
> a single lockowner.  I think the following is the quicker fix for
> stable, but you could convince me otherwise.
> 
> J. Bruce Fields (2):
>   nfsd4: remove lockowner when removing lock stateid
>   nfsd4: warn on finding lockowner without stateid's
> 
>  fs/nfsd/nfs4state.c | 15 +++++++++++++--
>  1 file changed, 13 insertions(+), 2 deletions(-)
> 

Looks reasonable as a less invasive fix for stable. I'm still getting
comfortable with the nfsd locking overhaul, so I won't suggest anything
else just yet.

-- 
Jeff Layton <jlayton@primarydata.com>
