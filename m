Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from lucidpixels.com ([72.73.18.11]:38202 "EHLO lucidpixels.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754879Ab1G0RPy (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 27 Jul 2011 13:15:54 -0400
Date: Wed, 27 Jul 2011 13:15:53 -0400 (EDT)
From: Justin Piszcz <jpiszcz@lucidpixels.com>
To: Bryan Schumaker <bjschuma@netapp.com>
cc: "J. Bruce Fields" <bfields@fieldses.org>, linux-kernel@vger.kernel.org,
        linux-nfs@vger.kernel.org, xfs@oss.sgi.com
Subject: Re: 2.6.xx: NFS: directory motion/cam2 contains a readdir loop
In-Reply-To: <4E303F6F.8010706@netapp.com>
Message-ID: <alpine.DEB.2.02.1107271315290.1451@p34.internal.lan>
References: <alpine.DEB.2.02.1107270952270.1451@p34.internal.lan> <20110727160752.GC974@fieldses.org> <alpine.DEB.2.02.1107271227340.1451@p34.internal.lan> <4E303F6F.8010706@netapp.com>
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0



On Wed, 27 Jul 2011, Bryan Schumaker wrote:

> On 07/27/2011 12:28 PM, Justin Piszcz wrote:
>>
>>
>> On Wed, 27 Jul 2011, J. Bruce Fields wrote:
>>
>>> On Wed, Jul 27, 2011 at 09:54:09AM -0400, Justin Piszcz wrote:
>>>> Hi,
>>>>
>>>> Kernel 2.6.30 on client.
>>>> Kernel 2.6.28 on server.
>>>>
>>>> p34 kernel: [92223.918892] NFS: directory motion/cam2 contains a
>>>> readdir loop.  Please contact your server vendor.  Offending cookie: 10272
>>>
>>> What filesystem on the server are you exporting?
>>
>> Hi,
>>
>> xfs.
>> /dev/sda1 on / type xfs (rw,noatime)
>>
>> Nothing special, thoughts?
>
> Are there a lot of files in the directory you're exporting?  It looks like cookie 10272 is mapped to multiple files. When the client tries to resume reading from this cookie, xfs will reply from the first matching file and cause the client to enter a loop.

Should I be using a different filesystem?

user@atom:/d1$ cd /d1/motion/cam1
user@atom:/d1/motion/cam1$ ls|wc
    5198    5198  140346
user@atom:/d1/motion/cam1$

Justin.


