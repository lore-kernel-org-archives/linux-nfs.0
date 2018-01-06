Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from ms.lwn.net ([45.79.88.28]:33146 "EHLO ms.lwn.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751082AbeAFSJf (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Sat, 6 Jan 2018 13:09:35 -0500
Date: Sat, 6 Jan 2018 11:09:08 -0700
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
Message-ID: <20180106110908.0adc1be2@lwn.net>
In-Reply-To: <20180102210431.GA20405@bombadil.infradead.org>
References: <878te9os81.fsf@notabene.neil.brown.name>
        <20171211142708.GA23284@bombadil.infradead.org>
        <20171211151420.18655-1-thiago.becker@gmail.com>
        <20742.1514904840@warthog.procyon.org.uk>
        <87wp10dlgk.fsf@notabene.neil.brown.name>
        <20180102210431.GA20405@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 2 Jan 2018 13:04:31 -0800
Matthew Wilcox <willy@infradead.org> wrote:

> > +When replacing the group list, the new list must be sorted before it
> > +is added to the credential, as a binary search is used to test for
> > +membership.  In practice, this means ``groups_sort()`` should be  
> 
> For a .rst file, shouldn't we be using :c:func:`groups_sort` instead of
> ``groups_sort()``?

There is value in using the c:func syntax, as it will generate
cross-references to the kerneldoc comments for those functions.  In this
case, it would appear that these comments exist, but nobody has pulled
them into the docs yet.  I took the liberty of adding :c:func: references
to this patch on its way into docs-next so that things will Just Work on
that happy day when somebody adds the function documentation.

Thanks,

jon
