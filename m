Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx141.netapp.com ([216.240.21.12]:21857 "EHLO mx141.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751099AbbBLUAD (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 12 Feb 2015 15:00:03 -0500
Message-ID: <54DD0631.8040802@Netapp.com>
Date: Thu, 12 Feb 2015 14:59:45 -0500
From: Anna Schumaker <Anna.Schumaker@netapp.com>
MIME-Version: 1.0
To: Anna Schumaker <Anna.Schumaker@netapp.com>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Trond Myklebust <trond.myklebust@primarydata.com>
CC: Christoph Hellwig <hch@infradead.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Thomas D Haynes <thomas.haynes@primarydata.com>
Subject: Re: [PATCH v2 2/4] NFSD: Add READ_PLUS support for data segments
References: <1422477777-27933-1-git-send-email-Anna.Schumaker@Netapp.com> <1422477777-27933-3-git-send-email-Anna.Schumaker@Netapp.com> <20150205141325.GC4522@infradead.org> <54D394EC.9030902@Netapp.com> <20150205162326.GA18977@infradead.org> <54D39DC2.9060808@Netapp.com> <20150205164832.GB4289@fieldses.org> <54DB7D72.5020001@Netapp.com> <CAHQdGtTujOS5QZSaTbEy2sK0aZpoWmo-qmjgxb_iuue_5b=46A@mail.gmail.com> <20150211162244.GH25696@fieldses.org> <54DBABE7.9050403@Netapp.com>
In-Reply-To: <54DBABE7.9050403@Netapp.com>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 02/11/2015 02:22 PM, Anna Schumaker wrote:
> On 02/11/2015 11:22 AM, J. Bruce Fields wrote:
>> On Wed, Feb 11, 2015 at 11:13:38AM -0500, Trond Myklebust wrote:
>>> On Wed, Feb 11, 2015 at 11:04 AM, Anna Schumaker
>>> <Anna.Schumaker@netapp.com> wrote:
>>>> I'm not seeing a huge performance increase with READ_PLUS compared to READ (in fact, it's often a bit slower compared to READ, even when using splice).  My guess is that the problem is mostly on the client's end since we have to do a memory shift on each segment to get everything lined up properly.  I'm playing around with code that cuts down the number of memory shifts, but I still have a few bugs to work out before I'll know if it actually helps.
>>>>
>>>
>>> I'm wondering if the right way to do READ_PLUS would have been to
>>> instead have a separate function READ_SPARSE, that will return a list
>>> of all sparse areas in the supplied range. We could even make that a
>>> READ_SAME, that can do the same for patterned data.
>>
>> I worry about ending up with incoherent results, but perhaps it's no
>> different from the current behavior since we're already piecing together
>> our idea of the file content from multiple reads sent in parallel.
>>
>>> The thing is that READ works just fine for what we want it to do. The
>>> real win here would be if given a very large file, we could request a
>>> list of all the sparse areas in, say, a 100GB range, and then use that
>>> data to build up a bitmap of unallocated blocks for which we can skip
>>> the READ requests.
>>
>> Can we start by having the server return a single data extent covering
>> the whole read request, with the single exception of the case where the
>> read falls entirely within a hole?
> 
> I'm trying this and it's still giving me pretty bad performance.  I picked out 6 xfstests that read sparse files, and v4.2 takes almost a minute longer to run compared to v4.1.  (1:30 vs 2:22).
> 
> I'm going to look into how I zero pages on the client - maybe that can be combined with the right-shift function so pages only need to be mapped into memory once.

Today I learned all about how to use operf to identify where the bottleneck is :).  It looks like the problem is in the hole zeroing code on the client side.  Is there a better way than memset() to mark a page as all zeros?

Anna

> 
> Anna
> 
>>
>> I think that should help in the case of large holes without interfering
>> with the client's zero-copy logic in the case there are no large holes.
>>
>> --b.
>>
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 

