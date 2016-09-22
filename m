Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from us-smtp-delivery-194.mimecast.com ([216.205.24.194]:31956 "EHLO
        us-smtp-delivery-194.mimecast.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1753761AbcIVEzN (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 22 Sep 2016 00:55:13 -0400
From: Trond Myklebust <trondmy@primarydata.com>
To: Mayur Bajaj <mbajaj@maprtech.com>
CC: List Linux NFS Mailing <linux-nfs@vger.kernel.org>
Subject: Re: NFS client behaviour with soft mount
Date: Thu, 22 Sep 2016 04:55:06 +0000
Message-ID: <093285F2-02F3-4485-AE6A-8B6409B3F03C@primarydata.com>
References: <CAKqBuofwLwUq0D8D_wnZ+f-ig1gO2QdSTjQ9ykkHb0NMaX3FoA@mail.gmail.com>
 <509BCC61-39B7-451D-A432-373F93D11673@primarydata.com>
 <CAKqBuocGR2TAnpgVLGiXj9atTna9O1yUk6j2ndhbmuZ3xAnrhg@mail.gmail.com>
In-Reply-To: <CAKqBuocGR2TAnpgVLGiXj9atTna9O1yUk6j2ndhbmuZ3xAnrhg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=WINDOWS-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


> On Sep 22, 2016, at 00:39, Mayur Bajaj <mbajaj@maprtech.com> wrote:
>=20
> Thanks for the response.
>=20
> Incomplete data on server (NFS) is alright. I wanted to know what
> happens to the dirty cache pages (on NFS client with soft mount and
> sync flag not set) after the NFS client has retried for 3 times (or
> retrans). Will the NFS client retry or give up and clean up the dirty
> cache pages (and the dirty inode).

As I said below, that behaviour is completely undefined. The page may end u=
p being discarded, or it may end up persisting in the page cache. If you wa=
nt to be certain that any remaining dirty pages in the page cache have been=
 cleaned, then you need to successfully fsync() the file to disk.

>=20
> Mayur
>=20
> On Wed, Sep 21, 2016 at 8:11 PM, Trond Myklebust
> <trondmy@primarydata.com> wrote:
>>=20
>>> On Sep 21, 2016, at 10:19, Mayur Bajaj <mbajaj@maprtech.com> wrote:
>>>=20
>>> Hello,
>>>=20
>>> I have a question regarding NFS client behaviour with soft mount. I
>>> have gone through the code but could not figure out. Can someone
>>> please help me.
>>>=20
>>> An application is writing data via NFS client (soft mount, with sync
>>> mount option NOT set). The Application thinks that data written was
>>> successful but that is not the case.
>>> The NFS client will cache all the write request and flush after some
>>> time/threshold. The NFS sever is not responding. NFS client retries
>>> for 3 times (or retrans) and give up as the NFS server is not
>>> responding.
>>>=20
>>> Will this cache pages be pinned in memory for ever or freed up (marked
>>> clean) as the operation has failed?
>>> Will NFS client keep on retrying again?
>>=20
>>=20
>> The behaviour in the above situation is completely undefined. You may ha=
ve bits and pieces of data persisted on the server or not, and cached data =
may end up getting resent after the EIO was returned to the application.
>>=20
>=20

