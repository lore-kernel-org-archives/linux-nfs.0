Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:47238 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759264Ab0KPGpH convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 16 Nov 2010 01:45:07 -0500
In-Reply-To: <20101115174837.GB10044@fieldses.org>
References: <20101112184353.GA32745@fieldses.org>
	<AANLkTinOSGtrW1S3LKWXarJF-=ZKgh_GMKuPA2ppu-P4@mail.gmail.com>
	<20101115174837.GB10044@fieldses.org>
Date: Tue, 16 Nov 2010 17:45:03 +1100
Message-ID: <AANLkTim1QjTwOZ4SHdMy8Y6TOAnaOYtTwgwHXfH5H5Xn@mail.gmail.com>
Subject: Re: lifetime of DCACHE_DISCONECTED dentries
From: Nick Piggin <npiggin@gmail.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Tue, Nov 16, 2010 at 4:48 AM, J. Bruce Fields <bfields@fieldses.org> wrote:
> On Sat, Nov 13, 2010 at 10:53:12PM +1100, Nick Piggin wrote:
>> On Sat, Nov 13, 2010 at 5:43 AM, J. Bruce Fields <bfields@fieldses.org> wrote:

>> >        - putfh: look up the filehandle.  The only alias found for the
>> >          inode will be DCACHE_UNHASHED alias referenced by the filp
>> >          associated with the nfsd open.  d_obtain_alias() doesn't like
>> >          this, so it creates a new DCACHE_DISCONECTED dentry and
>> >          returns that instead.
>>
>> This seems to be where the thing goes wrong. It isn't a hashed dentry at
>> this point here, so d_obtain_alias should not be making one.
>
> Sounds sensible.  (But can you think of any actual bugs that will result
> from trying to add a new hashed dentry in this case?)

Well, this one? :)


>> I think the inode i_nlink games are much more appropriate on this side of
>> the equation, rather than the dput side (after all, d_obtain_alias is setting
>> up an alias for the inode).
>>
>> Can you even put the link check into __d_find_alias?
>>
>> -               if (S_ISDIR(inode->i_mode) || !d_unhashed(alias)) {
>> +               if (S_ISDIR(inode->i_mode) || !inode->i_nlink ||
>> !d_unhashed(alias)) {
>>
>> Something like that?
>
> The immediate result of that would be for the close rpc (or any rpc's
> sent after the file was unlinked) to fail with ESTALE.

Why is that? Seems like it would be a bug, because a hashed dentry may
be unhashed at any time concurrently to nfsd operation, so it should be
able to tolerate that so long as it has a ref on the inode?


> But nfsd already holds an open file in this case, and you could argue
> that it should be using that from the start.

Yes.


> So, we could modify nfsd to add a hash mapping filehandles to the filp's
> that it knows about, and have nfsd consult that hash before calling
> dentry_to_fh.

Could be an option. It would be a pity not just be able to use the alias list.
What exactly goes wrong when it gets an unhashed alias back?
