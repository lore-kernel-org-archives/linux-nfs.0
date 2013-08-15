Return-Path: linux-nfs-owner@vger.kernel.org
Received: from userp1040.oracle.com ([156.151.31.81]:19792 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751002Ab3HOWK0 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 15 Aug 2013 18:10:26 -0400
Message-ID: <520D519F.6080102@oracle.com>
Date: Thu, 15 Aug 2013 17:09:35 -0500
From: Dave Kleikamp <dave.kleikamp@oracle.com>
MIME-Version: 1.0
To: Christian Kujau <lists@nerdbynature.de>
CC: "J. Bruce Fields" <bfields@fieldses.org>, Karl Schmidt <karl@xtronics.com>,
        Jonathan McDowell <noodles@earth.li>,
        jfs-discussion@lists.sourceforge.net, 714974@bugs.debian.org,
        Ben Hutchings <ben@decadent.org.uk>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH] jfs: fix readdir cookie incompatibility with NFSv4
References: <1373245980.3428.46.camel@deadeye.wl.decadent.org.uk> <520554A5.3060401@xtronics.com> <alpine.DEB.2.10.1308092352550.7081@trent.utfs.org> <alpine.DEB.2.10.1308120113360.7081@trent.utfs.org> <alpine.DEB.2.10.1308120122500.7081@trent.utfs.org> <20130812162924.GB2395@fieldses.org> <520C50F7.3010209@oracle.com> <alpine.DEB.2.10.1308142122550.7081@trent.utfs.org> <alpine.DEB.2.10.1308150001530.7081@trent.utfs.org> <520D3EA7.1010109@oracle.com> <alpine.DEB.2.10.1308151420140.7081@trent.utfs.org>
In-Reply-To: <alpine.DEB.2.10.1308151420140.7081@trent.utfs.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 08/15/2013 04:26 PM, Christian Kujau wrote:
> On Thu, 15 Aug 2013 at 15:48, Dave Kleikamp wrote:
>> This patch replaces the one I posted yesterday. I like this better since
>> it doesn't require fixing existing on-disk cookies or skipping a
>> position in the in-inode index table.
> 
> Thanks. Applied to 3.11-rc5 and tested, no more "readdir loop" messages 
> and with unique inode numbers, great!
> 
>   Tested-by: Christian Kujau <lists@nerdbynature.de>
> 
> Thanks for the fix!
> Christian.

Thanks for reporting, investigating and testing!

Dave

