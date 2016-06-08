Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from linuxhacker.ru ([217.76.32.60]:48176 "EHLO fiona.linuxhacker.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754225AbcFHArE convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 7 Jun 2016 20:47:04 -0400
Subject: Re: Files leak from nfsd in 4.7.1-rc1 (and more?)
Mime-Version: 1.0 (Apple Message framework v1283)
Content-Type: text/plain; charset=windows-1252
From: Oleg Drokin <green@linuxhacker.ru>
In-Reply-To: <1465344205.3024.42.camel@poochiereds.net>
Date: Tue, 7 Jun 2016 20:46:55 -0400
Cc: "J. Bruce Fields" <bfields@fieldses.org>, linux-nfs@vger.kernel.org,
        "<linux-kernel@vger.kernel.org> Mailing List"
	<linux-kernel@vger.kernel.org>
Message-Id: <159BAB74-7CB7-4DD5-AB3D-6503106E0A90@linuxhacker.ru>
References: <4EDA6CFD-1FE8-4FCA-ACCF-84250BE342CB@linuxhacker.ru> <1465319435.3024.25.camel@poochiereds.net> <0F21EDD6-5CBB-4B5B-A1FF-E066011D18D6@linuxhacker.ru> <1465329897.3024.38.camel@poochiereds.net> <752F7196-1EE7-4FB3-8769-177131C8A793@linuxhacker.ru> <1465344205.3024.42.camel@poochiereds.net>
To: Jeff Layton <jlayton@poochiereds.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Jun 7, 2016, at 8:03 PM, Jeff Layton wrote:

> On Tue, 2016-06-07 at 19:39 -0400, Oleg Drokin wrote:
>> On Jun 7, 2016, at 4:04 PM, Jeff Layton wrote:
>>> So, the way this is supposed to work is that the stateids each hold a
>>> reference to the nfs4_file. They also take an fi_access reference for
>>> the open modes that they represent. This is how we know when it's OK to
>>> close one of the files in the fd[] slots. It might be interesting to
>>> also print out the fi_access counters if the slot hasn't been zeroed
>>> out if you feel up to it.
>> Ok, I have primed that and will let you know next time it triggers.
> Thanks. Maybe that will give us some idea of where to look…

Well, the counters are: 0 1 0 at the warning site, which is what
makes sense, really.

>>> I think though that the open upgrade accounting may be wrong.
>>> __nfs4_file_get_access does an unconditional atomic_inc, so if the
>>> client does a open for write and then opens again for read/write, then
>>> we may end up with too many write fi_access references taken.
>> 
>> The read-write access is all fine I think, because when dropping read or write
>> it also checks if the readwrite is filled?
>> Also whoever did that atomic_inc for get_access would eventually do put,
>> and that should free the file, no?
>> I was mostly thinking there's an error exit path somewhere that forgets to do
>> the put.
>> This also would explain the other pieces leaked that are not directly attached
>> into the nfs4_file.
>> 
>>> 
>>> That said, this code is quite subtle. I'd need to look over it in more
>>> detail before I offer up any fixes. I'd also appreciate it if anyone
>>> else wants to sanity check my analysis there.
>>> 
> 
> Yeah, I think you're right. It's fine since r/w opens have a distinct
> slot, even though the refcounting just tracks the number of read and
> write references. So yeah, the leak probably is in an error path
> someplace, or maybe a race someplace.

I guess I'll try to put some tracers in the code to try and match
refcount takers vs refcount droppers for lack of better ideas.

Hopefully that'll lead us to see who got the count that was not dropped.

