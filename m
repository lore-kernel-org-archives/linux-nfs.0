Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([65.50.211.133]:35159 "EHLO
        bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750726AbeABVEd (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 2 Jan 2018 16:04:33 -0500
Date: Tue, 2 Jan 2018 13:04:31 -0800
From: Matthew Wilcox <willy@infradead.org>
To: NeilBrown <neilb@suse.com>
Cc: Jonathan Corbet <corbet@lwn.net>, linux-doc@vger.kernel.org,
        dhowells@redhat.com,
        Thiago Rafael Becker <thiago.becker@gmail.com>,
        viro@zeniv.linux.org.uk, schwidefsky@de.ibm.com,
        bfields@fieldses.org, linux-nfs@vger.kernel.org,
        linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH] Documentation: security/credentials.rst: explain need to
 sort group_list
Message-ID: <20180102210431.GA20405@bombadil.infradead.org>
References: <878te9os81.fsf@notabene.neil.brown.name>
 <20171211142708.GA23284@bombadil.infradead.org>
 <20171211151420.18655-1-thiago.becker@gmail.com>
 <20742.1514904840@warthog.procyon.org.uk>
 <87wp10dlgk.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <87wp10dlgk.fsf@notabene.neil.brown.name>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Jan 03, 2018 at 08:01:15AM +1100, NeilBrown wrote:
>  
> +When replacing the group list, the new list must be sorted before it
> +is added to the credential, as a binary search is used to test for
> +membership.  In practice, this means ``groups_sort()`` should be

For a .rst file, shouldn't we be using :c:func:`groups_sort` instead of
``groups_sort()``?

> +called before ``set_groups()`` or ``set_current_groups()``.
> +``groups_sort()`` must not be called on a ``struct group_list`` which
> +is shared as it may permute elements as part of the sorting process
> +even if the array is already sorted.
>  
>  When the credential set is ready, it should be committed to the current process
>  by calling::
> -- 
> 2.14.0.rc0.dirty
> 


