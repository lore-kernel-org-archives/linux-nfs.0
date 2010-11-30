Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:50449 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754391Ab0K3BAT convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 29 Nov 2010 20:00:19 -0500
In-Reply-To: <20101129193248.GA9897@fieldses.org>
References: <20101112184353.GA32745@fieldses.org>
	<AANLkTinOSGtrW1S3LKWXarJF-=ZKgh_GMKuPA2ppu-P4@mail.gmail.com>
	<20101115174837.GB10044@fieldses.org>
	<AANLkTim1QjTwOZ4SHdMy8Y6TOAnaOYtTwgwHXfH5H5Xn@mail.gmail.com>
	<AANLkTinMq1W1vx-jZnf7cb1cAnh9OyoVRYtVS7zpujfs@mail.gmail.com>
	<20101129193248.GA9897@fieldses.org>
Date: Tue, 30 Nov 2010 12:00:16 +1100
Message-ID: <AANLkTikwzDJ_q65==uxDsAhp3h8bU7Rkt7U9gVgRAK0D@mail.gmail.com>
Subject: Re: lifetime of DCACHE_DISCONECTED dentries
From: Nick Piggin <npiggin@gmail.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Tue, Nov 30, 2010 at 6:32 AM, J. Bruce Fields <bfields@fieldses.org> wrote:
> On Mon, Nov 29, 2010 at 02:56:22PM +1100, Nick Piggin wrote:
>> On Tue, Nov 16, 2010 at 5:45 PM, Nick Piggin <npiggin@gmail.com> wrote:
>> > On Tue, Nov 16, 2010 at 4:48 AM, J. Bruce Fields <bfields@fieldses.org> wrote:
>> >> On Sat, Nov 13, 2010 at 10:53:12PM +1100, Nick Piggin wrote:
>> >>> On Sat, Nov 13, 2010 at 5:43 AM, J. Bruce Fields <bfields@fieldses.org> wrote:
>> >
>> >>> >        - putfh: look up the filehandle.  The only alias found for the
>> >>> >          inode will be DCACHE_UNHASHED alias referenced by the filp
>> >>> >          associated with the nfsd open.  d_obtain_alias() doesn't like
>> >>> >          this, so it creates a new DCACHE_DISCONECTED dentry and
>> >>> >          returns that instead.
>> >>>
>> >>> This seems to be where the thing goes wrong. It isn't a hashed dentry at
>> >>> this point here, so d_obtain_alias should not be making one.
>> >>
>> >> Sounds sensible.  (But can you think of any actual bugs that will result
>> >> from trying to add a new hashed dentry in this case?)
>> >
>> > Well, this one? :)
>> >
>> >
>> >>> I think the inode i_nlink games are much more appropriate on this side of
>> >>> the equation, rather than the dput side (after all, d_obtain_alias is setting
>> >>> up an alias for the inode).
>> >>>
>> >>> Can you even put the link check into __d_find_alias?
>> >>>
>> >>> -               if (S_ISDIR(inode->i_mode) || !d_unhashed(alias)) {
>> >>> +               if (S_ISDIR(inode->i_mode) || !inode->i_nlink ||
>> >>> !d_unhashed(alias)) {
>> >>>
>> >>> Something like that?
>> >>
>> >> The immediate result of that would be for the close rpc (or any rpc's
>> >> sent after the file was unlinked) to fail with ESTALE.
>> >
>> > Why is that? Seems like it would be a bug, because a hashed dentry may
>> > be unhashed at any time concurrently to nfsd operation, so it should be
>> > able to tolerate that so long as it has a ref on the inode?
>>
>> Ping? Did you work out why nfs fails with ESTALE in that case? It seems
>> to work in my testing (and do the right thing with freeing the inode).
>
> Bah, sorry, I read too quickly, got the sense of the test backwards, and
> thought you were suggesting __d_find_alias() shouldn't return an alias
> in the i_nlink == 0 case!
>
> Yes, agreed, that should solve my problem.

OK, good.

> But what's the reason for the d_unhashed() check now?  Could we get rid
> of it entirely?

Well when the inode still has links I think we actually do want any new
references to go to hashed dentries. Definitely for d_splice_alias.
