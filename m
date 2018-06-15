Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.99]:43304 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1755405AbeFORAU (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 15 Jun 2018 13:00:20 -0400
Message-ID: <72750c3dd29740b55bff1b83fb3cc51e43913c13.camel@kernel.org>
Subject: Re: [PATCH 0/5] knfsd miscellaneous cleanup
From: Jeff Layton <jlayton@kernel.org>
To: "J. Bruce Fields" <bfields@redhat.com>, linux-nfs@vger.kernel.org
Date: Fri, 15 Jun 2018 13:00:17 -0400
In-Reply-To: <1529004733-6022-1-git-send-email-bfields@redhat.com>
References: <1529004733-6022-1-git-send-email-bfields@redhat.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 2018-06-14 at 15:32 -0400, J. Bruce Fields wrote:
> From: "J. Bruce Fields" <bfields@redhat.com>
> 
> Some cleanup and one minor bugfix.
> 
> --b.
> 
> J. Bruce Fields (5):
>   nfsd4: less confusing nfsd4_compound_in_session
>   nfsd4: cleanup sessionid in nfsd4_destroy_session
>   nfsd: update obselete comment referencing the BKL
>   nfsd: clarify check_op_ordering
>   nfsd: fix corrupted reply to badly ordered compound
> 
>  fs/nfsd/nfs4proc.c  | 14 ++++++++++----
>  fs/nfsd/nfs4state.c | 20 ++++++++++----------
>  2 files changed, 20 insertions(+), 14 deletions(-)
> 

These also seem reasonable.

Reviewed-by: Jeff Layton <jlayton@kernel.org>
