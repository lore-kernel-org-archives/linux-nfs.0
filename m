From: Steve Dickson <SteveD@redhat.com>
Subject: Re: pNFS kernel for Fedora 15
Date: Sat, 23 Apr 2011 08:05:59 -0400
Message-ID: <4DB2C0A7.6090501@RedHat.com>
References: <4DB05BB3.8080706@desy.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: NFS list <linux-nfs@vger.kernel.org>
To: Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:60216 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751359Ab1DWMGH (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 23 Apr 2011 08:06:07 -0400
In-Reply-To: <4DB05BB3.8080706@desy.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 04/21/2011 12:30 PM, Tigran Mkrtchyan wrote:
> 
> Hi Steve et. al.
> 
> it looks like kernel fails to correctly work with
> rpc.gssd if some of kernel modules statically
> compiled:
> 
> BAD (pnfs kernel from Steve):
> CONFIG_SUNRPC_GSS=m
> CONFIG_RPCSEC_GSS_KRB5=y
> 
> in messages:
> [  537.544188] gss_create: Pseudoflavor 390003 not found!
> [  537.544236] RPC: Couldn't create auth handle (flavor 390003)
> 
> 
> GOOD (fedora native kernel or my own build):
> CONFIG_SUNRPC_GSS=m
> CONFIG_RPCSEC_GSS_KRB5=m
> 
> Steve, could you build new kernel with CONFIG_RPCSEC_GSS_KRB5=m ?
> 
> 
> BTW, there was a similar issue with nfsd discussed last couple of days.
> http://www.spinics.net/lists/linux-nfs/msg20617.html
I'll take a look... thanks!

steved.
