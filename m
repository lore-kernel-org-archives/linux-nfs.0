From: Ben Greear <greearb@candelatech.com>
Subject: Re: Error mounting FC8 NFS server with 2.6.31-rc3 NFSv4 client.
Date: Tue, 21 Jul 2009 14:50:58 -0700
Message-ID: <4A663842.7040607@candelatech.com>
References: <4A64EB1F.4000602@candelatech.com>	 <1248178527.5222.0.camel@heimdal.trondhjem.org>	 <4A65F184.5060802@candelatech.com>	 <1248196339.21343.8.camel@heimdal.trondhjem.org>	 <4A65FCB2.6080903@candelatech.com>	 <1248199140.21343.17.camel@heimdal.trondhjem.org>	 <4A660295.9020807@candelatech.com>	 <1248200897.21343.19.camel@heimdal.trondhjem.org>	 <4A6609A9.3000504@candelatech.com>	 <1248211050.21343.38.camel@heimdal.trondhjem.org> <1248212939.5034.1.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: linux-kernel <linux-kernel@vger.kernel.org>,
	linux-nfs@vger.kernel.org
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:50722 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755529AbZGUVvD (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 21 Jul 2009 17:51:03 -0400
In-Reply-To: <1248212939.5034.1.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 07/21/2009 02:48 PM, Trond Myklebust wrote:

>> Note that there is a bug remaining inside nfs4_init_session(): we
>> shouldn't be copying the rsize/wsize into the nfs_client if the latter
>> was already initialised. I'm going to leave that for the moment, though,
>> since that bug wasn't introduced by my patch, and it doesn't affect
>> NFSv4.0.
>
> With that patch applied, I now get the expected behaviour when mounting
> a server with no NFSv4 root from a 2.6.31-rc3 based client:
>
> root@heimdal:~# mount -t nfs4 munkholm.local:/ /mnt
> mount.nfs4: mounting munkholm.local:/ failed, reason given by server:
>    No such file or directory
>
> Trond

I just successfully tested it on my systems as well, so I think this
does indeed fix the problem.

Thanks!
Ben


-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

