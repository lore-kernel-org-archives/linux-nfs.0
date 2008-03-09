From: Jan Engelhardt <jengelh-bdq14YP6qtRlEiWPh9xO2Q@public.gmane.org>
Subject: Re: READDIRPLUS max mount option
Date: Sun, 9 Mar 2008 17:16:36 +0100 (CET)
Message-ID: <Pine.LNX.4.64.0803091713440.26142@fbirervta.pbzchgretzou.qr>
References: <47D1995E.6060501@krose.org>  <1204919978.16746.12.camel@heimdal.trondhjem.org>
  <47D1A0F5.2070501@krose.org> <1204922570.16746.37.camel@heimdal.trondhjem.org>
 <47D1ADC5.1050108@krose.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Trond Myklebust <trond.myklebust@fys.uio.no>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	linux-nfs@vger.kernel.org
To: Kyle Rose <krose-x8616dYPWyvYtjvyW6yDsg@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from sovereign.computergmbh.de ([85.214.69.204]:34004 "EHLO
	sovereign.computergmbh.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750769AbYCIQQh (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 9 Mar 2008 12:16:37 -0400
In-Reply-To: <47D1ADC5.1050108-x8616dYPWyvYtjvyW6yDsg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Mar 7 2008 16:04, Kyle Rose wrote:
>> Since we're talking about what is really a quite arbitrary limit, I can
>> certainly see an argument for why we might want a way to change it, but
>> I'm still not convinced that we need to be setting this parameter at the
>> mountpoint level.
>
> Fair enough.  A proc entry to alter this globally would be an acceptable
> compromise for me, even if my local sysadmins might not like it.
>
sysfs, no? A module parameter is easy for a global default and is
the minimum thing to do :)
