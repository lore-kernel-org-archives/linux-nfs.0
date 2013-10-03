Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-we0-f173.google.com ([74.125.82.173]:50119 "EHLO
	mail-we0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754424Ab3JCOiX (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 3 Oct 2013 10:38:23 -0400
Received: by mail-we0-f173.google.com with SMTP id u57so1642573wes.4
        for <linux-nfs@vger.kernel.org>; Thu, 03 Oct 2013 07:38:22 -0700 (PDT)
Message-ID: <524D815A.1070906@primarydata.com>
Date: Thu, 03 Oct 2013 17:38:18 +0300
From: Benny Halevy <bhalevy@primarydata.com>
MIME-Version: 1.0
To: Ric Wheeler <rwheeler@redhat.com>
CC: Christoph Hellwig <hch@infradead.org>,
        "J. Bruce Fields" <bfields@redhat.com>, linux-nfs@vger.kernel.org,
        Steven Whitehouse <swhiteho@redhat.com>,
        Bob Peterson <rpeterso@redhat.com>, Abhijith Das <adas@redhat.com>,
        Andrew Price <anprice@redhat.com>, Paul Evans <pevans@redhat.com>
Subject: Re: [PATCH RFC v0 05/49] pnfsd: introduce pnfsd header files
References: <20131001203047.GH16245@pad.fieldses.org> <524C0556.9070705@primarydata.com> <20131002160759.GB27988@infradead.org> <524D0873.40602@primarydata.com> <20131003095511.GA30147@infradead.org> <524D6312.7020709@primarydata.com> <524D6D38.1040506@redhat.com> <20131003131750.GA23408@infradead.org> <524D6EB9.3040309@redhat.com> <524D7CF3.6020306@primarydata.com> <20131003142127.GA16716@infradead.org> <524D7E13.1010905@redhat.com>
In-Reply-To: <524D7E13.1010905@redhat.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 2013-10-03 17:24, Ric Wheeler wrote:
> On 10/03/2013 10:21 AM, Christoph Hellwig wrote:
>> On Thu, Oct 03, 2013 at 05:19:31PM +0300, Benny Halevy wrote:
>>> The question is what is the minimum value for submitting upstream...
>>>
>>> The thing pnfs over dlm/gfs2 is missing mostly is supporting read/write layout.
>>> One could use them load balancing, e.g. by either redirecting to a node
>>> holding an exclusive lock on the file, if there is one, or dlm_ino_hash in its absence.
>> One could do a lot of things, especially given infinite time.  But what
>> does the current code buy us?  We need data on that to justify merging
>> such a large chunk of code.
>>
> 
> I think that we can help figure out how to get something reasonably useful ready 
> for upstream, just need to get some people spun up to help test out some of 
> these ideas...

That would be very helpful.  Much appreciated!

Benny

> 
> ric
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
