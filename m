Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail.virtall.com ([178.63.195.102]:49760 "EHLO mail.virtall.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755112Ab2GJXkl (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 10 Jul 2012 19:40:41 -0400
Message-ID: <4FFCBD72.1020001@wpkg.org>
Date: Wed, 11 Jul 2012 07:40:34 +0800
From: Tomasz Chmielewski <mangoo@wpkg.org>
MIME-Version: 1.0
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: cachefilesd - using multiple cache directories (disks)?
References: <4FFC733D.7050306@wpkg.org> <1341947709.12698.15.camel@lade.trondhjem.org>
In-Reply-To: <1341947709.12698.15.camel@lade.trondhjem.org>
Content-Type: text/plain; charset=UTF-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 07/11/2012 03:15 AM, Myklebust, Trond wrote:

(...)

>> 2) it's not possible to use multiple directories with one
>> cachefilesd process, but it's perfectly OK to run multiple
>> instances of cachefilesd on one server
>>
>>
>> Which one is true?
>
> See Documentation/filesystems/caching/cachefiles.txt: ========
> OVERVIEW ======== ... CacheFiles is currently limited to a single
> cache.

And what about this answer by David Howells?

http://www.redhat.com/archives/linux-cachefs/2011-July/msg00003.html

	> Would I have to run two instances of the cachefiles daemon in
	> order to use both cache directories?

	You would have to have two config files and two daemons (one
	per cache).  Each cache needs to be managed separately.


-- 
Tomasz Chmielewski
http://www.ptrraveler.com

