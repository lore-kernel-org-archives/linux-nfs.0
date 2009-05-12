From: Shehjar Tikoo <shehjart-iP+wyIN8Xge1Z/+hSey0Gg@public.gmane.org>
Subject: Re: Different rsize/wsize for different NFS server software
Date: Tue, 12 May 2009 20:53:40 +0530
Message-ID: <4A09947C.9030206@zresearch.com>
References: <4A0959F9.1010107@zresearch.com>	 <4A097DE9.6030709@zresearch.com> <1242137345.21939.6.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from [12.204.100.226] ([12.204.100.226]:51411 "EHLO gluster.com"
	rhost-flags-FAIL-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1756725AbZELPV3 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 12 May 2009 11:21:29 -0400
In-Reply-To: <1242137345.21939.6.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Trond Myklebust wrote:
> On Tue, 2009-05-12 at 19:17 +0530, Shehjar Tikoo wrote:
>> Shehjar Tikoo wrote:
...
...
...
>> Is there any way to force the client to use a 64k wsize value?
> 
> You probably have the exact same filesystem still mounted somewhere else
> on that client. A 2.6.18 kernel will, in those circumstances, share the
> same super block with both mount points, and will therefore not permit
> you to use different mount options.

That was, in fact, the case.

Thanks
Shehjar

> 
> This is something which has been fixed in more recent kernels.
> 

> Trond
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 

