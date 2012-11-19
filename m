Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:64297 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752331Ab2KSVkt (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 19 Nov 2012 16:40:49 -0500
Message-ID: <50AAA75E.70703@RedHat.com>
Date: Mon, 19 Nov 2012 16:40:46 -0500
From: Steve Dickson <SteveD@redhat.com>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
CC: Chuck Lever <chuck.lever@oracle.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [RFC PATCH V2] mount: Added the -o v4.1 mount option
References: <1353339810-19126-1-git-send-email-steved@redhat.com>  <4FA345DA4F4AE44899BD2B03EEEC2FA9092EEE7A@SACEXCMBX04-PRD.hq.netapp.com>  <50AA571E.4090509@RedHat.com>  <4FA345DA4F4AE44899BD2B03EEEC2FA9092EEFD7@SACEXCMBX04-PRD.hq.netapp.com>  <50AA5AD4.5070808@RedHat.com>  <4FA345DA4F4AE44899BD2B03EEEC2FA9092EF0B3@SACEXCMBX04-PRD.hq.netapp.com>  <8B557EF0-A1F7-4487-8887-0B08F6922784@oracle.com> <4FA345DA4F4AE44899BD2B03EEEC2FA9092EF4AA@SACEXCMBX04-PRD.hq.netapp.com>
In-Reply-To: <4FA345DA4F4AE44899BD2B03EEEC2FA9092EF4AA@SACEXCMBX04-PRD.hq.netapp.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0



On 19/11/12 13:29, Myklebust, Trond wrote:
> Note that the mount command should in any case not be relying on rpcbind
> to decide whether or not the server supports NFSv4.
Of course.... 

> 
> As for minor version negotiation, RFC3530 already tells you how to do
> this: the client has to start with the highest version that it supports,
> and then walk that number down until the server stops replying with
> NFS4ERR_MINOR_VERS_MISMATCH.
Perfect... I think we should do *all* v4 negotiation from the mount 
command... It's so much acceptable to replace mount.nfs binaries 
than kernels... 

> 
> Note that if you want to do this in userland before calling the mount
> syscall, then the spec does allow you to "ping" the NFSv4 server with an
> empty COMPOUND.
The type of functionality will allow us to better deal with legacy servers, IMHO..

steved.

