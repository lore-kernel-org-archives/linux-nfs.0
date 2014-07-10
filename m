Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qg0-f52.google.com ([209.85.192.52]:44044 "EHLO
	mail-qg0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751853AbaGJMTO (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 10 Jul 2014 08:19:14 -0400
Received: by mail-qg0-f52.google.com with SMTP id f51so264838qge.25
        for <linux-nfs@vger.kernel.org>; Thu, 10 Jul 2014 05:19:13 -0700 (PDT)
From: Jeff Layton <jeff.layton@primarydata.com>
Date: Thu, 10 Jul 2014 08:19:12 -0400
To: Christoph Hellwig <hch@infradead.org>
Cc: bfields@fieldses.org, linux-nfs@vger.kernel.org
Subject: Re: [PATCH v4 015/100] nfsd: clean up reset_union_bmap_deny
Message-ID: <20140710081912.4af7c35b@tlielax.poochiereds.net>
In-Reply-To: <20140710103100.GA6935@infradead.org>
References: <1404842668-22521-1-git-send-email-jlayton@primarydata.com>
	<1404842668-22521-16-git-send-email-jlayton@primarydata.com>
	<20140710103100.GA6935@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 10 Jul 2014 03:31:00 -0700
Christoph Hellwig <hch@infradead.org> wrote:

> >  static void
> > -reset_union_bmap_deny(unsigned long deny, struct nfs4_ol_stateid *stp)
> > +reset_union_bmap_deny(u32 deny, struct nfs4_ol_stateid *stp)
> >  {
> >  	int i;
> > -	for (i = 0; i < 4; i++) {
> > +
> > +	for (i = 1; i < 4; i++) {
> >  		if ((i & deny) != i)
> >  			clear_deny(i, stp);
> >  	}
> 
> 
> Couldn't this simply be written as:
> 
> 	stp->st_deny_bmap &= ~deny;
> 
> and inlined into the caller?

No, the st_deny_bmap does not hold the NFS_SHARE_DENY_* bits
themselves. It sets a bit for each NFS_SHARE_DENY_* mode that the
stateid has used. The difference is subtle, but significant.

The rationale for that is in the comments above bmap_to_share_mode.

-- 
Jeff Layton <jlayton@primarydata.com>
