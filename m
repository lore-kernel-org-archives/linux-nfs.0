Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mxout12.cac.washington.edu ([140.142.33.31]:41464 "EHLO
	mxout12.cac.washington.edu" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750713Ab0HQUMF convert rfc822-to-8bit
	(ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 17 Aug 2010 16:12:05 -0400
Received: from smtp.washington.edu (smtp.washington.edu [140.142.33.34] (may be forged))
	by mxout12.cac.washington.edu (8.14.3+UW09.11/8.14.3+UW09.11) with ESMTP id o7HK8hXl011793
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Tue, 17 Aug 2010 13:08:43 -0700
Content-Type: text/plain; charset=us-ascii
Subject: Re: numeric UIDs
From: David Brodbeck <brodbd@u.washington.edu>
In-Reply-To: <4C6ADC57.80802@excfb.com>
Date: Tue, 17 Aug 2010 13:08:42 -0700
Message-Id: <F8D43B26-2795-4D8A-9429-0DBF0E75031D@u.washington.edu>
References: <201008030401.33552.dreck@vmsd.ath.cx> <20100803192241.GD31579@fieldses.org> <4C6ACB70.7080409@excfb.com> <20100817182400.GE23176@fieldses.org> <4C6ADC57.80802@excfb.com>
To: linux-nfs@vger.kernel.org
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0


On Aug 17, 2010, at 12:00 PM, Tom Haynes wrote:

> J. Bruce Fields wrote:
>> 
>> So the server rejects any attempts to set a numeric uid?
>>  
> 
> No, only ones which do not have a valid mapping in /etc/passwd.
> 
>> That means the sort of dumb-backup scenario required above would, as in
>> Linux, succeed over v3, but fail over v4?
>>  
> 
> Yes, it appears so.
> 
>> And have there been reports of users hitting that issue, or does it
>> remain a completely hypothetical problem?
>> 
>> --b.
>>  
> 
> It is all hypothetical. I think you would have to work pretty hard to get a system in such a state.

It comes up pretty regularly when extracting "foreign" tar files on an NFSv4 mount, ones that contain numeric UIDs that don't correspond to a valid user on your system.  You get one error message printed for each file as tar tries to set the numeric UID.  Of course, in that case you can get around it by specifying --no-same-owner, and in most applications it doesn't matter.  It's noticeably different behavior than NFSv3, though.

-- 

David Brodbeck
System Administrator, Linguistics
University of Washington




