Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:45477 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753496Ab3J2C2o convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 28 Oct 2013 22:28:44 -0400
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: Christoph Anton Mitterer <calestyo@scientia.net>
CC: Wheeler Ric <rwheeler@redhat.com>, Anand Avati <aavati@redhat.com>,
        "Dr Fields James Bruce" <bfields@redhat.com>,
        Mailing List Linux NFS <linux-nfs@vger.kernel.org>,
        Dickson Steve <steved@redhat.com>
Subject: Re: XATTRs in NFS?
Date: Tue, 29 Oct 2013 02:28:40 +0000
Message-ID: <875BFA1C-0305-49FF-85ED-7B156666AE85@netapp.com>
References: <20131028180838.GG31322@fieldses.org>
 <526EC3F7.3090601@gmail.com> <526EFFCC.2060506@redhat.com>
 <18F0636D-7CE0-42C1-9249-325DF69516D4@netapp.com>
 <526F0893.5030700@redhat.com>
 <A7C1B206-12CD-4958-9528-A8D9C9847011@netapp.com>
 <1383010758.8774.97.camel@heisenberg.scientia.net>
In-Reply-To: <1383010758.8774.97.camel@heisenberg.scientia.net>
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Oct 28, 2013, at 9:39 PM, Christoph Anton Mitterer <calestyo@scientia.net> wrote:

> Trond,... since you ask for motivations pro NFS-XATTRs, I wondered what
> are the strong reasons against?

As I've already told you: you're asking for the addition of a feature which is inadequately defined, and is not documented in any standard.

> Of course someone has to do the work,... but that's not really and
> argument pro or con NFS-XATTRs, is it?
> 
> The security problems with namespaces like trusted. or so can probably
> be solved quite easy, e.g. simply by not supporting or
> ignoring/rejecting them.
> 
> You've mentioned caching issues,... could you elaborate a bit on that?
> How is that much different from caching any other file metadata NFS
> transfers?

The standard metadata such as ctime, mtime, size, .... are all part of an existing NFS caching model called close-to-open. We know how they change when the filesystem data changes.

How do I know when it is safe to cache your checksum xattr? I don't even know what it is, let alone what its relation is to the other filesystem objects.
Let's say client B modifies the file and updates the checksum. When client A opens the file, it will see that the data has changed, but how does it know that it also needs to update the xattr information?
Alternatively, let's say that client A reads the file and checksum data after client B has updated the file, but before it updates the checksum. What will cause client A to stop caching the stale checksum once client B has updated it?

Trond