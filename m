Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-wg0-f46.google.com ([74.125.82.46]:59800 "EHLO
	mail-wg0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755684AbaH0Iuo (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 27 Aug 2014 04:50:44 -0400
Received: by mail-wg0-f46.google.com with SMTP id m15so15501312wgh.17
        for <linux-nfs@vger.kernel.org>; Wed, 27 Aug 2014 01:50:43 -0700 (PDT)
Message-ID: <53FD9BDF.6090400@gmail.com>
Date: Wed, 27 Aug 2014 11:50:39 +0300
From: Boaz Harrosh <openosd@gmail.com>
MIME-Version: 1.0
To: Trond Myklebust <trond.myklebust@primarydata.com>,
        Boaz Harrosh <boaz@plexistor.com>
CC: "Matt W. Benjamin" <matt@linuxbox.com>, Christoph Hellwig <hch@lst.de>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        "Adam C. Emerson" <aemerson@linuxbox.com>
Subject: Re: [PATCH] pnfs: Kick a pnfs_layoutcommit_inode on recall
References: <53FCA183.8000605@plexistor.com>	<1435166875.78.1409066662291.JavaMail.root@thunderbeast.private.linuxbox.com>	<CAHQdGtT-B7NTP8T7ETgTJD1+84k_KW_5aOfrYjLpA04hoR3YsA@mail.gmail.com>	<53FCBC5A.4060304@plexistor.com>	<CAHQdGtSghgbrPr=X8O2YLq=vXbKY1y5OuOMisf6vRoj8WeF0YA@mail.gmail.com>	<53FCBE9C.40906@plexistor.com>	<CAHQdGtTgcGiWbcZyAsaOzdB=RpdUx17vHcw1yxg7vS56BfwY+A@mail.gmail.com>	<53FCCFBD.3080305@plexistor.com>	<CAHQdGtRi_jA8+RkDqh+VBKwHhTpxygSEBWaDScqozyxVSPKAtg@mail.gmail.com> <CAHQdGtQM5uCyKLNBeU0ZENf-Jvki7TvJGbPt-FEAMLQi0jnYLg@mail.gmail.com>
In-Reply-To: <CAHQdGtQM5uCyKLNBeU0ZENf-Jvki7TvJGbPt-FEAMLQi0jnYLg@mail.gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 08/26/2014 10:46 PM, Trond Myklebust wrote:
<>
> 
> So to return to the original question: could we please change the
> layoutcommit in your patch so that it is asynchronous?
> 

There is nothing change. The original message at the head of
this thread, is Christoph's patch with the asynchronous layoutcommit.

As a reply I posted what I had in my tree, with a sync operation.
Because I wanted the recall to take 500 micro-seconds instead of like
300-1000 mili-seconds.

When the STD supports my model specifically I do not see why not

Don't you guys have recalls on the hot path?

Sigh, another nail in the coffin of what was suppose to be a dam
good STD.

Thinking about it from day one you had a personal agenda against
RECALLS. For some reason, which you never told me, you decided to
crash and burn any proper use of LO_RECALLS. With that dreaded
*synchronous* polling driven, forgetful--model recall.
(One day we'll sit on a Bear and you will tell me why? I really
 want to know)

Now that there is the last ever chance to make an half dissent
citizen out of what was left of recalls, you are all on your
back feet, against it. With religious mantras, when you have
never sat and actually stared at the prints and experienced
recalls for yourself. Your words

Christoph I have a deja-vu its principles against good science
again. Lets revert to your patch.

Reviewed-by: Boaz Harrosh <bharrosh@panasas.com>

