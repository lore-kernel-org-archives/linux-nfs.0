Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail.aixigo.de ([80.149.209.52]:65433 "EHLO mail.aixigo.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932440AbaGOHrH (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 15 Jul 2014 03:47:07 -0400
Message-ID: <53C4DC6C.1050108@aixigo.de>
Date: Tue, 15 Jul 2014 09:46:52 +0200
From: Harald Dunkel <harald.dunkel@aixigo.de>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: NFS service inside a container
References: <539B0683.3020605@aixigo.de> <20140711201503.GC11931@fieldses.org>
In-Reply-To: <20140711201503.GC11931@fieldses.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 07/11/14 22:15, J. Bruce Fields wrote:
> 
> Yeah, we should really get that fixed.  It can probably be worked around
> by reverting to the old reboot recovery method.
> 

I would be highly interested. Is the old method still in the kernel
sources, maybe supported by a config option?


Regards
Harri

