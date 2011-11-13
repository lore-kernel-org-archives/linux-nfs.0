Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-bw0-f46.google.com ([209.85.214.46]:44649 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751937Ab1KMNpt convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 13 Nov 2011 08:45:49 -0500
Received: by bke11 with SMTP id 11so4920959bke.19
        for <linux-nfs@vger.kernel.org>; Sun, 13 Nov 2011 05:45:48 -0800 (PST)
MIME-Version: 1.0
Reply-To: tigran.mkrtchyan@desy.de
In-Reply-To: <20111113145400.6c7a9be3@notabene.brown>
References: <1321052673-22171-1-git-send-email-treinish@linux.vnet.ibm.com>
	<1321056809.8733.2.camel@lade.trondhjem.org>
	<20111112144953.GA3740@infradead.org>
	<20111113145400.6c7a9be3@notabene.brown>
Date: Sun, 13 Nov 2011 14:45:48 +0100
Message-ID: <CAGue13r5BhjWOUF3L8Jd4_T0RmOwL7D=ktwHT_7paug5qEvKmA@mail.gmail.com>
Subject: Re: [PATCH/RFC 0/7] Volatile Filehandle Client-side Support
From: Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>
To: NeilBrown <neilb@suse.de>
Cc: Christoph Hellwig <hch@infradead.org>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        Matthew Treinish <treinish@linux.vnet.ibm.com>,
        linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I have a server which runs on top of hadoop. The problem with hadoop
is that there is no way to have persistent file handles. I am
currently working on a way to do that - either simulate them or add a
support for unique file id to hadoop. If linux client will support
volatile file handles then I can stop inventing some workarounds.

Tigran.

On Sun, Nov 13, 2011 at 4:54 AM, NeilBrown <neilb@suse.de> wrote:
> On Sat, 12 Nov 2011 09:49:53 -0500 Christoph Hellwig <hch@infradead.org>
> wrote:
>
>> On Fri, Nov 11, 2011 at 07:13:29PM -0500, Trond Myklebust wrote:
>> > On Fri, 2011-11-11 at 18:04 -0500, Matthew Treinish wrote:
>> > > This patch series implements client side support for volatile file handle
>> > > recovery (RFC 3530 section 4.2 and 4.3) with walk back using the dcache. To
>> > > test the client you either need a server that supports volatile file handles or
>> > > you can hard code the server to output NFS4ERR_FHEXPIRED instead of
>> > > NFSERR_STALE. (See the last patch in the series)
>> >
>> > WHY do we want to support this kind of "feature"? As you said, the RFC
>> > doesn't actually help in figuring out how this crap is supposed to work
>> > in practice, so why do we even consider starting to give a damn?
>>
>> *nod*. Pretending we handle it seems fairly dangerous.  I'd much prefer
>> outright rejecting it.
>
> Hence the suggested mount option.
>
> A server might not be able to provide stable file handles, but can ensure
> that files don't get renamed - for these filesystems, the name is a
> reliable stable handle for the file (it just doesn't fit in the NFSv4 file
> handle structure).
>
> So if you know the filesystem will only return FHEXPIRED for filehandles
> belonging to files that cannot be renamed, then it is perfectly reasonable to
> repeat the name lookup to re-access the file after the server forgets about
> an old filehandle.  The mount option is how you communicate this knowledge,
> because the RFC doesn't provide a way to communicate it.
>
> NeilBrown
>
>
>
