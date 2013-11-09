Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:22919 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758322Ab3KIXMt convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 9 Nov 2013 18:12:49 -0500
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: Steve Dickson <SteveD@redhat.com>
CC: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] Adding the nfs4_secure_mounts bool
Date: Sat, 9 Nov 2013 23:12:45 +0000
Message-ID: <E061C7A8-DC27-49BA-93C2-DC2E9C19EA7B@netapp.com>
References: <1384037221-7224-1-git-send-email-steved@redhat.com>
In-Reply-To: <1384037221-7224-1-git-send-email-steved@redhat.com>
Content-Type: text/plain; charset="Windows-1252"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Nov 9, 2013, at 17:47, Steve Dickson <SteveD@redhat.com> wrote:

> The nfs4_secure_mounts controls whether security
> flavors will be tried during the establishing of
> NFSv4 state and the pseudoroot lookups.
> 
> This allows security daemon like rpc.gssd to
> tell the kernel that secure mounts should be tried.
> 
> To enable secure mounts:
>   echo "on" >  /proc/fs/nfsfs/secure
> 
> To disable secure mounts:
>   echo "off" >  /proc/fs/nfsfs/secure
> 
> Signed-off-by: Steve Dickson <steved@redhat.com>

Hi Steve,

So the rpc.gssd would flip the switch to “on” when it starts up and to “off” when it quits? What if someone does a ‘kill -9’?

One alternative to the above scheme, which I believe that I’ve suggested before, is to have a permanent entry in rpc_pipefs that rpc.gssd can open and that the kernel can use to detect that it is running. If we make it /var/lib/nfs/rpc_pipefs/gssd/clnt00/gssd, then AFAICS we don’t need to change nfs-utils at all, since all newer versions of rpc.gssd will try to open for read anything of the form /var/lib/nfs/rpc_pipefs/*/clntXX/gssd...

Cheers
  Trond