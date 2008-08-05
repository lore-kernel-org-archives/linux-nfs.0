From: Steve Dickson <SteveD@redhat.com>
Subject: Re: nfs-utils and unfsd
Date: Tue, 05 Aug 2008 14:13:05 -0400
Message-ID: <48989831.2030808@RedHat.com>
References: <959E2970-49E6-425C-A10D-2D486913CD3F@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Neil Brown <neilb@suse.de>,
	Linux NFS Mailing List <linux-nfs@vger.kernel.org>
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:39837 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1761044AbYHESOy (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 5 Aug 2008 14:14:54 -0400
In-Reply-To: <959E2970-49E6-425C-A10D-2D486913CD3F@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



Chuck Lever wrote:
> There is a generic RPC server helper in nfs-utils called rpc_init(). 
> This API will need to be modified to support IPv6 in statd and mountd,
> at least.
> 
> However, there is a comment inside support/nfs/rpcmisc.c, where
> rpc_init() resides, that suggests that this interface is also used by
> unfsd.
> 
> Is it OK for me to modify nfs-utils' copy of this function, or is there
> any kind of ABI restriction between unfsd and nfs-utils?
I don't see any problem... Is there even a supported/maintained version
of unfsd out there today? I did a quick google search and didn't find
anything but man pages... 

steved.
