Return-Path: linux-nfs-owner@vger.kernel.org
Received: from aserp1040.oracle.com ([141.146.126.69]:43390 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754301Ab3KKSaS convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 11 Nov 2013 13:30:18 -0500
Content-Type: text/plain; charset=windows-1252
Mime-Version: 1.0 (Mac OS X Mail 6.6 \(1510\))
Subject: Re: [PATCH] Adding the nfs4_secure_mounts bool
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <52811CBB.3070204@RedHat.com>
Date: Mon, 11 Nov 2013 13:30:08 -0500
Cc: "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <E520DD5F-7E5A-4B6C-9FF6-6B74DA36FD1E@oracle.com>
References: <1384037221-7224-1-git-send-email-steved@redhat.com> <E061C7A8-DC27-49BA-93C2-DC2E9C19EA7B@netapp.com> <52811CBB.3070204@RedHat.com>
To: Steve Dickson <SteveD@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Nov 11, 2013, at 1:06 PM, Steve Dickson <SteveD@redhat.com> wrote:

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
> should be using the call_usermodehelper() to call up to rpc.gssd 
> to get the context, which means we could put this upcall noise 
> to bed... forever! :-)

Ask Al Viro for his comments on whether the kernel should start gssd (either a daemon or a script).  Hint: wear your kevlar underpants.

Have you tried Trond's approach yet?

> I realize this is not going happen overnight, so I would still
> like to propose my  nfs4_secure_mounts bool patch as bridge
> to the new call_usermodehelper()  since its the cleanest 
> solution so far... 
> 
> Thoughts?

We have workarounds already that work on every kernel since 3.8.

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




