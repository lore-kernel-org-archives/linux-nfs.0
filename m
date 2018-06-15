Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.99]:43152 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754672AbeFOQ6P (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 15 Jun 2018 12:58:15 -0400
Message-ID: <38ae86e328af14b45ee89fae2a4221b8404782db.camel@kernel.org>
Subject: Re: [PATCH 0/2] knfsd change_attr_type & time_delta improvements
From: Jeff Layton <jlayton@kernel.org>
To: "J. Bruce Fields" <bfields@redhat.com>, linux-nfs@vger.kernel.org
Date: Fri, 15 Jun 2018 12:58:12 -0400
In-Reply-To: <1529004093-5866-1-git-send-email-bfields@redhat.com>
References: <1529004093-5866-1-git-send-email-bfields@redhat.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 2018-06-14 at 15:21 -0400, J. Bruce Fields wrote:
> From: "J. Bruce Fields" <bfields@redhat.com>
> 
> Implement change_attr_type, and fix time_delta.
> 
> I don't think the client currently uses either, I'm just assuming
> they'll be useful some day, especially now that (thanks to jlayton) the
> change attribute should be a real change attribute now in the
> IS_I_VERSION() case.
> 
> 
> J. Bruce Fields (2):
>   nfsd: fix NFSv4 time_delta attribute
>   nfsd4: support change_attr_type attribute
> 
>  fs/nfsd/nfs4xdr.c    | 39 ++++++++++++++++++++++++++++++++++++---
>  fs/nfsd/nfsd.h       |  1 +
>  include/linux/nfs4.h |  8 ++++++++
>  3 files changed, 45 insertions(+), 3 deletions(-)
> 

Both look good.

Reviewed-by: Jeff Layton <jlayton@kernel.org>
