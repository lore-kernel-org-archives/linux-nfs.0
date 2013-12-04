Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.pingtimeout.net ([194.187.214.64]:51955 "EHLO
	mx1.pingtimeout.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753946Ab3LDVIP (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 4 Dec 2013 16:08:15 -0500
Message-ID: <529F99BA.6060106@pingtimeout.net>
Date: Wed, 04 Dec 2013 23:08:10 +0200
From: =?UTF-8?B?QW50dGkgVMO2bmt5csOk?= <daedalus@pingtimeout.net>
MIME-Version: 1.0
To: Dr Fields James Bruce <bfields@fieldses.org>
CC: Trond Myklebust <trond.myklebust@primarydata.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: Patch for mapping EILSEQ into NFSERR_INVAL
References: <529CEBC3.8060505@pingtimeout.net> <FA468B61-5F7E-4A88-A0BD-13BCF115282E@primarydata.com> <529CF322.4080701@pingtimeout.net> <20131203204806.GA2648@fieldses.org> <20131203212210.GC2648@fieldses.org> <529ED1C8.70208@pingtimeout.net> <20131204154104.GB14646@fieldses.org> <529F943D.30004@pingtimeout.net> <20131204210356.GA19452@fieldses.org>
In-Reply-To: <20131204210356.GA19452@fieldses.org>
Content-Type: text/plain; charset=UTF-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 2013-12-04 23:03, Dr Fields James Bruce wrote:
> On Wed, Dec 04, 2013 at 10:44:45PM +0200, Antti Tönkyrä wrote:
>> Looks like I can strace it and I did an example strace, if you need
>> something more specific please do tell. Command log has completion
>> timestamps for associating what part of strace happened at what
>> command.
>>
>> http://daedalus.pingtimeout.net/dbg/strace-ioerr.txt
>> http://daedalus.pingtimeout.net/dbg/strace-commandlog.txt
> Eh, not much use without knowing fuse's protocol, but:
>
>> And just in case you missed my other mail, the I/O error doesn't
>> kill the share if using NFSv3 (mount -t nfs -o vers=3,intr,hard
>> ...). The initial I/O error happens but the share doesn't die even
>> when there are file handles open there.
> Oh, I overlooked that.  So that merits another look at the network
> trace:
>
>>>> http://daedalus.pingtimeout.net/dbg/eilseq_ioerr.pcap
> And I see something I'd overlooked before: the client is sending the
> later opens with the same open owner and sequence id.  But NFS4ERR_IO is
> a seqid-mutating error.  So now I think this probably *is* a client
> bug....
>
> What's the client kernel version?
>
> --b.
Tests were mostly conducted using 3.8.0-29 (ubuntu flavour). Original 
bug was triggered with 3.8.10.

- Antti
