From: Martin Vogt <martin.vogt@itwm.fraunhofer.de>
Subject: Re: permission denied with >= ~2.6.25
Date: Tue, 25 May 2010 10:14:58 +0200
Message-ID: <4BFB8702.1070606@itwm.fraunhofer.de>
References: <4BE7ED5D.90801@itwm.fraunhofer.de> <4BE93940.5070804@itwm.fraunhofer.de> <4BED1E44.4020708@itwm.fraunhofer.de> <20100516175213.GA9225@lts032.itwm.fhg.de> <4BF25109.40300@itwm.fraunhofer.de> <4BF3C7A4.8030906@itwm.fraunhofer.de> <20100519171347.GB8137@fieldses.org> <4BF500C9.2010904@itwm.fraunhofer.de> <20100521173908.GD9639@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mailgw1.uni-kl.de ([131.246.120.220]:45801 "EHLO
	mailgw1.uni-kl.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753247Ab0EYIPB (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 25 May 2010 04:15:01 -0400
Received: from itwm2.itwm.fhg.de (itwm2.itwm.fhg.de [131.246.191.3])
	by mailgw1.uni-kl.de (8.14.3/8.14.3/Debian-5+lenny1) with ESMTP id o4P8EwVG010906
	(version=TLSv1/SSLv3 cipher=EDH-RSA-DES-CBC3-SHA bits=168 verify=NOT)
	for <linux-nfs@vger.kernel.org>; Tue, 25 May 2010 10:14:59 +0200
Received: from mail1.itwm.fhg.de ([131.246.191.78]:35205)
	by itwm2.itwm.fhg.de with esmtps (TLSv1:DES-CBC3-SHA:168)
	(/C=DE/ST=Rheinland-Pfalz/L=Kaiserslautern/O=Fraunhofer ITWM/OU=SLG/CN=mail1.itwm.fhg.de)(verified=1)
	 (Exim 4.66 #1)
	id 1OGpHu-0001WA-Ow
	for linux-nfs@vger.kernel.org; Tue, 25 May 2010 10:14:58 +0200
In-Reply-To: <20100521173908.GD9639@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

J. Bruce Fields wrote:
> On Thu, May 20, 2010 at 11:28:41AM +0200, Martin Vogt wrote:
>> J. Bruce Fields wrote:
>>> On Wed, May 19, 2010 at 01:12:36PM +0200, Martin Vogt wrote:
>>>> Martin Vogt wrote:
>>>>> Hello,
>>>>>
>>>>>
>>>>> today I tried 2.6.34 on server/client with standard
>>>>> hardware. After around the 69th checkout I had an
>>>>> "Invalid cross-device link" Error.
>>>>> (Before that it was EIO/EPERM)
>>>>>
>>>>> Test ran for around 9 hours before it failed.
>>>>>
>>>>>> svn: In directory 'Kernel-pxe3-69.EZvgHTmbzv/include/asm-sparc'
>>>>>> svn: Can't move
>>>>> 'Kernel-pxe3-69.EZvgHTmbzv/include/asm-sparc/resource.h.tmp'
>>>>>> to 'Kernel-pxe3-69.EZvgHTmbzv/include/asm-sparc/resource.h': Invalid
>>>>>> cross-device link
>>>>>> Mon May 17 23:46:32 CEST 2010,1
>>>>>> runcounter: 69
>>>> Ok.
>>>> RTFM: no_subtree_check :-(
>>>>
>>>> This option made the checkouts reliable.
>>> Erp.  Should have thought of that.  It's no longer the default in recent
>>> nfs-utils, for this sort of reason.
>>>
>>> (But, note: for anyone exporting directories that aren't mountpoints,
>>> that may expose more of their filesystem than intended.)
>>>
>> Hello,
>>
>> the report for the latest kernel was done with "no_subtree_check"
> 
> OK, sorry, I don't know.
> 
> You've been varying both client and server, but from your initial
> reports it sounded like this was something that first started happening
> on a client upgrade?
> 

Yes. I tried to go back with the kernels on the client.
(and keep the server fixed)
But up to 2.6.16 I had this svn error. Up to this time
I didn't know that no_subtree_check would increase the
stability that much.
All my tests were done with "subtree_check", except
the tests with 2.6.34 kernel on server/client.

On this server no_subtree_check was the default because of newer nfs-utils.

With this kernel it took ~9hours until I got the "Invalid cross-device
link".

> Have you been able to keep the server fixed while doing a binary search
> through the client version for the first non-working client?

No, test were done with "subtree_check" and as first
I thought that older clients are stable, but that's not true.
It only takes more time until svn aborts.


But the abort after 9hours was only one tests.
I will start the test again and see how long it takes
until it aborts.


Martin
