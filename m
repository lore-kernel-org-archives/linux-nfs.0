Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:41940 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752079Ab3KCKOn (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 3 Nov 2013 05:14:43 -0500
Date: Sun, 3 Nov 2013 05:14:38 -0500
From: Jeff Layton <jlayton@redhat.com>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        "dpquigl@davequigley.com" <dpquigl@davequigley.com>
Subject: Re: [PATCH] nfs: set security label when revalidating inode
Message-ID: <20131103051438.3a4db316@tlielax.poochiereds.net>
In-Reply-To: <C85EF88C-B4F8-484C-A00D-5A86ACB61C10@netapp.com>
References: <1383389838-1858-1-git-send-email-jlayton@redhat.com>
	<C85EF88C-B4F8-484C-A00D-5A86ACB61C10@netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=Windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, 3 Nov 2013 02:23:29 +0000
"Myklebust, Trond" <Trond.Myklebust@netapp.com> wrote:

> 
> On Nov 2, 2013, at 6:57, Jeff Layton <jlayton@redhat.com> wrote:
> 
> > Currently, we fetch the security label when revalidating an inode's
> > attributes, but don't apply it. This is in contrast to the readdir()
> > codepath where we do apply label changes.
> 
> OK. Why should we not just throw out the code that fetches the security label here?
> 
> IOW: what is the caching model that is being implemented in this patch; is it just “fetch label at random intervals” or is there real method to the madness?
> 
> Trond

I think that we should apply the new security label as soon as we
realize that it has changed. Why should we treat the security label
differently from any other inode attribute (e.g. ownership or mode)?

-- 
Jeff Layton <jlayton@redhat.com>
