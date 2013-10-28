Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:8171 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756700Ab3J1SB6 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 28 Oct 2013 14:01:58 -0400
Message-ID: <526EA65A.7010209@redhat.com>
Date: Mon, 28 Oct 2013 14:00:58 -0400
From: Ric Wheeler <rwheeler@redhat.com>
MIME-Version: 1.0
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
        Christoph Anton Mitterer <calestyo@scientia.net>
CC: Mailing List Linux NFS <linux-nfs@vger.kernel.org>,
        Dr Fields James Bruce <bfields@fieldses.org>,
        Steve Dickson <SteveD@redhat.com>
Subject: Re: XATTRs in NFS?
References: <1382560643.6924.12.camel@heisenberg.scientia.net> <EFB2CFAD-FACC-401D-BF0C-1C573B23A873@netapp.com> <1382624000.6907.8.camel@heisenberg.scientia.net> <E0F4C952-02DE-4778-A779-FB7AE111EC46@netapp.com> <1382630468.6907.58.camel@heisenberg.scientia.net> <625CAA34-BD6C-4283-86D0-3F8B460D54D0@netapp.com> <1382635350.6907.83.camel@heisenberg.scientia.net> <20131025140846.GB20497@fieldses.org> <1382807547.29041.12.camel@heisenberg.scientia.net> <20131027191512.GA31322@fieldses.org> <1382911068.6932.20.camel@heisenberg.scientia.net> <8DB0D7A2-BA2A-4001-A01C-D498C777B243@netapp.com> <1382920068.6932.46.camel@heisenberg.scientia.net> <2E672741-FE4F-4287-8D00-B7634A71709E@netapp.com> <526E8562.3040809@redhat.com> <1382976943.8774.10.camel@heisenberg.scientia.net> <FD29488A-348B-48BA-9B1D-4ACF997BC794@netapp.com>
In-Reply-To: <FD29488A-348B-48BA-9B1D-4ACF997BC794@netapp.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 10/28/2013 01:49 PM, Myklebust, Trond wrote:
> On Oct 28, 2013, at 12:15 PM, Christoph Anton Mitterer <calestyo@scientia.net> wrote:
>
>> On Mon, 2013-10-28 at 11:40 -0400, Ric Wheeler wrote:
>>> Then you end up with large directories and an extra name per inode that needs to
>>> be stored and extra lookups for each file when you do a whole file system crawl.
>>>
>>> Certainly not as easy as adding and xattrs with that information :)
>> And I think there's another reason why it wouldn't work...
>>
>> Imagine I change my system to encode what should be XATTRs in hardlink
>> pseudo files...
>>
>> If I have such pair locally e.g. on my ext4:
>> /foo/bar/actual/file
>> /meta/<SHA512 identifier>.2342348324
>>
>> And now move/copy the file via the network to the archive, I'd have to
>> copy both files (which is really annoying), and I'd guess the inode
>> coupling would get los (and at least the name wouldn't fit anymore).
>>
>> So the whole thing is IMHO not even a workaround.
> OK. So you're going to do XATTRs for us?
>
> Trond

Now that pNFS is perfect and labeled NFS has made it upstream, I think that 
Steve D must be looking for something to keep him busy :)

ric

