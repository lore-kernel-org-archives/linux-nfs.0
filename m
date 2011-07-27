Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:39454 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753076Ab1G0S2s (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 27 Jul 2011 14:28:48 -0400
Message-ID: <4E3058CF.9020304@netapp.com>
Date: Wed, 27 Jul 2011 14:28:31 -0400
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

I can ls a directory with 500,000 files over nfs4.  That's usually enough to cause the readdir loop in ext4, so I guess this is a different problem.

> Is your export directory really located directly within / on /dev/sda1?
> 
> cu,
> Rudi

