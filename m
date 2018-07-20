Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-vk0-f48.google.com ([209.85.213.48]:37603 "EHLO
        mail-vk0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S2388036AbeGTUPT (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 20 Jul 2018 16:15:19 -0400
Received: by mail-vk0-f48.google.com with SMTP id v72-v6so925107vkd.4
        for <linux-nfs@vger.kernel.org>; Fri, 20 Jul 2018 12:25:39 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <839932d583bf0962c636f4494cf9f387d4aba6fd.camel@hammerspace.com>
References: <CAN-5tyHi8g-WS451xrGOfgjaSzthVKYwdLK77Cy+Bah_2qF+KA@mail.gmail.com>
 <839932d583bf0962c636f4494cf9f387d4aba6fd.camel@hammerspace.com>
From: Olga Kornievskaia <aglo@umich.edu>
Date: Fri, 20 Jul 2018 15:25:38 -0400
Message-ID: <CAN-5tyGDnctzTRkbVB_oT5oZc+4PiywUZQV9RYh-pT2iuxMt5Q@mail.gmail.com>
Subject: Re: Another question about v3 attribute handling
To: Trond Myklebust <trondmy@hammerspace.com>
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Jul 20, 2018 at 2:50 PM, Trond Myklebust
<trondmy@hammerspace.com> wrote:
> On Fri, 2018-07-20 at 14:44 -0400, Olga Kornievskaia wrote:
>> Hi Trond,
>>
>> This is a different question but is related to the attribute
>> handling.
>>
>> What I see in v4, is that say the client received a reply to the OPEN
>> with before and after change_attr values for the directory. We check
>> if the before value is the same as what we have in the cache and if
>> it's not then we invalidate the directory attributes.
>>
>> It seems that we don't have similar check for the v3. If in v3, the
>> server returned a before that was different from what could be seen
>> on
>> the network trace as the before for the directory, it does not
>> trigger
>> invalidation. Is this expected because it's v3 or is this a bug?
>
> Doesn't the call to  nfs_post_op_update_inode(dir, data->res.dir_attr)
> in nfs3_do_create() do the right thing?

Dah, I knew I was missing something. Thanks.
