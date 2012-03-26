Return-Path: linux-nfs-owner@vger.kernel.org
Received: from natasha.panasas.com ([67.152.220.90]:50702 "EHLO
	natasha.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750703Ab2CZTHy (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 26 Mar 2012 15:07:54 -0400
Message-ID: <4F70BE77.7060902@panasas.com>
Date: Mon, 26 Mar 2012 12:07:35 -0700
From: Boaz Harrosh <bharrosh@panasas.com>
MIME-Version: 1.0
To: "Matt W. Benjamin" <matt@linuxbox.com>
CC: linux-nfs <linux-nfs@vger.kernel.org>,
        Ganesha NFS List <nfs-ganesha-devel@lists.sourceforge.net>,
        Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: unlink within an open directory stream
References: <1974178651.72.1332788099966.JavaMail.root@thunderbeast.private.linuxbox.com>
In-Reply-To: <1974178651.72.1332788099966.JavaMail.root@thunderbeast.private.linuxbox.com>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 03/26/2012 11:55 AM, Matt W. Benjamin wrote:

> Hi,
> 
> Boaz:  we do not any longer send a readdir index.  We do send a cookieverf.
> 
> Fist of all, I haven't established that the issue we're actually observing is caused
> by the Linux client sending old cookies to readdir(something).  However, if it is,
> it's in no way better to try to make cookies "more persistent."  Nor should the Linux
> client be expecting it.  The assumption is simply flawed.  The protocol introduced
> cookie verifier (a LONG time ago) for a reason.
> 
> Matt


Please don't top-post in a Linux-mailing lists. Us Linux guys are not used to it
and get confused.

Regarding the cookie-verifier it looks like the Linux client never supported
that. So even if it will start to, from here on, we are in trouble with old
clients.

Since we are in the business of being bug backward compatible then fixing the
client will not help. Because you must agree the easiest is to fix bonnie++
but that's a privilege we do not have.

I think we should imitate the behavior of knfsd+exfs3 I'm sure it's easy for
Ganesha to fix it. Lets talk about it in this week call. I have ideas that
will not change current code, just a small enhancement.

Thanks
Boaz

> ----- "Boaz Harrosh" <bharrosh@panasas.com> wrote:
> 
>> On 03/26/2012 11:25 AM, Myklebust, Trond wrote:
>>
>>> On Mon, 2012-03-26 at 11:17 -0700, Boaz Harrosh wrote:
>>>> On 03/24/2012 10:12 AM, Myklebust, Trond wrote:
>>>>
>>>>
>>>> It's the new (post RHEL 6.0 Kernel) NFS need for opendir after an
>> unlink.
>>>
>>> What?
>>>
>>
>>
>> The links below report on regression in RHEL 6.2 which have a new NFS
>> implementation where  6.0 used to be fine.
>> (Or it's what I understood from the reporters)
>>
>> <snip>
>>
>>>
>>
>>> No.
>>>
>>> If the server supports permanent readdir cookies, then there is no
>> need
>>> for opendir after unlink.
>>>
>>> If the server does not have permanent readdir cookies, then our
>> client
>>> has never supported it anyway (nor will it ever do so). That whole
>>> 'cookieverf' READDIR bullshit has never provided a workable model
>> for a
>>> POSIX client...
>>
>>
>> Thanks Trond for the explanation. Forgive my slowness. So you are
>> saying that with knfsd it's actually filesystem dependent and maybe
>> the reporters did not compare apples-to-apples and the difference is
>> in the behind file system.
>>
>> Matt I'm sure Trond is right with regard to Ganesha, because we
>> send a readdir index and a cookieverf, which will change after
>> unlink. Since the application does not call opendir again the
>> client will send the old cookies, which is now a different file
>> or might get out-of-bounds for Ganesha.
>>
>> Let me think about it a bit. I'm sure we can send a Better
>> 64bit cookie, which will be more persistent, even across unlinks.
>>
>>>
>>>
>>
>>
>> Thanks
>> Boaz
> 


