Return-Path: linux-nfs-owner@vger.kernel.org
Received: from plane.gmane.org ([80.91.229.3]:32918 "EHLO plane.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751341AbaLRM7y (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 18 Dec 2014 07:59:54 -0500
Received: from list by plane.gmane.org with local (Exim 4.69)
	(envelope-from <glN-linux-nfs@m.gmane.org>)
	id 1Y1agJ-0001EO-UD
	for linux-nfs@vger.kernel.org; Thu, 18 Dec 2014 13:59:51 +0100
Received: from p4ff58315.dip0.t-ipconnect.de ([79.245.131.21])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-nfs@vger.kernel.org>; Thu, 18 Dec 2014 13:59:51 +0100
Received: from holger.hoffstaette by p4ff58315.dip0.t-ipconnect.de with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-nfs@vger.kernel.org>; Thu, 18 Dec 2014 13:59:51 +0100
To: linux-nfs@vger.kernel.org
From: Holger =?iso-8859-1?q?Hoffst=E4tte?=
	<holger.hoffstaette@googlemail.com>
Subject: Re: 3.18.1: broken directory with one file too many
Date: Thu, 18 Dec 2014 12:59:39 +0000 (UTC)
Message-ID: <pan.2014.12.18.12.59.39@googlemail.com>
References: <pan.2014.12.16.22.19.18@googlemail.com>
	<20141217212159.GA11517@fieldses.org> <5492C710.20104@googlemail.com>
	<pan.2014.12.18.12.51.56@googlemail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: linux-kernel@vger.kernel.org
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 18 Dec 2014 12:51:56 +0000, Holger Hoffstätte wrote:

> On Thu, 18 Dec 2014 13:22:40 +0100, Holger Hoffstätte wrote:
> 
>> Meanwhile I'll try older/plain (unpatched) kernels. So far reverting
>> the client to vanilla 3.18.1 or 3.14.27 has not helped..
> 
> Rebooted the server into 3.14.27 (latest longterm stable), dropped
> caches on the client and the problem is gone: listing the directory
> works fine.

And just for good measure vanilla 3.18.0 also shows the problem, so it's 
not a .0/.1 regression.

I'm afraid that's all I can do for now. :/

thanks
Holger

