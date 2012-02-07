Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:33750 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756088Ab2BGTF6 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 7 Feb 2012 14:05:58 -0500
Message-ID: <4F31760B.10801@RedHat.com>
Date: Tue, 07 Feb 2012 14:05:47 -0500
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
CC: "Adamson, Dros" <Weston.Adamson@netapp.com>,
        Boaz Harrosh <bharrosh@panasas.com>,
        Chuck Lever <chuck.lever@oracle.com>,
        "<linux-nfs@vger.kernel.org>" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] NFS: add mount options 'v4.0' and 'v4.1'
References: <1328633351-1741-1-git-send-email-dros@netapp.com>	 <A5356E85-1E22-4C4C-A30C-58A912AE3C9F@oracle.com>	 <4F316BC4.4030504@panasas.com>	 <904F47FA-7497-49DA-B1DF-C113ACB26059@netapp.com>	 <1328640084.4124.26.camel@lade.trondhjem.org> <1328640482.4124.29.camel@lade.trondhjem.org>
In-Reply-To: <1328640482.4124.29.camel@lade.trondhjem.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 02/07/2012 01:48 PM, Myklebust, Trond wrote:
> On Tue, 2012-02-07 at 13:41 -0500, Trond Myklebust wrote:
>> That said, I see the 'vers=4' being reserved for auto-negotiation of
>> minor version, and the 'vers=4.x' as requiring a specific minor version
>> number.
>> The way auto-negotiation is supposed to work is laid out in
>> RFC3530(-bis): the client attempts the largest minor version that it
>> supports, and the server replies with an OK, or a MINOR_VERSION_MISMATCH
>> depending on whether it supports that minor version or not. If not, the
>> client retries with the next largest minor version, .... rince, repeat
>> until successful...
> 
> BTW: There is no reason why we should need to do this auto-negotiation
> in kernel space. As we've learned with major version negotiation, it can
> be more flexible to just teach the 'mount' command to do the actual
> probing, since that allows the user better control over the process via
> global configuration files...
> 
+1 

Its also much easier to debug and fix bugs... People are much more willing
to take a mount command update than a kernel update...  

steved.
