Return-Path: linux-nfs-owner@vger.kernel.org
Received: from userp1040.oracle.com ([156.151.31.81]:40975 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756298Ab3HONjG (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 15 Aug 2013 09:39:06 -0400
Message-ID: <520CD9C8.8000305@oracle.com>
Date: Thu, 15 Aug 2013 08:38:16 -0500
From: Dave Kleikamp <dave.kleikamp@oracle.com>
MIME-Version: 1.0
To: Christian Kujau <lists@nerdbynature.de>
CC: "J. Bruce Fields" <bfields@fieldses.org>, Karl Schmidt <karl@xtronics.com>,
        Jonathan McDowell <noodles@earth.li>,
        jfs-discussion@lists.sourceforge.net, 714974@bugs.debian.org,
        Ben Hutchings <ben@decadent.org.uk>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH] jfs: avoid misuse of cookie value of 2
References: <1373245980.3428.46.camel@deadeye.wl.decadent.org.uk> <520554A5.3060401@xtronics.com> <alpine.DEB.2.10.1308092352550.7081@trent.utfs.org> <alpine.DEB.2.10.1308120113360.7081@trent.utfs.org> <alpine.DEB.2.10.1308120122500.7081@trent.utfs.org> <20130812162924.GB2395@fieldses.org> <520C50F7.3010209@oracle.com> <alpine.DEB.2.10.1308142122550.7081@trent.utfs.org> <alpine.DEB.2.10.1308150001530.7081@trent.utfs.org>
In-Reply-To: <alpine.DEB.2.10.1308150001530.7081@trent.utfs.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 08/15/2013 02:09 AM, Christian Kujau wrote:
> On Wed, 14 Aug 2013 at 21:29, Christian Kujau wrote:
> 
>> On Wed, 14 Aug 2013 at 22:54, Dave Kleikamp wrote:
>>> It looks like the problem is that jfs was using a cookie value of 2 for
>>> a real directory entry, where NFSv4 expect 2 to represent "..". This
>>> patch has so far only been lightly tested.
>>
>> Hm, a first compile of 3.11-rc5 errors out with:
>>
>>   CC [M]  fs/jfs/jfs_dtree.o
>> /usr/local/src/linux-git/fs/jfs/jfs_dtree.c: In function ‘add_index’:
>> /usr/local/src/linux-git/fs/jfs/jfs_dtree.c:493:13: error: invalid storage class for function ‘free_index’
> [...]
>>
>> I'll run mrproper and try again...
> 
> This did not help, but adding a closing bracket did, in fs/jfs/jfs_dtree.c:354
> 
>         if (jfs_ip->next_index < 3) {
>                 jfs_ip->next_index = 3;
>         }
>    -----^
> 
> This compiled and booted and now I can run find(1) over that whole NFS 
> share, without any "readdir loop" messages and with unique inode numbers, 
> yay!

My bad. That's what happens when you clean up the patch after you test
it. I intended to remove the opening bracket when I removed a warning.

>   Tested-by: Christian Kujau <lists@nerdbynature.de>

Thanks. After sleeping on it, I'm contemplating a simpler patch. I'll
keep you up to date.

> 
> Thanks!
> Christian.
> 
