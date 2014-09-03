Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ig0-f170.google.com ([209.85.213.170]:55668 "EHLO
	mail-ig0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932437AbaICMnp (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 3 Sep 2014 08:43:45 -0400
Received: by mail-ig0-f170.google.com with SMTP id h3so5231034igd.1
        for <linux-nfs@vger.kernel.org>; Wed, 03 Sep 2014 05:43:44 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAHQdGtTU_ZDtQ0Y=1RuG3TbqNSgvBSVmg8Fm_77X6oZcJY4J8w@mail.gmail.com>
References: <CALXu0Ue8mn5ERuDM0J7YNYcubm9NDf-bHKqvYXZgTn7Uz7LEDA@mail.gmail.com>
	<CAHQdGtTU_ZDtQ0Y=1RuG3TbqNSgvBSVmg8Fm_77X6oZcJY4J8w@mail.gmail.com>
Date: Wed, 3 Sep 2014 14:43:44 +0200
Message-ID: <CALXu0UcXFphqD_JDCFpo=niaULoubFv-X9Fs4HErwB=9Ua0PqA@mail.gmail.com>
Subject: Re: Accessing alternate data streams on NFSv4 server?
From: Cedric Blancher <cedric.blancher@gmail.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 3 September 2014 14:22, Trond Myklebust
<trond.myklebust@primarydata.com> wrote:
> On Wed, Sep 3, 2014 at 5:14 AM, Cedric Blancher
> <cedric.blancher@gmail.com> wrote:
>> is there any utility which can be used to access alternate data
>> streams (which can be accessed on Solaris via O_XATTR or newer
>> bash/ksh versions via cd -@) on Linux?
>>
>> Ced
>
> No.

What can we do to access such data - except porting all stuff to
Windows or stick with Solaris/AIX?

Ced
-- 
Cedric Blancher <cedric.blancher@gmail.com>
Institute Pasteur
