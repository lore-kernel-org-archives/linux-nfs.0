Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx11.netapp.com ([216.240.18.76]:12432 "EHLO mx11.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755041Ab3KKS14 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 11 Nov 2013 13:27:56 -0500
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: Steve Dickson <SteveD@redhat.com>
CC: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] Adding the nfs4_secure_mounts bool
Date: Mon, 11 Nov 2013 18:25:14 +0000
Message-ID: <607B1346-570D-4CD6-8018-6F9C0A2B5318@netapp.com>
References: <1384037221-7224-1-git-send-email-steved@redhat.com>
 <E061C7A8-DC27-49BA-93C2-DC2E9C19EA7B@netapp.com>
 <52811CBB.3070204@RedHat.com>
In-Reply-To: <52811CBB.3070204@RedHat.com>
Content-Type: text/plain; charset="Windows-1252"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Nov 11, 2013, at 13:06, Steve Dickson <SteveD@redhat.com> wrote:

> 
> 
> On 09/11/13 18:12, Myklebust, Trond wrote:
>> One alternative to the above scheme, which I believe that I’ve 
>> suggested before, is to have a permanent entry in rpc_pipefs 
>> that rpc.gssd can open and that the kernel can use to detect 
>> that it is running. If we make it /var/lib/nfs/rpc_pipefs/gssd/clnt00/gssd, 
>> then AFAICS we don’t need to change nfs-utils at all, since all newer 
>> versions of rpc.gssd will try to open for read anything of the form 
>> /var/lib/nfs/rpc_pipefs/*/clntXX/gssd...
> 
> After further review I am going going have to disagree with you on this.
> Since all the context is cached on the initial mount the kernel

What context?

> should be using the call_usermodehelper() to call up to rpc.gssd 
> to get the context, which means we could put this upcall noise 
> to bed... forever! :-) 

No. We’re not adding yet another up call. We’ve already got two...

