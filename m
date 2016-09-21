Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from us-smtp-delivery-194.mimecast.com ([216.205.24.194]:28784 "EHLO
        us-smtp-delivery-194.mimecast.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1757448AbcIUOmO (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 21 Sep 2016 10:42:14 -0400
From: Trond Myklebust <trondmy@primarydata.com>
To: Mayur Bajaj <mbajaj@maprtech.com>
CC: List Linux NFS Mailing <linux-nfs@vger.kernel.org>
Subject: Re: NFS client behaviour with soft mount
Date: Wed, 21 Sep 2016 14:41:55 +0000
Message-ID: <509BCC61-39B7-451D-A432-373F93D11673@primarydata.com>
References: <CAKqBuofwLwUq0D8D_wnZ+f-ig1gO2QdSTjQ9ykkHb0NMaX3FoA@mail.gmail.com>
In-Reply-To: <CAKqBuofwLwUq0D8D_wnZ+f-ig1gO2QdSTjQ9ykkHb0NMaX3FoA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=WINDOWS-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


> On Sep 21, 2016, at 10:19, Mayur Bajaj <mbajaj@maprtech.com> wrote:
>=20
> Hello,
>=20
> I have a question regarding NFS client behaviour with soft mount. I
> have gone through the code but could not figure out. Can someone
> please help me.
>=20
> An application is writing data via NFS client (soft mount, with sync
> mount option NOT set). The Application thinks that data written was
> successful but that is not the case.
> The NFS client will cache all the write request and flush after some
> time/threshold. The NFS sever is not responding. NFS client retries
> for 3 times (or retrans) and give up as the NFS server is not
> responding.
>=20
> Will this cache pages be pinned in memory for ever or freed up (marked
> clean) as the operation has failed?
> Will NFS client keep on retrying again?


The behaviour in the above situation is completely undefined. You may have =
bits and pieces of data persisted on the server or not, and cached data may=
 end up getting resent after the EIO was returned to the application.

