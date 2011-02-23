Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qw0-f46.google.com ([209.85.216.46]:33526 "EHLO
	mail-qw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752474Ab1BWTmv (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 23 Feb 2011 14:42:51 -0500
Received: by qwd7 with SMTP id 7so4027458qwd.19
        for <linux-nfs@vger.kernel.org>; Wed, 23 Feb 2011 11:42:50 -0800 (PST)
Message-ID: <4D65632C.7040800@gmail.com>
Date: Wed, 23 Feb 2011 14:42:36 -0500
From: Joe Landman <joe.landman@gmail.com>
To: linux-nfs@vger.kernel.org
Subject: Re: Invisible file problem
References: <20110222215214.GA32537@untroubled.org> <1298447447.2968.8.camel@heimdal.trondhjem.org> <20110223145004.GA6747@untroubled.org>
In-Reply-To: <20110223145004.GA6747@untroubled.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 02/23/2011 09:50 AM, Bruce Guenter wrote:
> On Tue, Feb 22, 2011 at 11:50:47PM -0800, Trond Myklebust wrote:
>> There is a known bug in readdir that has been fixed in 2.6.38-rc6, but
>> hasn't yet hit the 2.6.37 stable series. Please check the patch at
>>
>> http://git.kernel.org/?p=linux/kernel/git/torvalds/linux-2.6.git&a=commitdiff&h=d1205f87bbb8040c1408bbd9e0a720310b2b0b9b
>>
>> and see if it fixes your problem.
>
> Yes it did, thank you very much.

Is this a server or client side issue BTW?  I am trying to track 
something that could be related to this down.

Thanks!

Joe


-- 
Joe Landman
landman@scalableinformatics.com
