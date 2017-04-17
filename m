Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:33410 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754704AbdDQNgF (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 17 Apr 2017 09:36:05 -0400
Date: Mon, 17 Apr 2017 09:36:04 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Olga Kornievskaia <aglo@umich.edu>
Cc: "Mora, Jorge" <Jorge.Mora@netapp.com>,
        "nfsv4@ietf.org" <nfsv4@ietf.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [nfsv4] Inter server-side copy performance
Message-ID: <20170417133604.GA22694@fieldses.org>
References: <DFE33002-FE1C-4E83-B6E3-50BFD304C7F6@netapp.com>
 <20170413174515.GA5140@fieldses.org>
 <59BDF7CA-78BB-42FC-8BC4-95101F5E1EC7@netapp.com>
 <CAN-5tyHOdU9BJnJft+X06=6X7_s8MS_hDmg9t=fJQ=QtvJQD=w@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <CAN-5tyHOdU9BJnJft+X06=6X7_s8MS_hDmg9t=fJQ=QtvJQD=w@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Apr 14, 2017 at 05:22:13PM -0400, Olga Kornievskaia wrote:
> On Fri, Apr 14, 2017 at 4:09 PM, Mora, Jorge <Jorge.Mora@netapp.com> wrote:
> > On 4/13/17, 11:45 AM, "J. Bruce Fields" <bfields@fieldses.org> wrote:
> >> Are you timing just the copy_file_range() call, or do you include a
> >> following sync?
> >
> > I am timing right before calling copy_file_range() up to doing an fsync() and close() of the destination file.
> > For the traditional copy is the same, I am timing right before the first read on the source file up to the
> > fsync() and close() of the destination file.
> 
> Why should do we need a sync after copy_file_range(). kernel
> copy_file_range() will send the commits for any unstable copies it
> received.

Why does it do that?  As far as I can tell it's not required by
documentation for copy_file_range() or COPY.  COPY has a write verifier
and a stable_how argument in the reply.  Skipping the commits would
allow better performance in case a copy requires multiple COPY calls.

But, in any case, if copy_file_range() already committed then it
probably doesn't make a significant difference to the timing whether you
include a following sync and/or close.

--b.
