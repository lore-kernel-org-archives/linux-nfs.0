From: "Kevin Coffman" <kwc@citi.umich.edu>
Subject: Re: Default supported enctypes in rpc.gssd
Date: Tue, 8 Apr 2008 07:47:54 -0400
Message-ID: <4d569c330804080447i4b0d6353ld66f33fcac22737d@mail.gmail.com>
References: <47FA931A.8080602@google.com> <47FB5808.80706@RedHat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "Vince Busam" <vbusam@google.com>, linux-nfs@vger.kernel.org
To: "Steve Dickson" <SteveD@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from yw-out-2324.google.com ([74.125.46.30]:47074 "EHLO
	yw-out-2324.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752619AbYDHLsD (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 8 Apr 2008 07:48:03 -0400
Received: by yw-out-2324.google.com with SMTP id 5so329160ywb.1
        for <linux-nfs@vger.kernel.org>; Tue, 08 Apr 2008 04:47:55 -0700 (PDT)
In-Reply-To: <47FB5808.80706-AfCzQyP5zfLQT0dZR+AlfA@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Apr 8, 2008 at 7:33 AM, Steve Dickson <SteveD@redhat.com> wrote:
>
>
>  Vince Busam wrote:
>  > Is there a reason the patch to use kernel supported enctypes from
>  > http://www.citi.umich.edu/projects/nfsv4/linux/nfs-utils-patches/1.1.1-1/nfs-utils-1.1.1-007-gssd_use_kernel_supported_enctypes.dif
>  >
>  > wasn't included in the 1.1.2 release?  It would be nice to at least
>  > increase the default list to match what this patch does ("1,3,2", adding
>  > ENCTYPE_DES_CBC_MD4 & ENCTYPE_DES_CBC_MD5).
>  Not sure how I missed these.... but I'll try to get them in asap...
>
>  Thanks for pointing this out.

Hi Steve,
This patch isn't ready for mainline.  The kernel interface is still
being worked out.  I'll look to see if you need a different patch to
allow ENCTYPE_DES_CBC_MD4 & ENCTYPE_DES_CBC_MD5.

K.C.
