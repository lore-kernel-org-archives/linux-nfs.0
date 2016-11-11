Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:42530 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S935747AbcKKWE0 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 11 Nov 2016 17:04:26 -0500
Date: Fri, 11 Nov 2016 17:04:25 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Omar Walid Llorente <omar@dit.upm.es>
Cc: Soumya Koduri <skoduri@redhat.com>,
        Jeff Layton <jlayton@poochiereds.net>, linux-nfs@vger.kernel.org,
        =?utf-8?Q?administraci=C3=B3n_del_centro_de_c=C3=A1lculo?= del
         dit <cdc@dit.upm.es>,
        Miklos Szeredi <mszeredi@redhat.com>
Subject: Re: possible bug in nfs-kernel-server
Message-ID: <20161111220425.GA30914@fieldses.org>
References: <56743FB6.80903@redhat.com>
 <20151218200840.GA28692@fieldses.org>
 <5677BCD4.4060009@redhat.com>
 <20151221164752.GA7869@fieldses.org>
 <56783DCC.1060201@redhat.com>
 <20151221201403.GB7869@fieldses.org>
 <2443f0d3-6937-ae92-d4d5-6e1f00a19e81@dit.upm.es>
 <20161108201611.GB26589@fieldses.org>
 <37f8eaf5-128c-ecd5-ae65-3b340c990171@dit.upm.es>
 <20161111190332.GA28132@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20161111190332.GA28132@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Sorry, resending with Miklos's address fixed....

On Fri, Nov 11, 2016 at 06:57:45PM +0100, Omar Walid Llorente wrote:
> Hi Bruce, thanks for your answer, that is greatly appreciated.
> 
> This side of the problem feels a little bit lonely and maybe we can
> manage to get to know what is happening if you have some time.
>
> We have been doing tests and we have found a way to replicate the
> problem in a virtual environment without ZFS, only with glusterfs
> and nfs-kernel-server, where we can give you root password or you
> can replicate it at home.
> 
> It is closely related to non-root users (with root credentials the
> problem does not happen).
> 
> If you think this is good news and feel like checking, tell me and
> next week we will prepare it and I'll forward you the data for both
> kind of tests.

So if I'm reading right, the setup is

	nfs client---NFSv3--->knfsd---FUSE-->gluster

I hate to just pass the buck, but my bet is on the issue being either on
the gluster side, or on limitations of the fuse protocol itself.

Cc'ing Miklos as I believe he did the original fuse nfsd export
implementation.  Miklos, does fuse has a way for file owners to override
permissions?  We need this sometimes because for example, an application
may hold a write open on a read-only file, but the server doesn't itself
already have an open (which can happen for lots of reasons).

--b.
