Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-vc0-f177.google.com ([209.85.220.177]:33348 "EHLO
	mail-vc0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932263AbaICM5X (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 3 Sep 2014 08:57:23 -0400
Received: by mail-vc0-f177.google.com with SMTP id hq11so8586920vcb.22
        for <linux-nfs@vger.kernel.org>; Wed, 03 Sep 2014 05:57:22 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CALXu0UcXFphqD_JDCFpo=niaULoubFv-X9Fs4HErwB=9Ua0PqA@mail.gmail.com>
References: <CALXu0Ue8mn5ERuDM0J7YNYcubm9NDf-bHKqvYXZgTn7Uz7LEDA@mail.gmail.com>
	<CAHQdGtTU_ZDtQ0Y=1RuG3TbqNSgvBSVmg8Fm_77X6oZcJY4J8w@mail.gmail.com>
	<CALXu0UcXFphqD_JDCFpo=niaULoubFv-X9Fs4HErwB=9Ua0PqA@mail.gmail.com>
Date: Wed, 3 Sep 2014 08:57:22 -0400
Message-ID: <CAHQdGtT11awbgNY7AiNEr=D-+3W-fsCRyw3quHmcRJT1nzdQQA@mail.gmail.com>
Subject: Re: Accessing alternate data streams on NFSv4 server?
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Cedric Blancher <cedric.blancher@gmail.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Sep 3, 2014 at 8:43 AM, Cedric Blancher
<cedric.blancher@gmail.com> wrote:
> On 3 September 2014 14:22, Trond Myklebust
> <trond.myklebust@primarydata.com> wrote:
>> On Wed, Sep 3, 2014 at 5:14 AM, Cedric Blancher
>> <cedric.blancher@gmail.com> wrote:
>>> is there any utility which can be used to access alternate data
>>> streams (which can be accessed on Solaris via O_XATTR or newer
>>> bash/ksh versions via cd -@) on Linux?
>>>
>>> Ced
>>
>> No.
>
> What can we do to access such data - except porting all stuff to
> Windows or stick with Solaris/AIX?

You have asked this question before. There is nothing new to add to
the previous mailing threads.

There is no support for Solaris style subfiles on any Linux
filesystem, including NFS. I'm not aware of anyone having any plans to
add such support after Reiser4 died. There is no indication that POSIX
is anywhere near ready to accept O_XATTR or any other interfaces to
support subfiles.

-- 
Trond Myklebust

Linux NFS client maintainer, PrimaryData

trond.myklebust@primarydata.com
