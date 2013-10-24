Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:56473 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753793Ab3JXPHM (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 24 Oct 2013 11:07:12 -0400
Subject: Re: XATTRs in NFS?
From: Simo Sorce <simo@redhat.com>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Cc: Christoph Anton Mitterer <calestyo@scientia.net>,
        "<linux-nfs@vger.kernel.org>" <linux-nfs@vger.kernel.org>
In-Reply-To: <E0F4C952-02DE-4778-A779-FB7AE111EC46@netapp.com>
References: <1382560643.6924.12.camel@heisenberg.scientia.net>
	 <EFB2CFAD-FACC-401D-BF0C-1C573B23A873@netapp.com>
	 <1382624000.6907.8.camel@heisenberg.scientia.net>
	 <E0F4C952-02DE-4778-A779-FB7AE111EC46@netapp.com>
Content-Type: text/plain; charset="UTF-8"
Date: Thu, 24 Oct 2013 11:07:05 -0400
Message-ID: <1382627225.899.76.camel@willson.li.ssimo.org>
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 2013-10-24 at 14:32 +0000, Myklebust, Trond wrote:
> On Oct 24, 2013, at 3:13 PM, Christoph Anton Mitterer <calestyo@scientia.net> wrote:
> 
> > On Thu, 2013-10-24 at 08:45 +0000, Myklebust, Trond wrote:
> >> labeled NFS (i.e. security labels for NFS) is already supported in Linux 3.10 and newer.
> > Sure, but that doesn't really help me.
> > 
> > 
> >> There are no plans to merge general purpose xattrs.
> > Why not? Is it a big deal?
> > 
> 
> Linux xattrs are a rabid mess.

First time I hear this :)

> The whole "system" namespace is something that cannot and should not ever be exposed on a network.
> The "trusted" and "user" namespaces just offer specialised storage. Why are they needed?

Samba for example stores various metadata bits of information there (DOS
bits, original ACLs before posix translation, etc..).
Loosing that data on an mv via NFS breaks stuff.
That said samba and NFS have other synchronization issues, so it is not
the best example, but you can't just discount xattrs. They exist, they
are used, and if you don't have support for them in NFS you are not
transparent to applications.
 
> >> Please just use an application-specific database.
> > Well that won't work,... since that wouldn't be updated if e.g.
> > pathnames are changed by any program (cp, mv)
> 
> If the data needs to follow the file, then store it in the file. Why do you need the filesystem to manage that for you?

Because the filesystem can do that when multiple applications are
involved without having to change them all to talk to each other and
invent custom protocol all the time just to keep some additional
metadata associated to a file..

Simo.

-- 
Simo Sorce * Red Hat, Inc * New York

