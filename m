Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:9942 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751084Ab2HAPWO (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 1 Aug 2012 11:22:14 -0400
Message-ID: <5019499C.2040805@RedHat.com>
Date: Wed, 01 Aug 2012 11:22:04 -0400
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: Karel Zak <kzak@redhat.com>
CC: NeilBrown <neilb@suse.de>, NFS <linux-nfs@vger.kernel.org>
Subject: Re: nfs-utils: Something is wrong in is_vers4()
References: <20120731165842.08017d60@notabene.brown> <5018103A.9070607@RedHat.com> <20120731183739.GA16347@x2.net.home>
In-Reply-To: <20120731183739.GA16347@x2.net.home>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 07/31/2012 02:37 PM, Karel Zak wrote:
> On Tue, Jul 31, 2012 at 01:04:58PM -0400, Steve Dickson wrote:
>>> BTW Steve, Karel's "[PATCH] umount.nfs: ignore non-nfs filesystems"
>>> which appears in email:
>>>
>>> From: Karel Zak <kzak@redhat.com>
>>> To: NeilBrown <neilb@suse.de>
>>> Cc: Steve Dickson <SteveD@redhat.com>, NFS <linux-nfs@vger.kernel.org>
>>> Subject: Re: [PATCH] umount.nfs: restore correct error status when umount fails.
>>> Date: Thu, 12 Jul 2012 18:44:20 +0200
>>>
>>> hasn't been applied, but probably should be.
>> I beg to differ....
>>
>> commit 76908c3f14a12e865054ea5d6e4cad201c28839a
>> Author: NeilBrown <neilb@suse.de>
>> Date:   Mon Jul 16 08:43:28 2012 -0400
>>
>>     mount.nfs: restore correct error status when umount fails
>>
>> Or am I missing something?
> 
>  Yes, Neil found two problems:
> 
>     http://www.spinics.net/lists/linux-nfs/msg31466.html
Ah... Found it and committed it... 

steved.

