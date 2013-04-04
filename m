Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ve0-f179.google.com ([209.85.128.179]:57895 "EHLO
	mail-ve0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1762357Ab3DDPwx (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 4 Apr 2013 11:52:53 -0400
Received: by mail-ve0-f179.google.com with SMTP id cz11so2820750veb.10
        for <linux-nfs@vger.kernel.org>; Thu, 04 Apr 2013 08:52:53 -0700 (PDT)
MIME-Version: 1.0
Reply-To: tigran.mkrtchyan@desy.de
In-Reply-To: <1365090480.10726.22.camel@leira.trondhjem.org>
References: <CAGue13pe_ZH_Eto-jL3mLjTNGFK26izTarnZdjs3eL82A2Z37w@mail.gmail.com>
	<20130404151507.GA8484@umich.edu>
	<CAGue13o6X5S3ppTX_fmMCTCX=7Mq_57YQEsb_hkOKwN9iOHwEQ@mail.gmail.com>
	<1365090480.10726.22.camel@leira.trondhjem.org>
Date: Thu, 4 Apr 2013 17:52:52 +0200
Message-ID: <CAGue13oq=COS6vJyQ_W1HSB8Zo4QR_pcQfunEuApemJ8C94S9g@mail.gmail.com>
Subject: Re: readdir vs. getattr
From: Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Cc: Jim Rees <rees@umich.edu>, linux-nfs <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Apr 4, 2013 at 5:48 PM, Myklebust, Trond
<Trond.Myklebust@netapp.com> wrote:
> On Thu, 2013-04-04 at 17:38 +0200, Tigran Mkrtchyan wrote:
>> On Thu, Apr 4, 2013 at 5:15 PM, Jim Rees <rees@umich.edu> wrote:
>> > Tigran Mkrtchyan wrote:
>> >
>> >   we have a directory with 50K (number of )  files in it.
>> >   The user does a 'ls' and I can see READDIR4. To
>> >   get the complete listing a client need to send ~380 requests.
>> >   Now user does yet another 'ls' in the same directory.
>> >   The client sends a GETATTR  on directorie's FH
>> >   (actually two of GETATTRS - why?!!) and discovers that a
>> >   directory didn't change and re-uses existing listing, BUT!!!
>> >   for each file in the directory it sends a GETATTR to discover
>> >   is  the file's attributes are changed. For 50K files it's a 50K requests.
>> >
>> > So is this a "ls -l"? Because for "ls" it shouldn't stat all the files.
>>
>> I believe it's 'ls -l'.  Well, you probably want to say that it's ls
>> calling stat on each file. Nevertheless client still should re-use
>> cached information.
>
> What makes you think that it isn't using cached information? I'm
well, wireshark tells me that. either timeout is too short or cache
size is too small.
It's quite strange behavior when fist 'ls' is much faster than second one.
I will play with the timeouts and will let you know.

Tigran.

> guessing you just need to adjust the values of acregmin and acregmax
> upwards.
>
> That said, we might be able to be a little more intelligent about how we
> use the NFS_INO_ADVISE_RDPLUS hint, and have it blow out the readdir
> cache when we find ourselves doing lots of lookup revalidates.
>
> --
> Trond Myklebust
> Linux NFS client maintainer
>
> NetApp
> Trond.Myklebust@netapp.com
> www.netapp.com
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
