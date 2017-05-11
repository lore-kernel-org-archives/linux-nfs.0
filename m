Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wm0-f41.google.com ([74.125.82.41]:38323 "EHLO
        mail-wm0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755224AbdEKILI (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 11 May 2017 04:11:08 -0400
Received: by mail-wm0-f41.google.com with SMTP id 142so26311111wma.1
        for <linux-nfs@vger.kernel.org>; Thu, 11 May 2017 01:11:07 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20170511073857.GL390@ZenIV.linux.org.uk>
References: <149443309780.2378.6532276992468576087.stgit@warthog.procyon.org.uk>
 <149443323117.2378.6029610622093309047.stgit@warthog.procyon.org.uk> <20170511073857.GL390@ZenIV.linux.org.uk>
From: Miklos Szeredi <mszeredi@redhat.com>
Date: Thu, 11 May 2017 10:11:06 +0200
Message-ID: <CAOssrKcq5MRmN1NnywOxCx6366PY4R9auEeFOjgD1YURXHK0fg@mail.gmail.com>
Subject: Re: [PATCH 14/14] Add commands to create or update a superblock
To: Al Viro <viro@zeniv.linux.org.uk>
Cc: David Howells <dhowells@redhat.com>,
        Jeff Layton <jlayton@redhat.com>,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>,
        linux-nfs@vger.kernel.org, lkml <linux-kernel@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, May 11, 2017 at 9:38 AM, Al Viro <viro@zeniv.linux.org.uk> wrote:
> On Wed, May 10, 2017 at 05:20:31PM +0100, David Howells wrote:
>
>> @@ -64,8 +70,8 @@ struct sb_config_operations {
>>       int (*parse_option)(struct sb_config *sc, char *p);
>>       int (*monolithic_mount_data)(struct sb_config *sc, void *data);
>>       int (*validate)(struct sb_config *sc);
>> -     struct dentry *(*mount)(struct sb_config *sc);
>> -     int (*fill_super)(struct super_block *s, struct sb_config *sc);
>> +     int (*create_super)(struct sb_config *sc);
>
> Hell, NO.
>
> The primary effect of that thing is *NOT* to create a superblock.  It
> might be a side effect, and quite often it will happen, but the
> real goal here is a mountable tree.  Which might or might not reside
> on a new superblock.  And which might very well involve no object
> creation whatsoever.
>
> This name is actively misleading and the same goes for its relatives
> (vfs_create_super(), etc.).  It's "give me a tree to mount", not
> "create something or other".

Indeed, I haven't thought of that.  And there's a good hornet's nest
waiting to poke ones hand into: mounting the same blockdev with
different options will get you either

 - EBUSY if the MS_* flags mismatch
 - silently ignored options in any other case

which is far from being nice and consistent.

Thanks,
Miklos
