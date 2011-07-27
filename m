Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:37635 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754879Ab1G0RJl (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 27 Jul 2011 13:09:41 -0400
Message-ID: <4E304652.5090708@netapp.com>
Date: Wed, 27 Jul 2011 13:09:38 -0400
From: Bryan Schumaker <bjschuma@netapp.com>
To: Ruediger Meier <sweet_f_a@gmx.de>
CC: Justin Piszcz <jpiszcz@lucidpixels.com>,
        "J. Bruce Fields" <bfields@fieldses.org>, linux-kernel@vger.kernel.org,
        linux-nfs@vger.kernel.org, xfs@oss.sgi.com
Subject: Re: 2.6.xx: NFS: directory motion/cam2 contains a readdir loop
References: <alpine.DEB.2.02.1107270952270.1451@p34.internal.lan> <alpine.DEB.2.02.1107271227340.1451@p34.internal.lan> <4E303F6F.8010706@netapp.com> <201107271900.11091.sweet_f_a@gmx.de>
In-Reply-To: <201107271900.11091.sweet_f_a@gmx.de>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 07/27/2011 01:00 PM, Ruediger Meier wrote:
> On Wednesday 27 July 2011, Bryan Schumaker wrote:
>> On 07/27/2011 12:28 PM, Justin Piszcz wrote:
>>> On Wed, 27 Jul 2011, J. Bruce Fields wrote:
>>>>
>>>> What filesystem on the server are you exporting?
>>>
>>> xfs.
>>> /dev/sda1 on / type xfs (rw,noatime)
>>>
>>> Nothing special, thoughts?
>>
>> Are there a lot of files in the directory you're exporting?  It looks
>> like cookie 10272 is mapped to multiple files.
> 
> I thought xfs is immune to readdir loops!?

I guess that depends how it generates the cookie... I want to try out the ext4 patches that were posted earlier today.  I'll double check xfs while I'm at it.

- Bryan

> Is your export directory really located directly within / on /dev/sda1?
> 
> cu,
> Rudi

