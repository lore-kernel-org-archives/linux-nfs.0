Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-wi0-f179.google.com ([209.85.212.179]:58124 "EHLO
	mail-wi0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755138AbaDGWJI (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 7 Apr 2014 18:09:08 -0400
Received: by mail-wi0-f179.google.com with SMTP id z2so331528wiv.0
        for <linux-nfs@vger.kernel.org>; Mon, 07 Apr 2014 15:09:07 -0700 (PDT)
Message-ID: <1396908542.5563.12.camel@leira.trondhjem.org>
Subject: Re: NFS deadlock between 'sync' and commit after unmount....
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Jan Kara <jack@suse.cz>
Cc: Brown Neil <neilb@suse.de>, Viro Alexander <viro@zeniv.linux.org.uk>,
        NFS <linux-nfs@vger.kernel.org>
Date: Mon, 07 Apr 2014 18:09:02 -0400
In-Reply-To: <20140407202750.GE23670@quack.suse.cz>
References: <20140407135001.56ef9f36@notabene.brown>
	 <F59673DE-8047-4FE0-AFF9-6A3DC37348A5@primarydata.com>
	 <20140407202750.GE23670@quack.suse.cz>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 2014-04-07 at 22:27 +0200, Jan Kara wrote:
>   Hello,
> 
> On Mon 07-04-14 10:10:27, Trond Myklebust wrote:

> > The problem seems to be the use of iterate_supers(), which grabs a
> > passive reference, and conflicts with our use of an active reference in
> > the open context.
>   Yeah, we cannot really do otherwise in iterate_supers() - we have to grab
> some superblock reference and we don't really want to get an active one
> since that would result in spurious EBUSY returns from umount.

BTW: By what mechanism does an active reference lead to EBUSY issues
here?

-- 
Trond Myklebust
Linux NFS client maintainer, PrimaryData
trond.myklebust@primarydata.com


