Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:4568 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934326AbaFTMvn (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 20 Jun 2014 08:51:43 -0400
Date: Fri, 20 Jun 2014 08:51:40 -0400
From: Scott Mayhew <smayhew@redhat.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH RFC] nfs: ensure cached data is correct before using
 delegation
Message-ID: <20140620125140.GH4510@tonberry.usersys.redhat.com>
References: <1402683488-23725-1-git-send-email-smayhew@redhat.com>
 <1402683488-23725-2-git-send-email-smayhew@redhat.com>
 <CAABAsM5kJFJK_-VwL4bB4ZUvpdx4pFEYqXKN1S7KqdF6=Xc76g@mail.gmail.com>
 <20140617210439.GC4510@tonberry.usersys.redhat.com>
 <CAHQdGtS=jTwzh+Q7WHy5Bg=vqXXsJvLK+O3-r55bq58DXNiZrQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <CAHQdGtS=jTwzh+Q7WHy5Bg=vqXXsJvLK+O3-r55bq58DXNiZrQ@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 17 Jun 2014, Trond Myklebust wrote:

> On Tue, Jun 17, 2014 at 5:04 PM, Scott Mayhew <smayhew@redhat.com> wrote:
> >
> > I did some more digging and I think I see 2 areas that could be
> > improved.
> >
> > The first would be to clear NFS_INO_INVALID_DATA if we've just
> > truncated the inode to 0 bytes -- after all, if we've just unmapped
> > all the pages from the inode's address space then isn't our data
> > consisitent?:
> 
> What say we rather just don't set/clear NFS_INO_INVALID_DATA if
> mapping->nrpages == 0? That should catch the above case, plus a couple
> of other potential false positives.
> 

That'd be fine too, but I'm not clear on whether I should do this check
for all files or just for regular files (I'm not sure how it would make
that big a difference for directory inodes for instance).

-Scott
