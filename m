Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:48400 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932461AbdERP2X (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 18 May 2017 11:28:23 -0400
Date: Thu, 18 May 2017 11:28:22 -0400
From: "bfields@fieldses.org" <bfields@fieldses.org>
To: Trond Myklebust <trondmy@primarydata.com>
Cc: "bfields@redhat.com" <bfields@redhat.com>,
        "stefanha@redhat.com" <stefanha@redhat.com>,
        "SteveD@redhat.com" <SteveD@redhat.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "chuck.lever@oracle.com" <chuck.lever@oracle.com>
Subject: Re: EXCHANGE_ID with same network address but different server owner
Message-ID: <20170518152822.GA9725@fieldses.org>
References: <1494601295.10434.1.camel@primarydata.com>
 <021509A5-FA89-4289-B190-26DC317A09F6@oracle.com>
 <20170515144306.GB16013@stefanha-x1.localdomain>
 <20170515160248.GD9697@parsley.fieldses.org>
 <20170516131142.GA12711@fieldses.org>
 <20170518133441.GC4155@stefanha-x1.localdomain>
 <A720C1BD-D218-43A2-B6FD-C72B1E58D98C@oracle.com>
 <1495119887.11859.1.camel@primarydata.com>
 <20170518150850.GB16256@parsley.fieldses.org>
 <1495120629.13396.1.camel@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1495120629.13396.1.camel@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, May 18, 2017 at 03:17:11PM +0000, Trond Myklebust wrote:
> For the case that Stefan is discussing (kvm) it would literally be a
> single process that is being migrated. For lxc and docker/kubernetes-
> style containers, it would be a collection of processes.
> 
> The mountpoints used by these containers are often owned by the host;
> they are typically set up before starting the containerised processes.
> Furthermore, there is typically no "start container" system call that
> we can use to identify which set of processes (or cgroups) are
> containerised, and should share a clientid.

Is that such a hard problem?

In any case, from the protocol point of view these all sound like client
implementation details.

The only problem I see with multiple client ID's is that you'd like to
keep their delegations from conflicting with each other so they can
share cache.

But, maybe I'm missing something else.

--b.
