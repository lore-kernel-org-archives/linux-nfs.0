Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from ozlabs.org ([103.22.144.67]:39871 "EHLO ozlabs.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750807AbdKSMUl (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Sun, 19 Nov 2017 07:20:41 -0500
Date: Sun, 19 Nov 2017 23:20:37 +1100
From: Stephen Rothwell <sfr@canb.auug.org.au>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
        Chuck Lever <chuck.lever@oracle.com>,
        Anna Schumaker <Anna.Schumaker@netapp.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Subject: Re: [PULL REQUEST] nfsd changes for 4.15
Message-ID: <20171119232037.6a719dec@canb.auug.org.au>
In-Reply-To: <CA+55aFwPHpD0Ehq8_VawfLCTXgMkbWE3fvdNc__ELmirh1rPVQ@mail.gmail.com>
References: <20171118184020.GA22603@fieldses.org>
        <CA+55aFwPHpD0Ehq8_VawfLCTXgMkbWE3fvdNc__ELmirh1rPVQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Linus,

On Sat, 18 Nov 2017 11:40:44 -0800 Linus Torvalds <torvalds@linux-foundation.org> wrote:
>
> On Sat, Nov 18, 2017 at 10:40 AM, J. Bruce Fields <bfields@fieldses.org> wrote:
> > Please pull nfsd changes for 4.15 from:  
> 
> Hmm. This had a tracepoint conflict with the nfs client pull.
> 
> The resolution seems obvious and I did it, but I'd like people to
> review the end result but particularly also their workflows, because I
> don't think that conflict was reported anywhere and doesn't seem to
> exist in next-20171115.
> 
> It certainly wasn't mentioned to me in either pull request.
> 
> Were the nfs client changes not in next?

They were not :-(
-- 
Cheers,
Stephen Rothwell
