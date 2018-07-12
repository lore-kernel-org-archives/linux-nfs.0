Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:56870 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726463AbeGLT1l (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 12 Jul 2018 15:27:41 -0400
Date: Thu, 12 Jul 2018 15:16:45 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: Olga Kornievskaia <aglo@umich.edu>
Cc: Olga Kornievskaia <kolga@netapp.com>,
        linux-nfs <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH v9 0/9] NFSD support for async COPY
Message-ID: <20180712191645.GC10033@parsley.fieldses.org>
References: <20180709192638.44799-1-kolga@netapp.com>
 <20180712185611.GB10033@parsley.fieldses.org>
 <CAN-5tyFeuDxTFTpM_-ZJp27sc87A1TU0ToDJxb2Kw4jTGFA+-A@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <CAN-5tyFeuDxTFTpM_-ZJp27sc87A1TU0ToDJxb2Kw4jTGFA+-A@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Jul 12, 2018 at 03:11:14PM -0400, Olga Kornievskaia wrote:
> On Thu, Jul 12, 2018 at 2:56 PM, J. Bruce Fields <bfields@redhat.com> wrote:
> > I think we got confused in the previous discussion of this.
> >
> > The reason I wanted the module parameter was that server-to-server copy
> > would allow a rogue client to direct the server to copy from any server
> > it wishes, and I thought this was potentially risky, and want people to
> > opt into it rather than having it the default.
> >
> > That doesn't apply to asynchronous copy on its own.
> >
> > So this module parameter could wait for the next patchset.
> 
> To clarify, you want "inter" copy offload to be configuration, but it
> already was (when it was first posted) under config option. Now
> instead of a compile option you prefer this to be a module parameter?

That's right.

I'd like distributions to be able to include server-to-server-copy
capable kernels, but I don't want it on by default because I think
responsible administrators will want to do some firewalling first.

> Do you have any other comments? I'd rather not re-post another version
> if you have more comments.

In that case I'd recommend holding off till next week.

--b.
