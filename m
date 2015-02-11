Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx141.netapp.com ([216.240.21.12]:43325 "EHLO mx141.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753153AbbBKQEF (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 11 Feb 2015 11:04:05 -0500
Message-ID: <54DB7D72.5020001@Netapp.com>
Date: Wed, 11 Feb 2015 11:04:02 -0500
From: Anna Schumaker <Anna.Schumaker@netapp.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: Christoph Hellwig <hch@infradead.org>, <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH v2 2/4] NFSD: Add READ_PLUS support for data segments
References: <1422477777-27933-1-git-send-email-Anna.Schumaker@Netapp.com> <1422477777-27933-3-git-send-email-Anna.Schumaker@Netapp.com> <20150205141325.GC4522@infradead.org> <54D394EC.9030902@Netapp.com> <20150205162326.GA18977@infradead.org> <54D39DC2.9060808@Netapp.com> <20150205164832.GB4289@fieldses.org>
In-Reply-To: <20150205164832.GB4289@fieldses.org>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 02/05/2015 11:48 AM, J. Bruce Fields wrote:
> On Thu, Feb 05, 2015 at 11:43:46AM -0500, Anna Schumaker wrote:
>> On 02/05/2015 11:23 AM, Christoph Hellwig wrote:
>>> On Thu, Feb 05, 2015 at 11:06:04AM -0500, Anna Schumaker wrote:
>>>>> If the READ_PLUS implementation can't use the splice read path it's
>>>>> probably a loss for most workloads.
>>>>>
>>>>
>>>> I'll play around with the splice path, but I don't think it was designed for encoding multiple read segments.
>>>
>>> The problem is that the typical case of all data won't use splice
>>> every with your patches as the 4.2 client will always send a READ_PLUS.
>>>
>>> So we'll have to find a way to use it where it helps.  While we might be
>>> able to add some hacks to only use splice for the first segment I guess
>>> we just need to make the splice support generic enough in the long run.
>>>
>>
>> I should be able to use splice if I detect that we're only returning a single DATA segment easily enough.
> 
> Oh, good thought, yes maybe that would be enough.
> 
> But I still wish he had more evidence here.

I'm not seeing a huge performance increase with READ_PLUS compared to READ (in fact, it's often a bit slower compared to READ, even when using splice).  My guess is that the problem is mostly on the client's end since we have to do a memory shift on each segment to get everything lined up properly.  I'm playing around with code that cuts down the number of memory shifts, but I still have a few bugs to work out before I'll know if it actually helps.

Anna

> 
> --b.
> 

