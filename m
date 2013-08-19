Return-Path: linux-nfs-owner@vger.kernel.org
Received: from ocean.cnchost.com ([207.155.250.20]:35061 "EHLO
	ocean.cnchost.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751080Ab3HSTk7 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 19 Aug 2013 15:40:59 -0400
Message-ID: <52126DD2.6090006@appliedplastic.com>
Date: Mon, 19 Aug 2013 13:11:14 -0600
From: ben <ben@appliedplastic.com>
MIME-Version: 1.0
To: Ben Hutchings <ben@decadent.org.uk>
CC: Karl Schmidt <karl@xtronics.com>, Jonathan McDowell <noodles@earth.li>,
        Dave Kleikamp <dave.kleikamp@oracle.com>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        jfs-discussion@lists.sourceforge.net, 714974@bugs.debian.org,
        linux-nfs@vger.kernel.org, Christian Kujau <lists@nerdbynature.de>
Subject: Re: [JunkMail] Re: [PATCH] jfs: fix readdir cookie incompatibility
 with NFSv4
References: <1373245980.3428.46.camel@deadeye.wl.decadent.org.uk>  <520554A5.3060401@xtronics.com>  <alpine.DEB.2.10.1308092352550.7081@trent.utfs.org>  <alpine.DEB.2.10.1308120113360.7081@trent.utfs.org>  <alpine.DEB.2.10.1308120122500.7081@trent.utfs.org>  <20130812162924.GB2395@fieldses.org> <520C50F7.3010209@oracle.com>  <alpine.DEB.2.10.1308142122550.7081@trent.utfs.org>  <alpine.DEB.2.10.1308150001530.7081@trent.utfs.org>  <520D3EA7.1010109@oracle.com>  <alpine.DEB.2.10.1308151420140.7081@trent.utfs.org> <1376769691.2544.4.camel@deadeye.wl.decadent.org.uk>
In-Reply-To: <1376769691.2544.4.camel@deadeye.wl.decadent.org.uk>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 8/17/2013 2:01 PM, Ben Hutchings wrote:
> On Thu, 2013-08-15 at 14:26 -0700, Christian Kujau wrote:
>> On Thu, 15 Aug 2013 at 15:48, Dave Kleikamp wrote:
>>> This patch replaces the one I posted yesterday. I like this better since
>>> it doesn't require fixing existing on-disk cookies or skipping a
>>> position in the in-inode index table.
>>
>> Thanks. Applied to 3.11-rc5 and tested, no more "readdir loop" messages 
>> and with unique inode numbers, great!
>>
>>   Tested-by: Christian Kujau <lists@nerdbynature.de>
> 
> Karl and Jonathan, could you test the attached backport to 3.2?
> 
> (Instructions for rebuilding the Debian kernel package are at:
> <http://kernel-handbook.alioth.debian.org/ch-common-tasks.html#s-common-official>)
> 
> Ben.
> 
When I read this the other day I thought It was a great idea, but when
sleeping on it I have this gut feeling that somewhere there is a
jfs_dirent->position--; missing but I don't have enough familiarity with
the code to begin to guess where. Hopefully I am wrong.

ben

-- 
Ben Hildred
Support Services
Applied Plastic Coatings, Inc.
5000 Tabor St.
Wheat Ridge, CO 80033
303 424 9200
F: 303 424 8800
ben@appliedplastic.com
http://appliedplastic.com

