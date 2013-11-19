Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:3741 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753297Ab3KSWnb convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 19 Nov 2013 17:43:31 -0500
From: "Adamson, Andy" <William.Adamson@netapp.com>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
CC: "Adamson, Andy" <William.Adamson@netapp.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH Version 3 1/1] NFSv4 wait on recovery for async session
 errors
Date: Tue, 19 Nov 2013 22:43:29 +0000
Message-ID: <C662575C-1FBD-4E72-B569-0BD4FC6BFE47@netapp.com>
References: <1384551376-8734-1-git-send-email-andros@netapp.com>
 <1384897797.45997.1.camel@leira.trondhjem.org>
 <1384900469.45997.2.camel@leira.trondhjem.org>
In-Reply-To: <1384900469.45997.2.camel@leira.trondhjem.org>
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Why not recover the lease? Shouldn't NFS4ERR_EXPIRED be left for the async handler?

-->Andy

On Nov 19, 2013, at 5:34 PM, "Myklebust, Trond" <Trond.Myklebust@netapp.com>
 wrote:

> On Tue, 2013-11-19 at 16:49 -0500, Trond Myklebust wrote:
>> There is a second patch that goes with this problem. Please see the
>> following attachment.
> 
> V2: Don't return an error when we know that the stateid is no longer
> valid.
> 
> -- 
> Trond Myklebust
> Linux NFS client maintainer
> 
> NetApp
> Trond.Myklebust@netapp.com
> www.netapp.com
> <0001-NFSv4-Update-list-of-irrecoverable-errors-on-DELEGRE.patch>

