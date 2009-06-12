From: Amit Gud <agud@akamai.com>
Subject: Re: [PATCH] NFS: Add acreg{min,max} and acdir{min,max} in milliseconds
Date: Fri, 12 Jun 2009 14:49:17 -0700
Message-ID: <4A32CD5D.2070502@akamai.com>
References: <200906091832.50633.agud@akamai.com>	 <1244636844.24750.23.camel@heimdal.trondhjem.org>	 <4A300CE3.8080502@akamai.com>	 <025BEFCD-2F56-4E29-99F9-1939867B48A7@fys.uio.no>	 <4A316814.7030609@akamai.com>	 <1244754888.5047.132.camel@heimdal.trondhjem.org>	 <4A32ACDB.90802@akamai.com> <1244836259.19533.19.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
	Steve Dickson <SteveD@redhat.com>, "gud-OYTqUY/oFF8@public.gmane.org" <gud-OYTqUY/oFF8@public.gmane.org>,
	"Uhlenkott, Jason" <juhlenko@akamai.com>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from prod-mail-xrelay03.akamai.com ([96.6.114.84]:39346 "EHLO
	prod-mail-xrelay03.akamai.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755711AbZFLVsz (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 12 Jun 2009 17:48:55 -0400
In-Reply-To: <1244836259.19533.19.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Trond Myklebust wrote:
> On Fri, 2009-06-12 at 12:30 -0700, Amit Gud wrote:
>> We definitely want lookup caching turned on, always, including both
>> positive and negative caching.  But, we need to see new files, unlinks,
>> and renames much quicker than a second.
> 
> Then use the lookupcache option, since that's what it is for.
> 

Sorry, I don't understand.

Copying from your last mail:

> Secondly, we have already introduced finer control over the lookup
> caching as of Linux 2.6.28 and newer:
>         - if you want to ensure that machine A always see new files and
>         links immediately once they have been created, then
>         '-olookupcache=positive' should turn off negative dentry
>         caching.
>         - if you also want to ensure that it immediately sees renames,
>         unlinks and such, then '-olookupcache=none' will turn off lookup
>         caching altogether.

How is it possible to _not_ disable any caching (positive or negative
dentries) and still be able to see renames, unlinks and such in << 1s?


AG
--
May the source be with you.
http://www.cis.ksu.edu/~gud
