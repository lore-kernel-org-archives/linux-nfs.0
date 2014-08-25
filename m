Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-yk0-f177.google.com ([209.85.160.177]:59389 "EHLO
	mail-yk0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752978AbaHYBnE (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 24 Aug 2014 21:43:04 -0400
Received: by mail-yk0-f177.google.com with SMTP id 79so9920041ykr.8
        for <linux-nfs@vger.kernel.org>; Sun, 24 Aug 2014 18:43:03 -0700 (PDT)
From: Jeff Layton <jeff.layton@primarydata.com>
Date: Sun, 24 Aug 2014 21:43:01 -0400
To: Christoph Hellwig <hch@infradead.org>
Cc: linux-fsdevel@vger.kernel.org, bfields@fieldses.org,
        cluster-devel@redhat.com, linux-cifs@vger.kernel.org,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH 00/10] locks/nfsd: internal lease API overhaul
Message-ID: <20140824214301.61019123@synchrony.poochiereds.net>
In-Reply-To: <20140824161046.GI15908@infradead.org>
References: <1408804878-1331-1-git-send-email-jlayton@primarydata.com>
	<20140824161046.GI15908@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, 24 Aug 2014 09:10:46 -0700
Christoph Hellwig <hch@infradead.org> wrote:

> One more wishlist item in addition to the one mentioned in the patches:
> 
>  - add a return value to lm_break so that the lock manager can tell the
>    core code "you can delete this lease right now".  That gets rid of
>    the games with the timeout which require all kinds of race avoidance
>    code in the users.
> 

I'm not sure I understand what you're suggesting here. Isn't it just as
simple to have lm_break call lease_modify to just remove the lease?

> And a big one that doesn't seem easily addressable, but I'll drop it in
> anyway:
> 
>  - calling ->lm_break without i_lock would make everyones life a heck
>    lot easier..
> 

Indeed. I have some ideas for a larger cleanup of the file locking
code. This series is really sort of prep work for that overhaul, and
I'm hoping we'll be able to do something along those lines.

-- 
Jeff Layton <jlayton@primarydata.com>
