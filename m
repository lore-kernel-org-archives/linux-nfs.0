Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail.aixigo.de ([80.149.209.52]:61503 "EHLO mail.aixigo.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754086AbaGOH4j (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 15 Jul 2014 03:56:39 -0400
Message-ID: <53C4DEB2.9060307@aixigo.de>
Date: Tue, 15 Jul 2014 09:56:34 +0200
From: Harald Dunkel <harald.dunkel@aixigo.de>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: NFS service inside a container
References: <539B0683.3020605@aixigo.de> <20140711201503.GC11931@fieldses.org> <53C4DC6C.1050108@aixigo.de>
In-Reply-To: <53C4DC6C.1050108@aixigo.de>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 07/15/14 09:46, Harald Dunkel wrote:
> On 07/11/14 22:15, J. Bruce Fields wrote:
>>
>> Yeah, we should really get that fixed.  It can probably be worked around
>> by reverting to the old reboot recovery method.
>>
> 
> I would be highly interested. Is the old method still in the kernel
> sources, maybe supported by a config option?
> 

PS: Should I create a bug report?


Regards
Harri

