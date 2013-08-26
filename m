Return-Path: linux-nfs-owner@vger.kernel.org
Received: from aserp1040.oracle.com ([141.146.126.69]:20321 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751734Ab3HZW20 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 26 Aug 2013 18:28:26 -0400
Message-ID: <521BD663.9070805@oracle.com>
Date: Mon, 26 Aug 2013 17:27:47 -0500
From: Dave Kleikamp <dave.kleikamp@oracle.com>
MIME-Version: 1.0
To: Christian Kujau <lists@nerdbynature.de>
CC: Karl Schmidt <karl@xtronics.com>, Jonathan McDowell <noodles@earth.li>,
        jfs-discussion@lists.sourceforge.net,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Ben Hutchings <ben@decadent.org.uk>, linux-nfs@vger.kernel.org
Subject: Re: [Jfs-discussion] [PATCH] jfs: fix readdir cookie incompatibility
 with NFSv4
References: <1373245980.3428.46.camel@deadeye.wl.decadent.org.uk> <520554A5.3060401@xtronics.com> <alpine.DEB.2.10.1308092352550.7081@trent.utfs.org> <alpine.DEB.2.10.1308120113360.7081@trent.utfs.org> <alpine.DEB.2.10.1308120122500.7081@trent.utfs.org> <20130812162924.GB2395@fieldses.org> <520C50F7.3010209@oracle.com> <alpine.DEB.2.10.1308142122550.7081@trent.utfs.org> <alpine.DEB.2.10.1308150001530.7081@trent.utfs.org> <520D3EA7.1010109@oracle.com> <alpine.DEB.2.11.1308241517240.21301@trent.utfs.org>
In-Reply-To: <alpine.DEB.2.11.1308241517240.21301@trent.utfs.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 08/24/2013 05:21 PM, Christian Kujau wrote:
> On Thu, 15 Aug 2013 at 15:48, Dave Kleikamp wrote:
>> This patch replaces the one I posted yesterday. I like this better since
>> it doesn't require fixing existing on-disk cookies or skipping a
>> position in the in-inode index table.
>>
>> NFSv4 reserves readdir cookie values 0-2 for special entries (. and ..),
>> but jfs allows a value of 2 for a non-special entry. This incompatibility
>> can result in the nfs client reporting a readdir loop.
>>
>> This patch doesn't change the value stored internally, but adds one to
>> the value exposed to the iterate method.
> 
> Out of curiosity, will this land on 3.11?

Just sent a pull request to Linus. Once it's picked up, I'll submit a
patch to the stable trees.
