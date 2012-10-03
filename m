Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:26920 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755607Ab2JCNkj (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 3 Oct 2012 09:40:39 -0400
Date: Wed, 3 Oct 2012 09:40:35 -0400
From: Jeff Layton <jlayton@redhat.com>
To: Scott Lovenberg <scott.lovenberg@gmail.com>
Cc: steved@redhat.com, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 7/6] nfsdcltrack: add a legacy transition mechanism
Message-ID: <20121003094035.1f7245a4@tlielax.poochiereds.net>
In-Reply-To: <CAFB9KM1xNQYJFS=hE=cFdTkZE9Da8qfhYRLSEJ2xVvwWzxJo1Q@mail.gmail.com>
References: <1349092365-23920-1-git-send-email-jlayton@redhat.com>
	<1349268173-16574-1-git-send-email-jlayton@redhat.com>
	<CAFB9KM1xNQYJFS=hE=cFdTkZE9Da8qfhYRLSEJ2xVvwWzxJo1Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 3 Oct 2012 09:34:36 -0400
Scott Lovenberg <scott.lovenberg@gmail.com> wrote:

> On Wed, Oct 3, 2012 at 8:42 AM, Jeff Layton <jlayton@redhat.com> wrote:
> [snip]
> > +               /* if there's a problem, then skip this entry */
> > +               if (len < 0 || (size_t)len >= sizeof(blob)) {
> > +                       xlog(L_WARNING, "%s: unable to build filename for %s!",
> > +                               __func__, entry->d_name);
> > +                       continue;
> > +               }
> 
> Is a len == 0 not a problem?
> 

I'm not sure -- under what circumstances would it return 0?

-- 
Jeff Layton <jlayton@redhat.com>
