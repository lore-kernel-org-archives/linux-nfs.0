Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-vc0-f170.google.com ([209.85.220.170]:45989 "EHLO
	mail-vc0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753319AbbBKQNk convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 11 Feb 2015 11:13:40 -0500
Received: by mail-vc0-f170.google.com with SMTP id hq12so1522713vcb.1
        for <linux-nfs@vger.kernel.org>; Wed, 11 Feb 2015 08:13:39 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <54DB7D72.5020001@Netapp.com>
References: <1422477777-27933-1-git-send-email-Anna.Schumaker@Netapp.com>
	<1422477777-27933-3-git-send-email-Anna.Schumaker@Netapp.com>
	<20150205141325.GC4522@infradead.org>
	<54D394EC.9030902@Netapp.com>
	<20150205162326.GA18977@infradead.org>
	<54D39DC2.9060808@Netapp.com>
	<20150205164832.GB4289@fieldses.org>
	<54DB7D72.5020001@Netapp.com>
Date: Wed, 11 Feb 2015 11:13:38 -0500
Message-ID: <CAHQdGtTujOS5QZSaTbEy2sK0aZpoWmo-qmjgxb_iuue_5b=46A@mail.gmail.com>
Subject: Re: [PATCH v2 2/4] NFSD: Add READ_PLUS support for data segments
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Anna Schumaker <Anna.Schumaker@netapp.com>
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
        Christoph Hellwig <hch@infradead.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Thomas D Haynes <thomas.haynes@primarydata.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Feb 11, 2015 at 11:04 AM, Anna Schumaker
<Anna.Schumaker@netapp.com> wrote:
> On 02/05/2015 11:48 AM, J. Bruce Fields wrote:
>> On Thu, Feb 05, 2015 at 11:43:46AM -0500, Anna Schumaker wrote:
>>> On 02/05/2015 11:23 AM, Christoph Hellwig wrote:
>>>> On Thu, Feb 05, 2015 at 11:06:04AM -0500, Anna Schumaker wrote:
>>>>>> If the READ_PLUS implementation can't use the splice read path it's
>>>>>> probably a loss for most workloads.
>>>>>>
>>>>>
>>>>> I'll play around with the splice path, but I don't think it was designed for encoding multiple read segments.
>>>>
>>>> The problem is that the typical case of all data won't use splice
>>>> every with your patches as the 4.2 client will always send a READ_PLUS.
>>>>
>>>> So we'll have to find a way to use it where it helps.  While we might be
>>>> able to add some hacks to only use splice for the first segment I guess
>>>> we just need to make the splice support generic enough in the long run.
>>>>
>>>
>>> I should be able to use splice if I detect that we're only returning a single DATA segment easily enough.
>>
>> Oh, good thought, yes maybe that would be enough.
>>
>> But I still wish he had more evidence here.
>
> I'm not seeing a huge performance increase with READ_PLUS compared to READ (in fact, it's often a bit slower compared to READ, even when using splice).  My guess is that the problem is mostly on the client's end since we have to do a memory shift on each segment to get everything lined up properly.  I'm playing around with code that cuts down the number of memory shifts, but I still have a few bugs to work out before I'll know if it actually helps.
>

I'm wondering if the right way to do READ_PLUS would have been to
instead have a separate function READ_SPARSE, that will return a list
of all sparse areas in the supplied range. We could even make that a
READ_SAME, that can do the same for patterned data.

The thing is that READ works just fine for what we want it to do. The
real win here would be if given a very large file, we could request a
list of all the sparse areas in, say, a 100GB range, and then use that
data to build up a bitmap of unallocated blocks for which we can skip
the READ requests.

-- 
Trond Myklebust
Linux NFS client maintainer, PrimaryData
trond.myklebust@primarydata.com
