Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([65.50.211.133]:57873 "EHLO
        bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751509AbeAFUUQ (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sat, 6 Jan 2018 15:20:16 -0500
Date: Sat, 6 Jan 2018 12:20:13 -0800
From: Matthew Wilcox <willy@infradead.org>
To: Jonathan Corbet <corbet@lwn.net>
Cc: NeilBrown <neilb@suse.com>, linux-doc@vger.kernel.org,
        dhowells@redhat.com,
        Thiago Rafael Becker <thiago.becker@gmail.com>,
        viro@zeniv.linux.org.uk, schwidefsky@de.ibm.com,
        bfields@fieldses.org, linux-nfs@vger.kernel.org,
        linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH] Documentation: security/credentials.rst: explain need to
 sort group_list
Message-ID: <20180106202013.GA6183@bombadil.infradead.org>
References: <878te9os81.fsf@notabene.neil.brown.name>
 <20171211142708.GA23284@bombadil.infradead.org>
 <20171211151420.18655-1-thiago.becker@gmail.com>
 <20742.1514904840@warthog.procyon.org.uk>
 <87wp10dlgk.fsf@notabene.neil.brown.name>
 <20180102210431.GA20405@bombadil.infradead.org>
 <20180106110908.0adc1be2@lwn.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20180106110908.0adc1be2@lwn.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, Jan 06, 2018 at 11:09:08AM -0700, Jonathan Corbet wrote:
> On Tue, 2 Jan 2018 13:04:31 -0800
> Matthew Wilcox <willy@infradead.org> wrote:
> 
> > > +When replacing the group list, the new list must be sorted before it
> > > +is added to the credential, as a binary search is used to test for
> > > +membership.  In practice, this means ``groups_sort()`` should be  
> > 
> > For a .rst file, shouldn't we be using :c:func:`groups_sort` instead of
> > ``groups_sort()``?
> 
> There is value in using the c:func syntax, as it will generate
> cross-references to the kerneldoc comments for those functions.  In this
> case, it would appear that these comments exist, but nobody has pulled
> them into the docs yet.  I took the liberty of adding :c:func: references
> to this patch on its way into docs-next so that things will Just Work on
> that happy day when somebody adds the function documentation.

Thanks for making that substitution.

I've been thinking about all the kernel-doc we have that's completely
unincorporated.  I've also been thinking about core-api/kernel-api.rst
which to my mind is completely unreadable in its current form -- look at
https://www.kernel.org/doc/html/latest/core-api/kernel-api.html and you
wouldn't really know there's anything in it beyond the List Management
Functions.

I think the right path forward is to have kernel-api.rst be the dumping
ground for all the files with kernel-doc but nothing more.  That gives
us somewhere to link to.

Then we need little stories about how all the functions in a subsystem
fit together.  For example, we can create a list.rst which explains how
this is a doubly-linked list that you use by embedding a list_head into
your data structure, and has O(1) insertion/deletion, etc, etc.  Then we
would move all the list.h kernel-doc from kernel-api.rst into list.rst.

Is this a reasonable strategy to follow?  Does anyone have a better
strategy?  I mean ... you've written a book, you presumably have some
idea about how to present the vast amount of information we've accumulated
over the years :-)
