Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:6033 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752667Ab1G0QkR (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 27 Jul 2011 12:40:17 -0400
Message-ID: <4E303F6F.8010706@netapp.com>
Date: Wed, 27 Jul 2011 12:40:15 -0400
From: Bryan Schumaker <bjschuma@netapp.com>
To: Justin Piszcz <jpiszcz@lucidpixels.com>
CC: "J. Bruce Fields" <bfields@fieldses.org>, linux-kernel@vger.kernel.org,
        linux-nfs@vger.kernel.org, xfs@oss.sgi.com
Subject: Re: 2.6.xx: NFS: directory motion/cam2 contains a readdir loop
References: <alpine.DEB.2.02.1107270952270.1451@p34.internal.lan> <20110727160752.GC974@fieldses.org> <alpine.DEB.2.02.1107271227340.1451@p34.internal.lan>
In-Reply-To: <alpine.DEB.2.02.1107271227340.1451@p34.internal.lan>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 07/27/2011 12:28 PM, Justin Piszcz wrote:
> 
> 
> On Wed, 27 Jul 2011, J. Bruce Fields wrote:
> 
>> On Wed, Jul 27, 2011 at 09:54:09AM -0400, Justin Piszcz wrote:
>>> Hi,
>>>
>>> Kernel 2.6.30 on client.
>>> Kernel 2.6.28 on server.
>>>
>>> p34 kernel: [92223.918892] NFS: directory motion/cam2 contains a
>>> readdir loop.  Please contact your server vendor.  Offending cookie: 10272
>>
>> What filesystem on the server are you exporting?
> 
> Hi,
> 
> xfs.
> /dev/sda1 on / type xfs (rw,noatime)
> 
> Nothing special, thoughts?

Are there a lot of files in the directory you're exporting?  It looks like cookie 10272 is mapped to multiple files. When the client tries to resume reading from this cookie, xfs will reply from the first matching file and cause the client to enter a loop.

- Bryan

> 
> Justin.
> 
> -- 
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

