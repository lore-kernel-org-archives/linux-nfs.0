Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:52457 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751861Ab2KSVvS (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 19 Nov 2012 16:51:18 -0500
Message-ID: <50AAA9D1.2010705@RedHat.com>
Date: Mon, 19 Nov 2012 16:51:13 -0500
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: Chuck Lever <chuck.lever@oracle.com>
CC: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [RFC PATCH V2] mount: Added the -o v4.1 mount option
References: <1353339810-19126-1-git-send-email-steved@redhat.com> <30DFD4FD-3442-4F35-B576-EA597E21F4CE@oracle.com>
In-Reply-To: <30DFD4FD-3442-4F35-B576-EA597E21F4CE@oracle.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 19/11/12 13:21, Chuck Lever wrote:
> 
> As Trond points out, mount.nfs really should not use option "minorversion=" here, except on kernels that do not support "vers=4.x".  That will add complexity, certainly.
I agree... The patch I put out today was just an RFC... I just wanted to get the conversation started... 

> 
> In addition, I think we can expect the need for support for "v4.2" and "v4.0" (perhaps) in the near future, and then subsequently "v4.3" and so on.  Since that is close at hand, we should consider the need to add those as we design this.
Right, I thinking bring this type of negotiation back up to userland is the right thing to do... 

> 
> Perhaps instead of editing the mount option string directly in nfs_nfs_version(), you might add a "*minorversion" argument to nfs_nfs_version() function and let its callers finish the work, just as is done with "*version" today.  That might also make it easier to add the logic that changes behavior based on kernel version.
Let me digest this... I've noticed that in recent kernels that minorversion always seems to be set... 

steved.

