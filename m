Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:57964 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932804Ab3DSVWb convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 19 Apr 2013 17:22:31 -0400
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: "Schumaker, Bryan" <Bryan.Schumaker@netapp.com>
CC: "bfields@fieldses.org" <bfields@fieldses.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH v2 1/2] nfs: Send atime and mtime as a 64bit value
Date: Fri, 19 Apr 2013 21:22:29 +0000
Message-ID: <1366406549.12513.1.camel@leira.trondhjem.org>
References: <1366402178-1281-1-git-send-email-bjschuma@netapp.com>
	 <1366402178-1281-2-git-send-email-bjschuma@netapp.com>
In-Reply-To: <1366402178-1281-2-git-send-email-bjschuma@netapp.com>
Content-Type: text/plain; charset=US-ASCII
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 2013-04-19 at 16:09 -0400, bjschuma@netapp.com wrote:
> From: Bryan Schumaker <bjschuma@netapp.com>
> 
> RFC 3530 says that the seconds value of a nfstime4 structure is a 64bit
> value, but we are instead sending a 32-bit 0 and then a 32bit conversion
> of the 64bit Linux value.  This means that if we try to set atime to a
> value before the epoch (touch -t 196001010101) the client will only send
> part of the new value due to lost precision.
> 
> Signed-off-by: Bryan Schumaker <bjschuma@netapp.com>

Thanks Bryan! Applied.

I assume that Bruce will pick up the 2/2.

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com
