Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from ms.lwn.net ([45.79.88.28]:41644 "EHLO ms.lwn.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S933517AbeAHQgn (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 8 Jan 2018 11:36:43 -0500
Date: Mon, 8 Jan 2018 09:36:39 -0700
From: Jonathan Corbet <corbet@lwn.net>
To: Matthew Wilcox <willy@infradead.org>
Cc: NeilBrown <neilb@suse.com>, linux-doc@vger.kernel.org,
        dhowells@redhat.com,
        Thiago Rafael Becker <thiago.becker@gmail.com>,
        viro@zeniv.linux.org.uk, schwidefsky@de.ibm.com,
        bfields@fieldses.org, linux-nfs@vger.kernel.org,
        linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH] Documentation: security/credentials.rst: explain need
 to sort group_list
Message-ID: <20180108093639.5d2c7e06@lwn.net>
In-Reply-To: <20180106202013.GA6183@bombadil.infradead.org>
References: <878te9os81.fsf@notabene.neil.brown.name>
        <20171211142708.GA23284@bombadil.infradead.org>
        <20171211151420.18655-1-thiago.becker@gmail.com>
        <20742.1514904840@warthog.procyon.org.uk>
        <87wp10dlgk.fsf@notabene.neil.brown.name>
        <20180102210431.GA20405@bombadil.infradead.org>
        <20180106110908.0adc1be2@lwn.net>
        <20180106202013.GA6183@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, 6 Jan 2018 12:20:13 -0800
Matthew Wilcox <willy@infradead.org> wrote:

> I've been thinking about all the kernel-doc we have that's completely
> unincorporated.  I've also been thinking about core-api/kernel-api.rst
> which to my mind is completely unreadable in its current form -- look at
> https://www.kernel.org/doc/html/latest/core-api/kernel-api.html and you
> wouldn't really know there's anything in it beyond the List Management
> Functions.

Yes, it's a mess.

> I think the right path forward is to have kernel-api.rst be the dumping
> ground for all the files with kernel-doc but nothing more.  That gives
> us somewhere to link to.

That's kind of what it is now :)

Note that we have a script now (scripts/find-unused-docs.sh) that can
seek out kerneldoc comments that aren't yet pulled in to the RST document
tree.  

> Then we need little stories about how all the functions in a subsystem
> fit together.  For example, we can create a list.rst which explains how
> this is a doubly-linked list that you use by embedding a list_head into
> your data structure, and has O(1) insertion/deletion, etc, etc.  Then we
> would move all the list.h kernel-doc from kernel-api.rst into list.rst.
> 
> Is this a reasonable strategy to follow?  Does anyone have a better
> strategy? 

That more-or-less corresponds to what I've been aiming at.  All of
Documentation/ currently is a bit of a dumping ground; I'd really like to
knit it together into something coherent and useful.  Progress on that
front has been slower than I would have liked - I've been distracted by a
number of other things.  Funny, I've never heard of that happening before.

The "little stories", incidentally, can also go into DOC: sections in the
source itself.  There's a bit of tension, though, between doing that and
putting the stories in the RST files.  The former approach puts the docs
where they might be most useful and most likely to be updated, but it can
also leave the RST files as a collection of kerneldoc directives that is
rather unhelpful to read in unprocessed form.  Since the whole idea is to
not require any sort of processing to make the docs useful, I don't
entirely like that outcome.

Thanks,

jon
