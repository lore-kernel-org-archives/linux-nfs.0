Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.pingtimeout.net ([194.187.214.64]:47012 "EHLO
	mx1.pingtimeout.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754557Ab3LBUwy (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 2 Dec 2013 15:52:54 -0500
Message-ID: <529CF322.4080701@pingtimeout.net>
Date: Mon, 02 Dec 2013 22:52:50 +0200
From: =?ISO-8859-1?Q?Antti_T=F6nkyr=E4?= <daedalus@pingtimeout.net>
MIME-Version: 1.0
To: Trond Myklebust <trond.myklebust@primarydata.com>
CC: Dr Fields James Bruce <bfields@fieldses.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: Patch for mapping EILSEQ into NFSERR_INVAL
References: <529CEBC3.8060505@pingtimeout.net> <FA468B61-5F7E-4A88-A0BD-13BCF115282E@primarydata.com>
In-Reply-To: <FA468B61-5F7E-4A88-A0BD-13BCF115282E@primarydata.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 2013-12-02 22:45, Trond Myklebust wrote:
> On Dec 2, 2013, at 15:21, Antti Tönkyrä <daedalus@pingtimeout.net> wrote:
>
>> Hello,
>>
>> NTFS file system and some other filesystems seem to return EILSEQ when user passes badly formatted data. Current NFSv4 implementation does not map EILSEQ into any known NFSv4 error code which causes problems in some use cases. In my case I observed that if filesystem returns EILSEQ, the NFS share will begin I/O erroring until it's able to recover (If there are handles open to the files in the share, I/O errors will continue until they are closed after which the share recovers after small period of time).
>>
>> Given that widely used ntfs-3g FUSE module also returns EILSEQ on the same case (I tested this) I would argue that a fix should be done for upstream especially since RFC5661 clearly defines that invalid UTF-8 sequence should map into NFSERR_INVAL, exact quote: "Where the client sends an invalid UTF-8 string, the server should return NFS4ERR_INVAL (see Table 5)".
> The NFS client will then happily map that straight into EINVAL for you...
>
> Cheers,
>    Trond
Hello,

But if we get a (somewhat) sane error back, we'd avoid the whole NFS 
share dying in I/O errors because someone decided to touch a file with 
his terminal having wrong charset (if I understood this correctly). The 
problem here is that we don't simply get one I/O error from the 
offending file, but rather that the whole share dies after EILSEQ is 
returned from the backing filesystem.

BR, Antti
