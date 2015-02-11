Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-vc0-f180.google.com ([209.85.220.180]:44060 "EHLO
	mail-vc0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753294AbbBKQbo convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 11 Feb 2015 11:31:44 -0500
Received: by mail-vc0-f180.google.com with SMTP id im6so1529840vcb.11
        for <linux-nfs@vger.kernel.org>; Wed, 11 Feb 2015 08:31:44 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20150211162244.GH25696@fieldses.org>
References: <1422477777-27933-1-git-send-email-Anna.Schumaker@Netapp.com>
	<1422477777-27933-3-git-send-email-Anna.Schumaker@Netapp.com>
	<20150205141325.GC4522@infradead.org>
	<54D394EC.9030902@Netapp.com>
	<20150205162326.GA18977@infradead.org>
	<54D39DC2.9060808@Netapp.com>
	<20150205164832.GB4289@fieldses.org>
	<54DB7D72.5020001@Netapp.com>
	<CAHQdGtTujOS5QZSaTbEy2sK0aZpoWmo-qmjgxb_iuue_5b=46A@mail.gmail.com>
	<20150211162244.GH25696@fieldses.org>
Date: Wed, 11 Feb 2015 11:31:43 -0500
Message-ID: <CAHQdGtTOdGh8pzseGdE6J8onoid-4ee4O=ra9sSS5aD_nWov+w@mail.gmail.com>
Subject: Re: [PATCH v2 2/4] NFSD: Add READ_PLUS support for data segments
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Anna Schumaker <Anna.Schumaker@netapp.com>,
        Christoph Hellwig <hch@infradead.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Thomas D Haynes <thomas.haynes@primarydata.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Feb 11, 2015 at 11:22 AM, J. Bruce Fields <bfields@fieldses.org> wrote:
> On Wed, Feb 11, 2015 at 11:13:38AM -0500, Trond Myklebust wrote:
>> On Wed, Feb 11, 2015 at 11:04 AM, Anna Schumaker
>> <Anna.Schumaker@netapp.com> wrote:
>> > I'm not seeing a huge performance increase with READ_PLUS compared to READ (in fact, it's often a bit slower compared to READ, even when using splice).  My guess is that the problem is mostly on the client's end since we have to do a memory shift on each segment to get everything lined up properly.  I'm playing around with code that cuts down the number of memory shifts, but I still have a few bugs to work out before I'll know if it actually helps.
>> >
>>
>> I'm wondering if the right way to do READ_PLUS would have been to
>> instead have a separate function READ_SPARSE, that will return a list
>> of all sparse areas in the supplied range. We could even make that a
>> READ_SAME, that can do the same for patterned data.
>
> I worry about ending up with incoherent results, but perhaps it's no
> different from the current behavior since we're already piecing together
> our idea of the file content from multiple reads sent in parallel.

I don't see what the problem is. The client sends a READ_SPARSE, and
caches the existence or not of a hole. How is that in any way
different from caching the results of a read that returns no data?

>> The thing is that READ works just fine for what we want it to do. The
>> real win here would be if given a very large file, we could request a
>> list of all the sparse areas in, say, a 100GB range, and then use that
>> data to build up a bitmap of unallocated blocks for which we can skip
>> the READ requests.
>
> Can we start by having the server return a single data extent covering
> the whole read request, with the single exception of the case where the
> read falls entirely within a hole?
>
> I think that should help in the case of large holes without interfering
> with the client's zero-copy logic in the case there are no large holes.
>

That still forces the server to do extra work on each read: it has to
check for the presence of a hole or not instead of just filling the
buffer with data.

-- 
Trond Myklebust
Linux NFS client maintainer, PrimaryData
trond.myklebust@primarydata.com
