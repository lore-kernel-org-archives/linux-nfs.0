Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:50620 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753300Ab1ASXut (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 19 Jan 2011 18:50:49 -0500
In-Reply-To: <1295480976.22151.23.camel@heimdal.trondhjem.org>
References: <20110119223543.30706.10304.stgit@matisse.1015granger.net>
	<1295479517.22151.16.camel@heimdal.trondhjem.org>
	<AANLkTikRX8nxh-gp=Fdr21dg-DLmUb2FxYXrM2A0hfN0@mail.gmail.com>
	<1295479900.22151.19.camel@heimdal.trondhjem.org>
	<AANLkTiknrso7mQbTiXNF3MLz+RPi52M1s+DV1XaxciO=@mail.gmail.com>
	<1295480976.22151.23.camel@heimdal.trondhjem.org>
Date: Thu, 20 Jan 2011 10:50:47 +1100
Message-ID: <AANLkTimwQJknzWHsMBFMpjiAe7qw5LktXMhXnQrKHoHA@mail.gmail.com>
Subject: Re: [PATCH] NFS: Fix "BUG at fs/aio.c:554!"
From: Nick Piggin <npiggin@gmail.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: Chuck Lever <chuck.lever@oracle.com>, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org, wen.gang.wang@oracle.com
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Thu, Jan 20, 2011 at 10:49 AM, Trond Myklebust
<Trond.Myklebust@netapp.com> wrote:
> On Thu, 2011-01-20 at 10:37 +1100, Nick Piggin wrote:
>> On Thu, Jan 20, 2011 at 10:31 AM, Trond Myklebust
>> <Trond.Myklebust@netapp.com> wrote:
>> > On Thu, 2011-01-20 at 10:26 +1100, Nick Piggin wrote:
>> >> On Thu, Jan 20, 2011 at 10:25 AM, Trond Myklebust
>>
>> >> > Also, why is EIO the correct reply when no bytes were read/written? Why
>> >> > shouldn't the VFS aio code be able to cope with a zero byte reply?
>> >>
>> >> What would it do?
>> >
>> > Just return that zero byte reply to userland.
>> >
>> > zero bytes is a valid reply for ordinary read() and write(), so why
>> > should we have to do anything different for aio_read()/aio_write()?
>>
>> It doesn't give userspace much to do. zero reply from read means
>> EOF. Zero reply from write is pretty useless, I don't think we do it
>> in the buffered write path -- we either ensure we write at least
>> something or have a meaningful error to return.
>
> zero reply from read means EOF _or_ user supplied a zero length buffer.
>
> zero reply from write may also be useless, but it is a valid value. It
> can simply mean the user supplied a zero length buffer.

OK, yes. I'm ignoring zero length request.
