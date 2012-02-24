Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:64817 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752722Ab2BXNTm convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 24 Feb 2012 08:19:42 -0500
Subject: Re: [PATCH] SUNRPC: fix use-after-free of rpc pipes
Mime-Version: 1.0 (Apple Message framework v1084)
Content-Type: text/plain; charset=us-ascii
From: Fred Isaman <iisaman@netapp.com>
In-Reply-To: <4F4778C6.8050705@parallels.com>
Date: Fri, 24 Feb 2012 05:17:40 -0800
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Message-Id: <802ED333-DCE5-4EA5-ACDC-0269E8817EA7@netapp.com>
References: <1330019288-13031-1-git-send-email-iisaman@netapp.com> <4F4778C6.8050705@parallels.com>
To: Stanislav Kinsbursky <skinsbursky@parallels.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Feb 24, 2012, at 3:47 AM, Stanislav Kinsbursky wrote:

> BTW, it looks very strange...
> Now many networks namespaces do you use?
> 

Not sure, I definitely was not intentionally adding any, so I assume one.  This was reproduced on Fedora 12, Fedora 16 and recent RHEL distros with custom kernels installed.

The Fedora 16 install was a fresh install onto a VMWare Fusion guest with two NICs (one NAT and one bridged), though the bridged one was turned off.


Fred