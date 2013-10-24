Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx11.netapp.com ([216.240.18.76]:9365 "EHLO mx11.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754747Ab3JXOcq convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 24 Oct 2013 10:32:46 -0400
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: Christoph Anton Mitterer <calestyo@scientia.net>
CC: "<linux-nfs@vger.kernel.org>" <linux-nfs@vger.kernel.org>
Subject: Re: XATTRs in NFS?
Date: Thu, 24 Oct 2013 14:32:40 +0000
Message-ID: <E0F4C952-02DE-4778-A779-FB7AE111EC46@netapp.com>
References: <1382560643.6924.12.camel@heisenberg.scientia.net>
 <EFB2CFAD-FACC-401D-BF0C-1C573B23A873@netapp.com>
 <1382624000.6907.8.camel@heisenberg.scientia.net>
In-Reply-To: <1382624000.6907.8.camel@heisenberg.scientia.net>
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Oct 24, 2013, at 3:13 PM, Christoph Anton Mitterer <calestyo@scientia.net> wrote:

> On Thu, 2013-10-24 at 08:45 +0000, Myklebust, Trond wrote:
>> labeled NFS (i.e. security labels for NFS) is already supported in Linux 3.10 and newer.
> Sure, but that doesn't really help me.
> 
> 
>> There are no plans to merge general purpose xattrs.
> Why not? Is it a big deal?
> 

Linux xattrs are a rabid mess.

The whole "system" namespace is something that cannot and should not ever be exposed on a network.
The "trusted" and "user" namespaces just offer specialised storage. Why are they needed?

> 
>> Please just use an application-specific database.
> Well that won't work,... since that wouldn't be updated if e.g.
> pathnames are changed by any program (cp, mv)

If the data needs to follow the file, then store it in the file. Why do you need the filesystem to manage that for you?

Cheers
  Trond