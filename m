Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.pingtimeout.net ([194.187.214.64]:51891 "EHLO
	mx1.pingtimeout.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932999Ab3LDUou (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 4 Dec 2013 15:44:50 -0500
Message-ID: <529F943D.30004@pingtimeout.net>
Date: Wed, 04 Dec 2013 22:44:45 +0200
From: =?UTF-8?B?QW50dGkgVMO2bmt5csOk?= <daedalus@pingtimeout.net>
MIME-Version: 1.0
To: Dr Fields James Bruce <bfields@fieldses.org>
CC: Trond Myklebust <trond.myklebust@primarydata.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: Patch for mapping EILSEQ into NFSERR_INVAL
References: <529CEBC3.8060505@pingtimeout.net> <FA468B61-5F7E-4A88-A0BD-13BCF115282E@primarydata.com> <529CF322.4080701@pingtimeout.net> <20131203204806.GA2648@fieldses.org> <20131203212210.GC2648@fieldses.org> <529ED1C8.70208@pingtimeout.net> <20131204154104.GB14646@fieldses.org>
In-Reply-To: <20131204154104.GB14646@fieldses.org>
Content-Type: text/plain; charset=UTF-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 2013-12-04 17:41, Dr Fields James Bruce wrote:
> On Wed, Dec 04, 2013 at 08:55:04AM +0200, Antti Tönkyrä wrote:
>> On 2013-12-03 23:22, Dr Fields James Bruce wrote:
>>> On Tue, Dec 03, 2013 at 03:48:06PM -0500, Dr Fields James Bruce wrote:
>>>> OK, it makes sense that touching a file with a bad name would get an
>>>> error, but you're seeing that cause later creates of files on the same
>>>> filesystem fail.  I can't figure out why that would happen.
>>> ...
>>>
>>> So maybe there's some other problem here, but...
>>>
>>>>>>> Given that widely used ntfs-3g FUSE module also returns EILSEQ on the same case (I tested this) I would argue that a fix should be done for upstream especially since RFC5661 clearly defines that invalid UTF-8 sequence should map into NFSERR_INVAL, exact quote: "Where the client sends an invalid UTF-8 string, the server should return NFS4ERR_INVAL (see Table 5)".
>>>>>> The NFS client will then happily map that straight into EINVAL for you...
>>> This seems like a spec bug?
>>>
>>> NFS4ERR_INVAL only makes sense if you could really mandate UTF-8 on the
>>> wire all the time.  But I don't know what other error would work.
>>>
>>> I guess a client could map INVAL to EILSEQ on open or lookup (is there
>>> any other reason a correct client should ever see INVAL on those ops?).
>>> Or do that only if fs_charset is supported and has
>>> FSCHARSET_CAP4_ALLOWS_ONLY_UTF8 set.  Yuch.
>>>
>>> --b.
>> Hello,
>>
>> I don't really think it's an issue if we don't do any mapping here
>> either, I/O error is perfectly acceptable to me but the whole share
>> dying is of course not very desirable...
>>
>> I have been conducting my tests with ntfs-3g for now and after
>> applying my patch to map EILSEQ into INVAL I didn't witness the
>> share dying anymore. I captured network traffic from both cases
>> (urls below). The tests were conducted so that after mounting the
>> NFS share a file was opened (with w-mode) after which pcap was
>> started. After that the following commands were executed:
>>
>> touch `echo -e $'\some_bad_sequence'` (I tested these with \377 and \375)
>> <wait a bit>
>> touch something
>>
>> http://daedalus.pingtimeout.net/dbg/eilseq_ioerr.pcap
>> http://daedalus.pingtimeout.net/dbg/eilseq_mapped.pcap
>>
>> With mapping patch applied, the bad sequence touch returns invalid
>> argument but doesn't kill the share as somewhat visible from the
>> pcap.
> The later creates show up as opens for "something", and the server's
> resending with NFSERR_IO on the open.
>
> So, thanks, that probably rules out any client-side bug.
>
> Since you're testing a fuse filesystem--is there an easy way to get some
> debugging info out of it?  E.g. is it running as an ntfs-3g daemon that
> you can strace?
>
> --b.
Looks like I can strace it and I did an example strace, if you need 
something more specific please do tell. Command log has completion 
timestamps for associating what part of strace happened at what command.

http://daedalus.pingtimeout.net/dbg/strace-ioerr.txt
http://daedalus.pingtimeout.net/dbg/strace-commandlog.txt

And just in case you missed my other mail, the I/O error doesn't kill 
the share if using NFSv3 (mount -t nfs -o vers=3,intr,hard ...). The 
initial I/O error happens but the share doesn't die even when there are 
file handles open there.

- Antti
