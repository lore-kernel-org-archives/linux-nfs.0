Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-vc0-f182.google.com ([209.85.220.182]:52159 "EHLO
	mail-vc0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753614AbbBKRr1 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 11 Feb 2015 12:47:27 -0500
Received: by mail-vc0-f182.google.com with SMTP id id10so1727419vcb.13
        for <linux-nfs@vger.kernel.org>; Wed, 11 Feb 2015 09:47:26 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <OF7B254253.7A276767-ON88257DE9.005F1E53-88257DE9.0060F512@us.ibm.com>
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
	<CAHQdGtTOdGh8pzseGdE6J8onoid-4ee4O=ra9sSS5aD_nWov+w@mail.gmail.com>
	<OF7B254253.7A276767-ON88257DE9.005F1E53-88257DE9.0060F512@us.ibm.com>
Date: Wed, 11 Feb 2015 12:47:26 -0500
Message-ID: <CAHQdGtSC-VRf=O6T175Li2Mvm7Zz9zY9RtCyaR-G=KSGAT8ppg@mail.gmail.com>
Subject: Re: [PATCH v2 2/4] NFSD: Add READ_PLUS support for data segments
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Marc Eshel <eshel@us.ibm.com>
Cc: Anna Schumaker <Anna.Schumaker@netapp.com>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Christoph Hellwig <hch@infradead.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        linux-nfs-owner@vger.kernel.org,
        Thomas D Haynes <thomas.haynes@primarydata.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Feb 11, 2015 at 12:39 PM, Marc Eshel <eshel@us.ibm.com> wrote:
> linux-nfs-owner@vger.kernel.org wrote on 02/11/2015 08:31:43 AM:
>
>> From: Trond Myklebust <trond.myklebust@primarydata.com>
>> To: "J. Bruce Fields" <bfields@fieldses.org>
>> Cc: Anna Schumaker <Anna.Schumaker@netapp.com>, Christoph Hellwig
>> <hch@infradead.org>, Linux NFS Mailing List <linux-
>> nfs@vger.kernel.org>, Thomas D Haynes <thomas.haynes@primarydata.com>
>> Date: 02/11/2015 08:31 AM
>> Subject: Re: [PATCH v2 2/4] NFSD: Add READ_PLUS support for data segments
>> Sent by: linux-nfs-owner@vger.kernel.org
>>
>> On Wed, Feb 11, 2015 at 11:22 AM, J. Bruce Fields
>> <bfields@fieldses.org> wrote:
>> > On Wed, Feb 11, 2015 at 11:13:38AM -0500, Trond Myklebust wrote:
>> >> On Wed, Feb 11, 2015 at 11:04 AM, Anna Schumaker
>> >> <Anna.Schumaker@netapp.com> wrote:
>> >> > I'm not seeing a huge performance increase with READ_PLUS
>> compared to READ (in fact, it's often a bit slower compared to READ,
>> even when using splice).  My guess is that the problem is mostly on
>> the client's end since we have to do a memory shift on each segment
>> to get everything lined up properly.  I'm playing around with code
>> that cuts down the number of memory shifts, but I still have a few
>> bugs to work out before I'll know if it actually helps.
>> >> >
>> >>
>> >> I'm wondering if the right way to do READ_PLUS would have been to
>> >> instead have a separate function READ_SPARSE, that will return a list
>> >> of all sparse areas in the supplied range. We could even make that a
>> >> READ_SAME, that can do the same for patterned data.
>> >
>> > I worry about ending up with incoherent results, but perhaps it's no
>> > different from the current behavior since we're already piecing together
>> > our idea of the file content from multiple reads sent in parallel.
>>
>> I don't see what the problem is. The client sends a READ_SPARSE, and
>> caches the existence or not of a hole. How is that in any way
>> different from caching the results of a read that returns no data?
>>
>> >> The thing is that READ works just fine for what we want it to do. The
>> >> real win here would be if given a very large file, we could request a
>> >> list of all the sparse areas in, say, a 100GB range, and then use that
>> >> data to build up a bitmap of unallocated blocks for which we can skip
>> >> the READ requests.
>> >
>> > Can we start by having the server return a single data extent covering
>> > the whole read request, with the single exception of the case where the
>> > read falls entirely within a hole?
>> >
>> > I think that should help in the case of large holes without interfering
>> > with the client's zero-copy logic in the case there are no large holes.
>> >
>>
>> That still forces the server to do extra work on each read: it has to
>> check for the presence of a hole or not instead of just filling the
>> buffer with data.
>
> A good hint that we are dealing with a sparse file is the the number of
> blocks don't add up to the reported filesize
> Marc.

Sure, but that still adds up to an unnecessary inefficiency on each
READ_PLUS call to that file.

My point is that the best way for the client to process this
information (and for the server too) is to read the sparseness map in
once as a bulk operation on a very large chunk of the file, and then
to use that map as a guide for when it needs to call READ.

-- 
Trond Myklebust
Linux NFS client maintainer, PrimaryData
trond.myklebust@primarydata.com
