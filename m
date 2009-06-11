From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH] NFS: Add acreg{min,max} and acdir{min,max} in milliseconds
Date: Wed, 10 Jun 2009 20:11:04 -0400
Message-ID: <025BEFCD-2F56-4E29-99F9-1939867B48A7@fys.uio.no>
References: <200906091832.50633.agud@akamai.com> <1244636844.24750.23.camel@heimdal.trondhjem.org> <4A300CE3.8080502@akamai.com>
Mime-Version: 1.0 (iPhone Mail 5H11)
Content-Type: text/plain;
	charset=us-ascii;
	format=flowed;
	delsp=yes
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
	Steve Dickson <SteveD@redhat.com>, "gud-OYTqUY/oFF8@public.gmane.org" <gud-OYTqUY/oFF8@public.gmane.org>,
	"Uhlenkott, Jason" <juhlenko@akamai.com>
To: Amit Gud <agud@akamai.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out2.uio.no ([129.240.10.58]:44948 "EHLO mail-out2.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752281AbZFKALL (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 10 Jun 2009 20:11:11 -0400
In-Reply-To: <4A300CE3.8080502@akamai.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Jun 10, 2009, at 15:43, Amit Gud <agud@akamai.com> wrote:

> Trond Myklebust wrote:
>> On Tue, 2009-06-09 at 18:32 -0700, Amit Gud wrote:
>>> This patch adds 4 new NFS mount options(acdirminms, acdirmaxms,  
>>> acregminms,
>>> acregmaxms) converting already existing one into a millisecond  
>>> resolution
>>> instead of seconds.
>>>
>>> Also, modifies the mountstats output to milliseconds instead of  
>>> seconds.
>>
>> Why, exactly, do you need to control cache timeouts down to the
>> millisecond level?
>>
>
> The problem is to make the updates visible from one client to the  
> other
> in less than a second and turning off caching entirely has an
> unacceptably high penalty.

Specifics, please: updates of what, exactly? Are we talking  
attributes, data or directory contents?

What is your application, and why does 1ms constitute an acceptable  
caching timeout, while 1s does not?

Trond
