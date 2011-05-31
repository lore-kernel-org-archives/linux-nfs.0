Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:60420 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751055Ab1EaOvG (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 31 May 2011 10:51:06 -0400
Message-ID: <4DE50058.8060602@netapp.com>
Date: Tue, 31 May 2011 10:51:04 -0400
From: Bryan Schumaker <bjschuma@netapp.com>
To: Ruediger Meier <sweet_f_a@gmx.de>
CC: linux-nfs@vger.kernel.org
Subject: Re: infinite getdents64 loop
References: <201105281502.32719.sweet_f_a@gmx.de> <201105291855.04487.sweet_f_a@gmx.de> <1306688643.2386.24.camel@lade.trondhjem.org> <201105301137.02061.sweet_f_a@gmx.de>
In-Reply-To: <201105301137.02061.sweet_f_a@gmx.de>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 05/30/2011 05:37 AM, Ruediger Meier wrote:
> On Sunday 29 May 2011, Trond Myklebust wrote:
>> It's actually a problem with the underlying filesystem: it is
>> generating readdir 'offsets' that are not unique. In other words, if
> 
> Does this mean ext4 generally does not work with for nfs?

It'll work for smaller directories, but when you get closer to about 300,000 entries this problem starts showing up.

- Bryan
> 
> 
> cu,
> Rudi
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

