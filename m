Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:59836 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750899AbcHWTgX (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 23 Aug 2016 15:36:23 -0400
Date: Tue, 23 Aug 2016 15:36:21 -0400
To: Benjamin Coddington <bcodding@redhat.com>
Cc: List Linux NFS Mailing <linux-nfs@vger.kernel.org>
Subject: Re: I can't get no readdir satisfaction
Message-ID: <20160823193621.GA28230@fieldses.org>
References: <778246F3-8F24-48FD-AEA9-0BCC0DCD93B3@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <778246F3-8F24-48FD-AEA9-0BCC0DCD93B3@redhat.com>
From: bfields@fieldses.org (J. Bruce Fields)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Aug 23, 2016 at 11:09:37AM -0400, Benjamin Coddington wrote:
> Hi linux-nfs,
> 
> 311324ad1713 ("NFS: Be more aggressive in using readdirplus for 'ls -l'
> situations") changed when nfs_readdir() decides to revalidate the
> directory's mapping, which contains all the entries.  In addition to just
> checking if the attribute cache has expired, it includes a check to see if
> NFS_INO_INVALID_DATA is set on the directory.
> 
> Well, customers that have directories with very many dentries and that same
> directory's attributes are frequently updated are now grouchy that `ls -l`
> takes so long since any update of the directory causes the mapping to be
> invalidated and we have to start over filling the directory's mapping.

Apologies, I don't understand the client's readdir implementation.  So
it really zeroes out the cookie every time it invalidates the directory
cache?

I also seem to remember it makes up its own cookies to return to users
instead of returning the server's.  Is the cookie invalidation a
consequence of that?  I don't think it should have to be.  And as long
as these two things (cache and cookie validity) are tied together, I
can't see how we're going to guarantee readdir progress.

--b.

> 
> I actually haven't put real hard thought into it yet (because often for me
> that just wastes a lot of time), so I am doing the lazy thing by asking this
> question:
> 
> Can we go back to just the using the attribute cache timeout, or should we
> get all heuristical about readdir?
> 
> Ben
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
