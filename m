Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx11.netapp.com ([216.240.18.76]:42121 "EHLO mx11.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755143Ab3JXQab convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 24 Oct 2013 12:30:31 -0400
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: Christoph Anton Mitterer <calestyo@scientia.net>
CC: "<linux-nfs@vger.kernel.org>" <linux-nfs@vger.kernel.org>
Subject: Re: XATTRs in NFS?
Date: Thu, 24 Oct 2013 16:30:30 +0000
Message-ID: <625CAA34-BD6C-4283-86D0-3F8B460D54D0@netapp.com>
References: <1382560643.6924.12.camel@heisenberg.scientia.net>
 <EFB2CFAD-FACC-401D-BF0C-1C573B23A873@netapp.com>
 <1382624000.6907.8.camel@heisenberg.scientia.net>
 <E0F4C952-02DE-4778-A779-FB7AE111EC46@netapp.com>
 <1382630468.6907.58.camel@heisenberg.scientia.net>
In-Reply-To: <1382630468.6907.58.camel@heisenberg.scientia.net>
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Oct 24, 2013, at 5:01 PM, Christoph Anton Mitterer <calestyo@scientia.net> wrote:

> On Thu, 2013-10-24 at 14:32 +0000, Myklebust, Trond wrote:
>> Linux xattrs are a rabid mess.
> Well... might be from a technical POV, but for users they're quite
> useful in some scenarios.
> 
> 
>> The whole "system" namespace is something that cannot and should not ever be exposed on a network.
>> The "trusted" and "user" namespaces just offer specialised storage. Why are they needed?
> Well what I do is attaching integrity information to files.
> 
> You may say now that this is similar to what btrfs will provide
> anyway... but the problem with that is, that checksums are always
> updated when something in the system does valid changes to the file.
> 
> What I however want is that I really manually have to set this, so that
> I notice "accidental" changes, e.g. by myself or by buggy software...
> 
> 
>> If the data needs to follow the file, then store it in the file. Why do you need the filesystem to manage that for you?
> ... and since this applies to arbitrary files, from text-files over
> pictures, videos to binaries,... it's neither possible to store this in
> the file, nor can I really track this with an database,... since
> literally any program that uses such files, from the picture editor to
> the file-manager would need to use such DB.

Those programs need to recompute the checksum data anyway in order to verify and/or update it. Checksums that are computed by some third party application have exactly zero value for integrity checking.

Trond