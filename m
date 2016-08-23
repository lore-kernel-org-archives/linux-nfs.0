Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:57768 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752183AbcHWVut (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 23 Aug 2016 17:50:49 -0400
From: "Benjamin Coddington" <bcodding@redhat.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: "List Linux NFS Mailing" <linux-nfs@vger.kernel.org>
Subject: Re: I can't get no readdir satisfaction
Date: Tue, 23 Aug 2016 17:50:47 -0400
Message-ID: <E45FFA91-0A33-4C6C-834D-E7AE507FB302@redhat.com>
In-Reply-To: <20160823193621.GA28230@fieldses.org>
References: <778246F3-8F24-48FD-AEA9-0BCC0DCD93B3@redhat.com>
 <20160823193621.GA28230@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 23 Aug 2016, at 15:36, J. Bruce Fields wrote:

> On Tue, Aug 23, 2016 at 11:09:37AM -0400, Benjamin Coddington wrote:
>> Hi linux-nfs,
>>
>> 311324ad1713 ("NFS: Be more aggressive in using readdirplus for 'ls 
>> -l'
>> situations") changed when nfs_readdir() decides to revalidate the
>> directory's mapping, which contains all the entries.  In addition to 
>> just
>> checking if the attribute cache has expired, it includes a check to 
>> see if
>> NFS_INO_INVALID_DATA is set on the directory.
>>
>> Well, customers that have directories with very many dentries and 
>> that same
>> directory's attributes are frequently updated are now grouchy that 
>> `ls -l`
>> takes so long since any update of the directory causes the mapping to 
>> be
>> invalidated and we have to start over filling the directory's 
>> mapping.
>
> Apologies, I don't understand the client's readdir implementation.  So
> it really zeroes out the cookie every time it invalidates the 
> directory
> cache?

Yes, it zeros the cookieverf, so as I understand it we have to start 
over.
But, maybe for a given open() of a directory we can just keep the same
cookieverf, even if we invalidate the mapping we can continue to return
entries where the last nfs_readdir() left off..

I don't fully understand the client's readdir implementation either..

> I also seem to remember it makes up its own cookies to return to users
> instead of returning the server's.  Is the cookie invalidation a
> consequence of that?  I don't think it should have to be.  And as long
> as these two things (cache and cookie validity) are tied together, I
> can't see how we're going to guarantee readdir progress.

For users, it looks like a "position" is used, which is like an index 
into the
entries.  After READDIR, each entry's cookie is stored in the pagecache 
in
an array indexed by this position.  So in order to resume reading the
directory at a position, we need retrieve all the prior entries from the
server to determine what cookie to start from.

.. that made sense to me.  I hope I am understanding this correctly.

Ben
