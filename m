Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ig0-f171.google.com ([209.85.213.171]:41063 "EHLO
	mail-ig0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752200AbbBKStG (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 11 Feb 2015 13:49:06 -0500
MIME-Version: 1.0
In-Reply-To: <20150211181750.GB80012@kitty.kitty>
References: <54D394EC.9030902@Netapp.com>
	<20150205162326.GA18977@infradead.org>
	<54D39DC2.9060808@Netapp.com>
	<20150205164832.GB4289@fieldses.org>
	<54DB7D72.5020001@Netapp.com>
	<CAHQdGtTujOS5QZSaTbEy2sK0aZpoWmo-qmjgxb_iuue_5b=46A@mail.gmail.com>
	<20150211162244.GH25696@fieldses.org>
	<CAHQdGtTOdGh8pzseGdE6J8onoid-4ee4O=ra9sSS5aD_nWov+w@mail.gmail.com>
	<OF7B254253.7A276767-ON88257DE9.005F1E53-88257DE9.0060F512@us.ibm.com>
	<CAHQdGtSC-VRf=O6T175Li2Mvm7Zz9zY9RtCyaR-G=KSGAT8ppg@mail.gmail.com>
	<20150211181750.GB80012@kitty.kitty>
Date: Wed, 11 Feb 2015 13:49:05 -0500
Message-ID: <CAABAsM47mWrYFtkudHyiUSs6Ft=SWJr97yzc3bP-tST7tQppuA@mail.gmail.com>
Subject: Re: [PATCH v2 2/4] NFSD: Add READ_PLUS support for data segments
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Tom Haynes <thomas.haynes@primarydata.com>
Cc: Marc Eshel <eshel@us.ibm.com>, Anna Schumaker <Anna.Schumaker@netapp.com>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Christoph Hellwig <hch@infradead.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        linux-nfs-owner@vger.kernel.org
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Feb 11, 2015 at 1:17 PM, Tom Haynes
<thomas.haynes@primarydata.com> wrote:
> On Wed, Feb 11, 2015 at 12:47:26PM -0500, Trond Myklebust wrote:
>> On Wed, Feb 11, 2015 at 12:39 PM, Marc Eshel <eshel@us.ibm.com> wrote:
>> >
>> > A good hint that we are dealing with a sparse file is the the number of
>> > blocks don't add up to the reported filesize
>>
>> Sure, but that still adds up to an unnecessary inefficiency on each
>> READ_PLUS call to that file.
>>
>> My point is that the best way for the client to process this
>> information (and for the server too) is to read the sparseness map in
>> once as a bulk operation on a very large chunk of the file, and then
>> to use that map as a guide for when it needs to call READ.
>
> I thought we agreed that the sparseness map made no sense because
> the information was immeadiately stale?

Right now, we're caching the zero reads, aren't we? What makes caching
hole information so special?

> Anyway, the client could build that map if it wanted to using SEEK. I'm
> not arguing that it would be efficient, but that it could be done
> with a cycle of looking for holes.

Sure, however that's not necessarily useful as an optimiser either.
