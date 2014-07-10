Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qc0-f182.google.com ([209.85.216.182]:34706 "EHLO
	mail-qc0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752323AbaGJMhB (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 10 Jul 2014 08:37:01 -0400
Received: by mail-qc0-f182.google.com with SMTP id m20so7853517qcx.13
        for <linux-nfs@vger.kernel.org>; Thu, 10 Jul 2014 05:37:00 -0700 (PDT)
From: Jeff Layton <jeff.layton@primarydata.com>
Date: Thu, 10 Jul 2014 08:36:59 -0400
To: Christoph Hellwig <hch@infradead.org>
Cc: bfields@fieldses.org, linux-nfs@vger.kernel.org
Subject: Re: [PATCH v4 013/100] nfsd: shrink st_access_bmap and st_deny_bmap
Message-ID: <20140710083659.7718e687@tlielax.poochiereds.net>
In-Reply-To: <20140710105019.GD6935@infradead.org>
References: <1404842668-22521-1-git-send-email-jlayton@primarydata.com>
	<1404842668-22521-14-git-send-email-jlayton@primarydata.com>
	<20140710105019.GD6935@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 10 Jul 2014 03:50:19 -0700
Christoph Hellwig <hch@infradead.org> wrote:

> >  static inline void
> >  set_access(u32 access, struct nfs4_ol_stateid *stp)
> 
> I suspect it might be a good idea to kill all these wrappers, as doing
> higher level bitops seems to be benefitial to a lot of the callers.
> 

Maybe. I'd prefer to leave that sort of cleanup until after this set if
it can be helped.

-- 
Jeff Layton <jlayton@primarydata.com>
