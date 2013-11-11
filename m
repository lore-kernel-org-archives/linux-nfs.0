Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:10337 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753821Ab3KKSFw (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 11 Nov 2013 13:05:52 -0500
Message-ID: <52811CBB.3070204@RedHat.com>
Date: Mon, 11 Nov 2013 13:06:51 -0500
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
CC: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] Adding the nfs4_secure_mounts bool
References: <1384037221-7224-1-git-send-email-steved@redhat.com> <E061C7A8-DC27-49BA-93C2-DC2E9C19EA7B@netapp.com>
In-Reply-To: <E061C7A8-DC27-49BA-93C2-DC2E9C19EA7B@netapp.com>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 09/11/13 18:12, Myklebust, Trond wrote:
> One alternative to the above scheme, which I believe that I’ve 
> suggested before, is to have a permanent entry in rpc_pipefs 
> that rpc.gssd can open and that the kernel can use to detect 
> that it is running. If we make it /var/lib/nfs/rpc_pipefs/gssd/clnt00/gssd, 
> then AFAICS we don’t need to change nfs-utils at all, since all newer 
> versions of rpc.gssd will try to open for read anything of the form 
> /var/lib/nfs/rpc_pipefs/*/clntXX/gssd...

After further review I am going going have to disagree with you on this.
Since all the context is cached on the initial mount the kernel
should be using the call_usermodehelper() to call up to rpc.gssd 
to get the context, which means we could put this upcall noise 
to bed... forever! :-) 

I realize this is not going happen overnight, so I would still
like to propose my  nfs4_secure_mounts bool patch as bridge
to the new call_usermodehelper()  since its the cleanest 
solution so far... 

Thoughts?

steved.
