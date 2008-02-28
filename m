From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [regression] nfs4: 30 second delay during umount of remote fs
	on system shutdown
Date: Thu, 28 Feb 2008 13:46:58 -0800
Message-ID: <1204235218.7109.13.camel@heimdal.trondhjem.org>
References: <200802281829.16343.elendil@planet.nl>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
To: Frans Pop <elendil-EIBgga6/0yRmR6Xm/wNWPw@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from pat.uio.no ([129.240.10.15]:53465 "EHLO pat.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753719AbYB1VrD (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 28 Feb 2008 16:47:03 -0500
In-Reply-To: <200802281829.16343.elendil-EIBgga6/0yRmR6Xm/wNWPw@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Thu, 2008-02-28 at 18:29 +0100, Frans Pop wrote:

> I have verified that portmap is also not running during S31umountnfs.sh with 
> 2.6.24, so apparently there has been a change in the kernel that has made 
> umount look for portmap and cause the 30 second delay if it is not running.

You are probably seeing the effect of lockd going down: it always
attempts to unregister from the portmapper (and no, this is _not_ new
behaviour).

If debian is killing the portmapper while lockd is still up, then that
is a definite debian bug...

Trond

