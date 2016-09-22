Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-yw0-f175.google.com ([209.85.161.175]:33252 "EHLO
        mail-yw0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752777AbcIVE7m (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 22 Sep 2016 00:59:42 -0400
Received: by mail-yw0-f175.google.com with SMTP id i129so83827374ywb.0
        for <linux-nfs@vger.kernel.org>; Wed, 21 Sep 2016 21:59:41 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <093285F2-02F3-4485-AE6A-8B6409B3F03C@primarydata.com>
References: <CAKqBuofwLwUq0D8D_wnZ+f-ig1gO2QdSTjQ9ykkHb0NMaX3FoA@mail.gmail.com>
 <509BCC61-39B7-451D-A432-373F93D11673@primarydata.com> <CAKqBuocGR2TAnpgVLGiXj9atTna9O1yUk6j2ndhbmuZ3xAnrhg@mail.gmail.com>
 <093285F2-02F3-4485-AE6A-8B6409B3F03C@primarydata.com>
From: Mayur Bajaj <mbajaj@maprtech.com>
Date: Thu, 22 Sep 2016 10:29:40 +0530
Message-ID: <CAKqBuoev4=8AgLLtB-HobCEnkZ7X4H2vJrEafB-AvCPntH0Hsg@mail.gmail.com>
Subject: Re: NFS client behaviour with soft mount
To: Trond Myklebust <trondmy@primarydata.com>
Cc: List Linux NFS Mailing <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Thanks a lot.

On Thu, Sep 22, 2016 at 10:25 AM, Trond Myklebust
<trondmy@primarydata.com> wrote:
>
>> On Sep 22, 2016, at 00:39, Mayur Bajaj <mbajaj@maprtech.com> wrote:
>>
>> Thanks for the response.
>>
>> Incomplete data on server (NFS) is alright. I wanted to know what
>> happens to the dirty cache pages (on NFS client with soft mount and
>> sync flag not set) after the NFS client has retried for 3 times (or
>> retrans). Will the NFS client retry or give up and clean up the dirty
>> cache pages (and the dirty inode).
>
> As I said below, that behaviour is completely undefined. The page may end=
 up being discarded, or it may end up persisting in the page cache. If you =
want to be certain that any remaining dirty pages in the page cache have be=
en cleaned, then you need to successfully fsync() the file to disk.
>
>>
>> Mayur
>>
>> On Wed, Sep 21, 2016 at 8:11 PM, Trond Myklebust
>> <trondmy@primarydata.com> wrote:
>>>
>>>> On Sep 21, 2016, at 10:19, Mayur Bajaj <mbajaj@maprtech.com> wrote:
>>>>
>>>> Hello,
>>>>
>>>> I have a question regarding NFS client behaviour with soft mount. I
>>>> have gone through the code but could not figure out. Can someone
>>>> please help me.
>>>>
>>>> An application is writing data via NFS client (soft mount, with sync
>>>> mount option NOT set). The Application thinks that data written was
>>>> successful but that is not the case.
>>>> The NFS client will cache all the write request and flush after some
>>>> time/threshold. The NFS sever is not responding. NFS client retries
>>>> for 3 times (or retrans) and give up as the NFS server is not
>>>> responding.
>>>>
>>>> Will this cache pages be pinned in memory for ever or freed up (marked
>>>> clean) as the operation has failed?
>>>> Will NFS client keep on retrying again?
>>>
>>>
>>> The behaviour in the above situation is completely undefined. You may h=
ave bits and pieces of data persisted on the server or not, and cached data=
 may end up getting resent after the EIO was returned to the application.
>>>
>>
>
