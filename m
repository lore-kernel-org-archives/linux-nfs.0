Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:58404 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752143Ab1K2L63 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 29 Nov 2011 06:58:29 -0500
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Subject: RE: [PATCH 1/1] fix d_revalidate oopsen on NFS exports
Date: Tue, 29 Nov 2011 03:58:07 -0800
Message-ID: <2E1EB2CF9ED1CB4AA966F0EB76EAB4430C3CBC20@SACMVEXC2-PRD.hq.netapp.com>
In-Reply-To: <20111129082501.GA569@onthe.net.au>
References: <1321861008-20611-1-git-send-email-chris@onthe.net.au> <20111129082501.GA569@onthe.net.au>
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: "Chris Dunlop" <chris@onthe.net.au>, <linux-fsdevel@vger.kernel.org>,
        <linux-kernel@vger.kernel.org>,
        "Eric Van Hensbergen" <ericvh@gmail.com>,
        "Ron Minnich" <rminnich@sandia.gov>,
        "Latchesar Ionkov" <lucho@ionkov.net>,
        "David Howells" <dhowells@redhat.com>,
        "Jan Harkes" <jaharkes@cs.cmu.edu>,
        "maintainer:CODA FILE SYSTEM" <coda@cs.cmu.edu>,
        "Dave Kleikamp" <shaggy@kernel.org>,
        "Petr Vandrovec" <petr@vandrovec.name>,
        "Greg Kroah-Hartman" <gregkh@suse.de>,
        "Al Viro" <viro@zeniv.linux.org.uk>,
        <v9fs-developer@lists.sourceforge.net>,
        <linux-afs@lists.infradead.org>, <codalist@TELEMANN.coda.cs.cmu.edu>,
        <jfs-discussion@lists.sourceforge.net>, <linux-nfs@vger.kernel.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

> -----Original Message-----
> From: Chris Dunlop [mailto:chris@onthe.net.au]
> Sent: Tuesday, November 29, 2011 3:25 AM
> To: linux-fsdevel@vger.kernel.org; linux-kernel@vger.kernel.org; Eric
Van
> Hensbergen; Ron Minnich; Latchesar Ionkov; David Howells; Jan Harkes;
> maintainer:CODA FILE SYSTEM; Dave Kleikamp; Petr Vandrovec; Myklebust,
> Trond; Greg Kroah-Hartman; Al Viro;
v9fs-developer@lists.sourceforge.net;
> linux-afs@lists.infradead.org; codalist@TELEMANN.coda.cs.cmu.edu; jfs-
> discussion@lists.sourceforge.net; linux-nfs@vger.kernel.org
> Subject: Re: [PATCH 1/1] fix d_revalidate oopsen on NFS exports
> 
> Hi,
> 
> I haven't seen any response to this patch which fixes an Oops in
> d_revalidate. I hit this using NFS, but various other file systems
look to be
> likewise vulnerable, hence the broadness of the patch. The sequence
leading
> to the Oops is:
> 
> lookup_one_len() [fs/namei.c]
>    calls __lookup_hash() [fs/namei.c] with nd == NULL,
>       which can then call the file system specific d_revalidate(),
passing in nd ==
> NULL
>          which will then Oops if nd is used without checking

That's because you are "fixing" the wrong bug and if you'd checked the
list archives, you'd know that this has already been discussed several
times...

By allowing stacked filesystems to pass nd==NULL (the VFS doesn't do
this), you're circumventing  the lookup intent mechanisms and will hit
all sorts of problems further down the road. If you want to fix the
problem, then please fix the broken stacking filesystems to stop using
lookup_one_len...

Trond
