Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:11575 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752899Ab3GBP3o (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 2 Jul 2013 11:29:44 -0400
Message-ID: <1372778981.2302.5.camel@tlielax.poochiereds.net>
Subject: Re: [PATCH 1/2] rpc_pipe: export simple_dentry_operations and have
 rpc_pipefs use it
From: Jeff Layton <jlayton@redhat.com>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>,
        "J. Bruce Fields" <bfields@fieldses.org>
Date: Tue, 02 Jul 2013 11:29:41 -0400
In-Reply-To: <20130701122201.6a8fc966@tlielax.poochiereds.net>
References: <1372122340-28982-1-git-send-email-jlayton@redhat.com>
	 <1372122340-28982-2-git-send-email-jlayton@redhat.com>
	 <1372174611.5968.28.camel@leira.trondhjem.org>
	 <20130701122201.6a8fc966@tlielax.poochiereds.net>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 2013-07-01 at 12:22 -0400, Jeff Layton wrote:
> On Tue, 25 Jun 2013 15:36:54 +0000
> "Myklebust, Trond" <Trond.Myklebust@netapp.com> wrote:
> 
> > On Mon, 2013-06-24 at 21:05 -0400, Jeff Layton wrote:
> > > ...instead of replicating a copy of them.
> > > 
> > > Signed-off-by: Jeff Layton <jlayton@redhat.com>
> > > ---
> > >  fs/libfs.c            |  9 +++++----
> > >  include/linux/fs.h    |  1 +
> > >  net/sunrpc/rpc_pipe.c | 11 +----------
> > >  3 files changed, 7 insertions(+), 14 deletions(-)
> > > 
> > 
> > Can you please get an ACK from Al on this patch.
> > 
> > Cheers
> >   Trond
> > 
> 
> Al, could you weigh in on this? The only real change to generic VFS
> code is that I'm exporting simple_dentry_operations here.
> 

Trond, I've been unable to get in touch with Al to get him to ACK this.
I'm guessing he's busy getting patches together for the merge window. 

I propose we do this instead:

I'll respin the patch such that sb->s_d_op is set to
rpc_dentry_operations, and we'll just keep those for now. Then, I can
propose a patch later to export simple_dentry_operations and convert
rpc_pipefs to use that afterward (probably for 3.12).

I'll post the respin after I've done a bit of testing...

-- 
Jeff Layton <jlayton@redhat.com>

