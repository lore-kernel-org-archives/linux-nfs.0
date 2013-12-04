Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.pingtimeout.net ([194.187.214.64]:51287 "EHLO
	mx1.pingtimeout.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932128Ab3LDMkN (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 4 Dec 2013 07:40:13 -0500
Message-ID: <529F22A9.1030808@pingtimeout.net>
Date: Wed, 04 Dec 2013 14:40:09 +0200
From: =?ISO-8859-1?Q?Antti_T=F6nkyr=E4?= <daedalus@pingtimeout.net>
MIME-Version: 1.0
To: Dr Fields James Bruce <bfields@fieldses.org>
CC: Trond Myklebust <trond.myklebust@primarydata.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: Patch for mapping EILSEQ into NFSERR_INVAL
References: <529CEBC3.8060505@pingtimeout.net> <FA468B61-5F7E-4A88-A0BD-13BCF115282E@primarydata.com> <529CF322.4080701@pingtimeout.net> <20131203204806.GA2648@fieldses.org> <20131203212210.GC2648@fieldses.org> <529F211E.9000003@pingtimeout.net>
In-Reply-To: <529F211E.9000003@pingtimeout.net>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 2013-12-04 14:33, Antti Tönkyrä wrote:
> On 2013-12-03 23:22, Dr Fields James Bruce wrote:
>> On Tue, Dec 03, 2013 at 03:48:06PM -0500, Dr Fields James Bruce wrote:
>>> OK, it makes sense that touching a file with a bad name would get an
>>> error, but you're seeing that cause later creates of files on the same
>>> filesystem fail.  I can't figure out why that would happen.
>> ...
>>
>> So maybe there's some other problem here, but...
>>
>>>>>> Given that widely used ntfs-3g FUSE module also returns EILSEQ on 
>>>>>> the same case (I tested this) I would argue that a fix should be 
>>>>>> done for upstream especially since RFC5661 clearly defines that 
>>>>>> invalid UTF-8 sequence should map into NFSERR_INVAL, exact quote: 
>>>>>> "Where the client sends an invalid UTF-8 string, the server 
>>>>>> should return NFS4ERR_INVAL (see Table 5)".
>>>>> The NFS client will then happily map that straight into EINVAL for 
>>>>> you...
>> This seems like a spec bug?
>>
>> NFS4ERR_INVAL only makes sense if you could really mandate UTF-8 on the
>> wire all the time.  But I don't know what other error would work.
>>
>> I guess a client could map INVAL to EILSEQ on open or lookup (is there
>> any other reason a correct client should ever see INVAL on those ops?).
>> Or do that only if fs_charset is supported and has
>> FSCHARSET_CAP4_ALLOWS_ONLY_UTF8 set.  Yuch.
>>
>> --b.
> Ewh...
>
> I did some further testing and managed to get stale NFS file handles 
> instead of I/O errors on one run. (Haven't been able to repeat this 
> behaviour)
>
> After that I did another run (which errored with I/O errors) and found 
> out that I am able to touch existing files but not create any new 
> files. Touching an existing file changes the mtime as expected on both 
> the NFS share and backing FS so something is still being exchanged by 
> the NFS client and server. I also tested to write into a touchable 
> file but that returned an I/O error again.
>
> Example below:
> # ls -l p
> -rwxrwxrwx 1 root root 0 Dec  4 14:26 p
> # touch p
> # ls -l p
> -rwxrwxrwx 1 root root 0 Dec  4 14:31 p
> # touch newfile
> touch: cannot touch `newfile': Input/output error
> # echo test > p
> -su: p: Input/output error
>
> - Antti
>
Also might be worth noting that NFSv3 also emits the "nfsd: non-standard 
errno: -84" and touch command on client says "I/O error" but in NFSv3 
case the client doesn't start to I/O erroring on everything after that.

- Antti
