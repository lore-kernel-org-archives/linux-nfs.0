Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:49471 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755855AbaDGWcL (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 7 Apr 2014 18:32:11 -0400
Date: Tue, 8 Apr 2014 00:32:09 +0200
From: Jan Kara <jack@suse.cz>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: Jan Kara <jack@suse.cz>, Brown Neil <neilb@suse.de>,
        Viro Alexander <viro@zeniv.linux.org.uk>,
        NFS <linux-nfs@vger.kernel.org>
Subject: Re: NFS deadlock between 'sync' and commit after unmount....
Message-ID: <20140407223209.GA1125@quack.suse.cz>
References: <20140407135001.56ef9f36@notabene.brown>
 <F59673DE-8047-4FE0-AFF9-6A3DC37348A5@primarydata.com>
 <20140407202750.GE23670@quack.suse.cz>
 <1396908542.5563.12.camel@leira.trondhjem.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1396908542.5563.12.camel@leira.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon 07-04-14 18:09:02, Trond Myklebust wrote:
> On Mon, 2014-04-07 at 22:27 +0200, Jan Kara wrote:
> >   Hello,
> > 
> > On Mon 07-04-14 10:10:27, Trond Myklebust wrote:
> 
> > > The problem seems to be the use of iterate_supers(), which grabs a
> > > passive reference, and conflicts with our use of an active reference in
> > > the open context.
> >   Yeah, we cannot really do otherwise in iterate_supers() - we have to grab
> > some superblock reference and we don't really want to get an active one
> > since that would result in spurious EBUSY returns from umount.
> 
> BTW: By what mechanism does an active reference lead to EBUSY issues
> here?
  Ah, sorry. I was wrong. We use mount usecount for this. But still using
active reference for iterate_supers() seems wrong as that could result in
handling of destruction of superblock from it...

								Honza
-- 
Jan Kara <jack@suse.cz>
SUSE Labs, CR
