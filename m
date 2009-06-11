Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from prod-mail-xrelay02.akamai.com ([72.246.2.14]:51003 "EHLO
	prod-mail-xrelay02.akamai.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753209AbZFKUYc (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 11 Jun 2009 16:24:32 -0400
Message-ID: <4A316814.7030609@akamai.com>
Date: Thu, 11 Jun 2009 13:24:52 -0700
From: Amit Gud <agud@akamai.com>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        Steve Dickson <SteveD@redhat.com>, "gud@ksu.edu" <gud@ksu.edu>,
        "Uhlenkott, Jason" <juhlenko@akamai.com>
Subject: Re: [PATCH] NFS: Add acreg{min,max} and acdir{min,max} in milliseconds
References: <200906091832.50633.agud@akamai.com> <1244636844.24750.23.camel@heimdal.trondhjem.org> <4A300CE3.8080502@akamai.com> <025BEFCD-2F56-4E29-99F9-1939867B48A7@fys.uio.no>
In-Reply-To: <025BEFCD-2F56-4E29-99F9-1939867B48A7@fys.uio.no>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Trond Myklebust wrote:
> On Jun 10, 2009, at 15:43, Amit Gud <agud@akamai.com> wrote:
> 
>> Trond Myklebust wrote:
>>> On Tue, 2009-06-09 at 18:32 -0700, Amit Gud wrote:
>>>> This patch adds 4 new NFS mount options(acdirminms, acdirmaxms,
>>>> acregminms,
>>>> acregmaxms) converting already existing one into a millisecond
>>>> resolution
>>>> instead of seconds.
>>>>
>>>> Also, modifies the mountstats output to milliseconds instead of
>>>> seconds.
>>>
>>> Why, exactly, do you need to control cache timeouts down to the
>>> millisecond level?
>>>
>>
>> The problem is to make the updates visible from one client to the other
>> in less than a second and turning off caching entirely has an
>> unacceptably high penalty.
> 
> Specifics, please: updates of what, exactly? Are we talking attributes,
> data or directory contents?
> 
> What is your application, and why does 1ms constitute an acceptable
> caching timeout, while 1s does not?
> 

We have a system in which machine A needs a change made to an NFS
directory.  But, the actual change must be executed by machine B, so A
makes an request to B to make the update.  But, A is allowed to read
the directory directly, so A can't in general continue until it is
able to see the effect of the update.  With 1s caching, that means a
1s "sleep" after each update.

Setting caching to "0s" means that consecutive stats performed by
machine A must always revalidate every node of each path walked.  In
many cases, we end up wanting to stat every path component in some
path, which would result in O(N2) getattr or lookup calls for N
levels of directory depth.

Using a very small acdirmax (e.g. 10ms) gives us a significant
performance boost on these consecutive stats without increasing the
post-update "sleep" to 1s.  (Of course, if the file server delays more
than 10ms at any step, then we will have to start over for the next
operation.  But, the file server often has everything necessary in
cache such that each response is well below a millisecond.)


AG
--
May the source be with you.
