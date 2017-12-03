Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from ozlabs.org ([103.22.144.67]:49895 "EHLO ozlabs.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751626AbdLCVig (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Sun, 3 Dec 2017 16:38:36 -0500
Date: Mon, 4 Dec 2017 08:38:34 +1100
From: Stephen Rothwell <sfr@canb.auug.org.au>
To: Anna Schumaker <Anna.Schumaker@Netapp.com>
Cc: Trond Myklebust <trond.myklebust@fys.uio.no>,
        NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PULL REQUEST] nfsd changes for 4.15
Message-ID: <20171204083834.5a676fa9@canb.auug.org.au>
In-Reply-To: <10221c9a-4b34-3a83-0fd7-0a4f11699c15@Netapp.com>
References: <20171118184020.GA22603@fieldses.org>
        <CA+55aFwPHpD0Ehq8_VawfLCTXgMkbWE3fvdNc__ELmirh1rPVQ@mail.gmail.com>
        <20171119232037.6a719dec@canb.auug.org.au>
        <4fba12c5-b204-9492-cfa8-283af5e87dde@Netapp.com>
        <20171201074717.3f6af4ce@canb.auug.org.au>
        <10221c9a-4b34-3a83-0fd7-0a4f11699c15@Netapp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Anna,

On Thu, 30 Nov 2017 15:53:22 -0500 Anna Schumaker <Anna.Schumaker@Netapp.com> wrote:
>
> On 11/30/2017 03:47 PM, Stephen Rothwell wrote:
> > 
> > On Thu, 30 Nov 2017 15:24:59 -0500 Anna Schumaker <Anna.Schumaker@Netapp.com> wrote:  
> >>
> >> What are the steps for adding my tree to next?  
> > 
> > I just need a (git) url for the tree and branch (or tag) that you will
> > update when stuff is ready to be in linux-next.  I will fetch that
> > branch every morning, so once set up I automatically get updates.  
> 
> Let's go with the "linux-next" branch at git://git.linux-nfs.org/projects/anna/linux-nfs.git
> 
> > 
> > Also, a list of contacts that I can report problems (conflicts, build
> > failures/warnings etc) to (probably yourself, but maybe a mailing list
> > and any others who can fix problems.
> >   
> 
> Let's go with me (anna.schumaker@netapp.com), Trond (trondmy@primarydata.com), and linux-nfs@vger.kernel.org.

Added from today.

Thanks for adding your subsystem tree as a participant of linux-next.  As
you may know, this is not a judgement of your code.  The purpose of
linux-next is for integration testing and to lower the impact of
conflicts between subsystems in the next merge window. 

You will need to ensure that the patches/commits in your tree/series have
been:
     * submitted under GPL v2 (or later) and include the Contributor's
        Signed-off-by,
     * posted to the relevant mailing list,
     * reviewed by you (or another maintainer of your subsystem tree),
     * successfully unit tested, and 
     * destined for the current or next Linux merge window.

Basically, this should be just what you would send to Linus (or ask him
to fetch).  It is allowed to be rebased if you deem it necessary.

-- 
Cheers,
Stephen Rothwell 
sfr@canb.auug.org.au
