Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:57968 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756448Ab3J1Sce (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 28 Oct 2013 14:32:34 -0400
Message-ID: <526EAD86.6090507@redhat.com>
Date: Mon, 28 Oct 2013 14:31:34 -0400
From: Ric Wheeler <rwheeler@redhat.com>
MIME-Version: 1.0
To: Dr Fields James Bruce <bfields@fieldses.org>
CC: "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
        Christoph Anton Mitterer <calestyo@scientia.net>,
        Mailing List Linux NFS <linux-nfs@vger.kernel.org>,
        Steve Dickson <SteveD@redhat.com>
Subject: Re: XATTRs in NFS?
References: <1382807547.29041.12.camel@heisenberg.scientia.net> <20131027191512.GA31322@fieldses.org> <1382911068.6932.20.camel@heisenberg.scientia.net> <8DB0D7A2-BA2A-4001-A01C-D498C777B243@netapp.com> <1382920068.6932.46.camel@heisenberg.scientia.net> <2E672741-FE4F-4287-8D00-B7634A71709E@netapp.com> <526E8562.3040809@redhat.com> <1382976943.8774.10.camel@heisenberg.scientia.net> <FD29488A-348B-48BA-9B1D-4ACF997BC794@netapp.com> <526EA65A.7010209@redhat.com> <20131028180838.GG31322@fieldses.org>
In-Reply-To: <20131028180838.GG31322@fieldses.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 10/28/2013 02:08 PM, Dr Fields James Bruce wrote:
> On Mon, Oct 28, 2013 at 02:00:58PM -0400, Ric Wheeler wrote:
>> On 10/28/2013 01:49 PM, Myklebust, Trond wrote:
>>> On Oct 28, 2013, at 12:15 PM, Christoph Anton Mitterer <calestyo@scientia.net> wrote:
>>>
>>>> On Mon, 2013-10-28 at 11:40 -0400, Ric Wheeler wrote:
>>>>> Then you end up with large directories and an extra name per inode that needs to
>>>>> be stored and extra lookups for each file when you do a whole file system crawl.
>>>>>
>>>>> Certainly not as easy as adding and xattrs with that information :)
>>>> And I think there's another reason why it wouldn't work...
>>>>
>>>> Imagine I change my system to encode what should be XATTRs in hardlink
>>>> pseudo files...
>>>>
>>>> If I have such pair locally e.g. on my ext4:
>>>> /foo/bar/actual/file
>>>> /meta/<SHA512 identifier>.2342348324
>>>>
>>>> And now move/copy the file via the network to the archive, I'd have to
>>>> copy both files (which is really annoying), and I'd guess the inode
>>>> coupling would get los (and at least the name wouldn't fit anymore).
>>>>
>>>> So the whole thing is IMHO not even a workaround.
>>> OK. So you're going to do XATTRs for us?
>>>
>>> Trond
>> Now that pNFS is perfect and labeled NFS has made it upstream, I
>> think that Steve D must be looking for something to keep him busy :)
> I agree with Trond that we first really need good evidence about exactly
> who wants this and why.
>
> --b.

For the user space xattrs, many applications store various types of metadata.  
Gluster for example heavily uses xattrs, other programs do things like data 
scrubbing (look for a long unchanged file, compute a has and store it as an 
xattr) or simply use it to annotate the file with the name of the program that 
created it. Think of it as file decorations or annotations.

Today, if we store files in NFS that have xattrs, we do in fact cause data loss.

I can understand an answer of "this would be hard to do for NFS and need to go 
through IETF" but think that xattrs are well enough established in Linux and 
supported in the tool chain that it is way too late to question whether or not 
supporting them is a worth our time.

Ric

