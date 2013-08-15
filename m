Return-Path: linux-nfs-owner@vger.kernel.org
Received: from trent.utfs.org ([94.185.90.103]:50764 "EHLO trent.utfs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751146Ab3HOV0c (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 15 Aug 2013 17:26:32 -0400
Date: Thu, 15 Aug 2013 14:26:16 -0700 (PDT)
From: Christian Kujau <lists@nerdbynature.de>
To: Dave Kleikamp <dave.kleikamp@oracle.com>
cc: "J. Bruce Fields" <bfields@fieldses.org>, Karl Schmidt <karl@xtronics.com>,
        Jonathan McDowell <noodles@earth.li>,
        jfs-discussion@lists.sourceforge.net, 714974@bugs.debian.org,
        Ben Hutchings <ben@decadent.org.uk>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH] jfs: fix readdir cookie incompatibility with NFSv4
In-Reply-To: <520D3EA7.1010109@oracle.com>
Message-ID: <alpine.DEB.2.10.1308151420140.7081@trent.utfs.org>
References: <1373245980.3428.46.camel@deadeye.wl.decadent.org.uk> <520554A5.3060401@xtronics.com> <alpine.DEB.2.10.1308092352550.7081@trent.utfs.org> <alpine.DEB.2.10.1308120113360.7081@trent.utfs.org> <alpine.DEB.2.10.1308120122500.7081@trent.utfs.org>
 <20130812162924.GB2395@fieldses.org> <520C50F7.3010209@oracle.com> <alpine.DEB.2.10.1308142122550.7081@trent.utfs.org> <alpine.DEB.2.10.1308150001530.7081@trent.utfs.org> <520D3EA7.1010109@oracle.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 15 Aug 2013 at 15:48, Dave Kleikamp wrote:
> This patch replaces the one I posted yesterday. I like this better since
> it doesn't require fixing existing on-disk cookies or skipping a
> position in the in-inode index table.

Thanks. Applied to 3.11-rc5 and tested, no more "readdir loop" messages 
and with unique inode numbers, great!

  Tested-by: Christian Kujau <lists@nerdbynature.de>

Thanks for the fix!
Christian.
-- 
BOFH excuse #442:

Trojan horse ran out of hay
