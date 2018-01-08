Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from ms.lwn.net ([45.79.88.28]:41674 "EHLO ms.lwn.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932623AbeAHQke (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 8 Jan 2018 11:40:34 -0500
Date: Mon, 8 Jan 2018 09:40:30 -0700
From: Jonathan Corbet <corbet@lwn.net>
To: NeilBrown <neilb@suse.com>
Cc: Matthew Wilcox <willy@infradead.org>, linux-doc@vger.kernel.org,
        dhowells@redhat.com,
        Thiago Rafael Becker <thiago.becker@gmail.com>,
        viro@zeniv.linux.org.uk, schwidefsky@de.ibm.com,
        bfields@fieldses.org, linux-nfs@vger.kernel.org,
        linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH] Documentation: security/credentials.rst: explain need
 to sort group_list
Message-ID: <20180108093923.5bc41f4d@lwn.net>
In-Reply-To: <87608dck7x.fsf@notabene.neil.brown.name>
References: <878te9os81.fsf@notabene.neil.brown.name>
        <20171211142708.GA23284@bombadil.infradead.org>
        <20171211151420.18655-1-thiago.becker@gmail.com>
        <20742.1514904840@warthog.procyon.org.uk>
        <87wp10dlgk.fsf@notabene.neil.brown.name>
        <20180102210431.GA20405@bombadil.infradead.org>
        <20180106110908.0adc1be2@lwn.net>
        <87608dck7x.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 08 Jan 2018 10:39:14 +1100
NeilBrown <neilb@suse.com> wrote:

> > There is value in using the c:func syntax, as it will generate
> > cross-references to the kerneldoc comments for those functions.  In this
> > case, it would appear that these comments exist, but nobody has pulled
> > them into the docs yet.  I took the liberty of adding :c:func: references
> > to this patch on its way into docs-next so that things will Just Work on
> > that happy day when somebody adds the function documentation.  
> 
> Is this the sort of thing that might result in that happy day?
> I didn't spend tooo much time on it, in case including the
> kernel-doc in credentials.rst like this was the wrong direction.
