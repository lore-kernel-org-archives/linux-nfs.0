From: Steve Dickson <SteveD@redhat.com>
Subject: Re: Default supported enctypes in rpc.gssd
Date: Tue, 08 Apr 2008 07:33:28 -0400
Message-ID: <47FB5808.80706@RedHat.com>
References: <47FA931A.8080602@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-nfs@vger.kernel.org
To: Vince Busam <vbusam@google.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:59569 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751686AbYDHLkD (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 8 Apr 2008 07:40:03 -0400
In-Reply-To: <47FA931A.8080602@google.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



Vince Busam wrote:
> Is there a reason the patch to use kernel supported enctypes from
> http://www.citi.umich.edu/projects/nfsv4/linux/nfs-utils-patches/1.1.1-1/nfs-utils-1.1.1-007-gssd_use_kernel_supported_enctypes.dif
> 
> wasn't included in the 1.1.2 release?  It would be nice to at least
> increase the default list to match what this patch does ("1,3,2", adding
> ENCTYPE_DES_CBC_MD4 & ENCTYPE_DES_CBC_MD5).
Not sure how I missed these.... but I'll try to get them in asap...

Thanks for pointing this out.

steved.
