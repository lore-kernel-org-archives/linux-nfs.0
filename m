From: Amit Gud <agud@akamai.com>
Subject: Re: [PATCH] NFS: Add acreg{min,max} and acdir{min,max} in milliseconds
Date: Fri, 12 Jun 2009 12:30:35 -0700
Message-ID: <4A32ACDB.90802@akamai.com>
References: <200906091832.50633.agud@akamai.com>	 <1244636844.24750.23.camel@heimdal.trondhjem.org>	 <4A300CE3.8080502@akamai.com>	 <025BEFCD-2F56-4E29-99F9-1939867B48A7@fys.uio.no>	 <4A316814.7030609@akamai.com> <1244754888.5047.132.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
	Steve Dickson <SteveD@redhat.com>, "gud-OYTqUY/oFF8@public.gmane.org" <gud-OYTqUY/oFF8@public.gmane.org>,
	"Uhlenkott, Jason" <juhlenko@akamai.com>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from prod-mail-xrelay04.akamai.com ([96.6.114.79]:42112 "EHLO
	prod-mail-xrelay04.akamai.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753561AbZFLTaO (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 12 Jun 2009 15:30:14 -0400
In-Reply-To: <1244754888.5047.132.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Trond Myklebust wrote:
> On Thu, 2009-06-11 at 13:24 -0700, Amit Gud wrote:
>> Trond Myklebust wrote:
>>> On Jun 10, 2009, at 15:43, Amit Gud <agud@akamai.com> wrote:
>>>
>>>> Trond Myklebust wrote:
>>>>> On Tue, 2009-06-09 at 18:32 -0700, Amit Gud wrote:
>>>>>> This patch adds 4 new NFS mount options(acdirminms, acdirmaxms,
>>>>>> acregminms,
>>>>>> acregmaxms) converting already existing one into a millisecond
>>>>>> resolution
>>>>>> instead of seconds.
>>>>>>
>>>>>> Also, modifies the mountstats output to milliseconds instead of
>>>>>> seconds.
>>>>> Why, exactly, do you need to control cache timeouts down to the
>>>>> millisecond level?
>>>>>
>>>> The problem is to make the updates visible from one client to the other
>>>> in less than a second and turning off caching entirely has an
>>>> unacceptably high penalty.
>>> Specifics, please: updates of what, exactly? Are we talking attributes,
>>> data or directory contents?
>>>
>>> What is your application, and why does 1ms constitute an acceptable
>>> caching timeout, while 1s does not?
>>>
>> We have a system in which machine A needs a change made to an NFS
>> directory.  But, the actual change must be executed by machine B, so A
>> makes an request to B to make the update.  But, A is allowed to read
>> the directory directly, so A can't in general continue until it is
>> able to see the effect of the update.  With 1s caching, that means a
>> 1s "sleep" after each update.
>>
>> Setting caching to "0s" means that consecutive stats performed by
>> machine A must always revalidate every node of each path walked.  In
>> many cases, we end up wanting to stat every path component in some
>> path, which would result in O(N2) getattr or lookup calls for N
>> levels of directory depth.
>>
>> Using a very small acdirmax (e.g. 10ms) gives us a significant
>> performance boost on these consecutive stats without increasing the
>> post-update "sleep" to 1s.  (Of course, if the file server delays more
>> than 10ms at any step, then we will have to start over for the next
>> operation.  But, the file server often has everything necessary in
>> cache such that each response is well below a millisecond.)
> 
> I'm still not sure I fully understand, but here are a couple of
> comments.
> 
> Firstly, opendir() will _always_ force a revalidation of the directory
> attributes, so if your machine A is relying on doing an 'ls' in order to
> figure out the directory contents, then that shouldn't need extra
> attribute timeouts.
> 
> Secondly, we have already introduced finer control over the lookup
> caching as of Linux 2.6.28 and newer:
>         - if you want to ensure that machine A always see new files and
>         links immediately once they have been created, then
>         '-olookupcache=positive' should turn off negative dentry
>         caching.
>         - if you also want to ensure that it immediately sees renames,
>         unlinks and such, then '-olookupcache=none' will turn off lookup
>         caching altogether.
> Both of these lookup cache options are more reliable than relying on the
> directory attribute cache timeouts, and they have the added benefit that
> they also work around the problem that Linux servers tend to have poor
> mtime resolution. A 1ms cache timeout on the client won't help you much
> if the server only registers changes in 1s increments.

Those options don't seem particularly useful.

Machine A doesn't necessarily use ls to figure out changes in the
directory content. So, revalidation of the directory attribute wouldn't
happen.

We definitely want lookup caching turned on, always, including both
positive and negative caching.  But, we need to see new files, unlinks,
and renames much quicker than a second.

And mtime resolution may not be a problem if NFS servers are not on Linux.


AG
--
May the source be with you.
http://www.cis.ksu.edu/~gud

