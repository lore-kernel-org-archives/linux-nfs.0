Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qc0-f180.google.com ([209.85.216.180]:39214 "EHLO
	mail-qc0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750759AbaF3M7g (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 30 Jun 2014 08:59:36 -0400
Received: by mail-qc0-f180.google.com with SMTP id r5so7034211qcx.11
        for <linux-nfs@vger.kernel.org>; Mon, 30 Jun 2014 05:59:36 -0700 (PDT)
From: Jeff Layton <jeff.layton@primarydata.com>
Date: Mon, 30 Jun 2014 08:59:34 -0400
To: Christoph Hellwig <hch@infradead.org>
Cc: bfields@fieldses.org, linux-nfs@vger.kernel.org
Subject: Re: [PATCH v2 000/117] nfsd: eliminate the client_mutex
Message-ID: <20140630085934.2bf86ba0@tlielax.poochiereds.net>
In-Reply-To: <20140630125142.GA32089@infradead.org>
References: <1403810017-16062-1-git-send-email-jlayton@primarydata.com>
	<20140630125142.GA32089@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 30 Jun 2014 05:51:42 -0700
Christoph Hellwig <hch@infradead.org> wrote:

> I'm pretty happy with what's the first 25 patches in this version
> with all the review comments addressed, so as far as I'm concerned
> these are ready for for-next.  Does anyone else plan to do a review
> as well?
> 

Thanks very much for the review so far.

> I'll try to get to the locking changes as well soon, but I've got some
> work keeping me fairly busy at the moment.  I guess it wasn't easily
> feasible to move the various stateid refcounting to before the major
> locking changes?
> 

Not really. If I had done the set from scratch I would have probably
done that instead, but Trond's original had those changes interleaved.
Separating them would be a lot of work that I'd prefer to avoid.

> Btw, do you have any benchrmarks showing the improvements of the new
> locking scheme?

No, I'm hoping to get those numbers soon from our QA folks. Most of the
testing I've done has been for correctness and stability. I'm pretty
happy with things at that end now, but I don't have any numbers that
show whether and how much this helps scalability.

-- 
Jeff Layton <jlayton@primarydata.com>
