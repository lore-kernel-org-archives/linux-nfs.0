From: Steve Dickson <SteveD@redhat.com>
Subject: Re: [nfs-utils PATCH] retry on EPERM from NFSv4 mount attempt
Date: Mon, 07 Dec 2009 17:27:45 -0500
Message-ID: <4B1D8161.8090300@RedHat.com>
References: <19211.7054.291514.185591@notabene.brown>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-nfs@vger.kernel.org
To: Neil Brown <neilb@suse.de>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:7510 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934201AbZLGW1o (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 7 Dec 2009 17:27:44 -0500
In-Reply-To: <19211.7054.291514.185591-wvvUuzkyo1EYVZTmpyfIwg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 11/23/2009 06:32 PM, Neil Brown wrote:
> 
> Hi,
>  I recently packaged nfs-utils 1.2.1 for openSUSE and fairly quickly
>  got a bug report - "-o nfsvers=3" was needed to mount NFSv3
>  filesystems.
> 
>  mount.nfs in 1.2.1 will first try a v4 mount but will fall-back to v3
>  if it gets ENOENT.  This works fine.
>  However for kernel prior to 2.6.25, you don't get ENOENT, you get
>  EPERM.
>  In that case the fall-back to v3 doesn't happen and you get a failure
>  to mount.
> 
>  So I think we need to fall back on EPERM as well.  See below.
Committed! We have to... but the line in the sand is drawn... 

steved.
