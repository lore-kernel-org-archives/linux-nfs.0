Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qa0-f54.google.com ([209.85.216.54]:57781 "EHLO
	mail-qa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752050AbaGJMtY (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 10 Jul 2014 08:49:24 -0400
Received: by mail-qa0-f54.google.com with SMTP id s7so3141136qap.13
        for <linux-nfs@vger.kernel.org>; Thu, 10 Jul 2014 05:49:24 -0700 (PDT)
From: Jeff Layton <jeff.layton@primarydata.com>
Date: Thu, 10 Jul 2014 08:49:22 -0400
To: Christoph Hellwig <hch@infradead.org>
Cc: Jeff Layton <jeff.layton@primarydata.com>, bfields@fieldses.org,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH v4 011/100] nfsd: refactor nfs4_file_get_access and
 nfs4_file_put_access
Message-ID: <20140710084922.6899fdf2@tlielax.poochiereds.net>
In-Reply-To: <20140710113523.GA17814@infradead.org>
References: <1404842668-22521-1-git-send-email-jlayton@primarydata.com>
	<1404842668-22521-12-git-send-email-jlayton@primarydata.com>
	<20140710075920.GA6226@infradead.org>
	<20140710073214.5621293f@tlielax.poochiereds.net>
	<20140710113523.GA17814@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 10 Jul 2014 04:35:23 -0700
Christoph Hellwig <hch@infradead.org> wrote:

> On Thu, Jul 10, 2014 at 07:32:14AM -0400, Jeff Layton wrote:
> > So, you're correct that we never take an fi_access reference for O_RDWR,
> > which is why the array doesn't have a slot for it:
> > 
> >         atomic_t                fi_access[2];
> > 
> > ...it's tracked by the union of the O_RDONLY and O_WRONLY counters.
> 
> Which will be racy as long we try to use an atomic_t and not a proper
> lock over access to all of fi_access.
> 

gets are always done with the lock held. puts do an atomic_dec_and_lock
or are done with the lock held. I don't see how that's racy...

> I'm still trying to understand why we even need fi_access and can't just
> use the file references directly, though.
> 


-- 
Jeff Layton <jlayton@primarydata.com>
