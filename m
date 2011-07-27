Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from lucidpixels.com ([72.73.18.11]:40204 "EHLO lucidpixels.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753453Ab1G0QfG (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 27 Jul 2011 12:35:06 -0400
Date: Wed, 27 Jul 2011 12:28:05 -0400 (EDT)
From: Justin Piszcz <jpiszcz@lucidpixels.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
cc: linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org, xfs@oss.sgi.com
Subject: Re: 2.6.xx: NFS: directory motion/cam2 contains a readdir loop
In-Reply-To: <20110727160752.GC974@fieldses.org>
Message-ID: <alpine.DEB.2.02.1107271227340.1451@p34.internal.lan>
References: <alpine.DEB.2.02.1107270952270.1451@p34.internal.lan> <20110727160752.GC974@fieldses.org>
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0



On Wed, 27 Jul 2011, J. Bruce Fields wrote:

> On Wed, Jul 27, 2011 at 09:54:09AM -0400, Justin Piszcz wrote:
>> Hi,
>>
>> Kernel 2.6.30 on client.
>> Kernel 2.6.28 on server.
>>
>> p34 kernel: [92223.918892] NFS: directory motion/cam2 contains a
>> readdir loop.  Please contact your server vendor.  Offending cookie: 10272
>
> What filesystem on the server are you exporting?

Hi,

xfs.
/dev/sda1 on / type xfs (rw,noatime)

Nothing special, thoughts?

Justin.

