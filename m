Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:56522 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1162691AbeBOUGE (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 15 Feb 2018 15:06:04 -0500
Date: Thu, 15 Feb 2018 15:06:04 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Olga Kornievskaia <aglo@umich.edu>
Cc: Olga Kornievskaia <kolga@netapp.com>,
        "J. Bruce Fields" <bfields@redhat.com>,
        linux-nfs <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH v6 05/10] NFSD first draft of async copy
Message-ID: <20180215200604.GA13228@fieldses.org>
References: <20171024174752.74910-1-kolga@netapp.com>
 <20171024174752.74910-6-kolga@netapp.com>
 <20180125220440.GA21492@fieldses.org>
 <CAN-5tyHoYk+tybHBaMXNE2vgtb8nfAn+3h5yBk8hd5f5UCUmpQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <CAN-5tyHoYk+tybHBaMXNE2vgtb8nfAn+3h5yBk8hd5f5UCUmpQ@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Feb 15, 2018 at 02:59:14PM -0500, Olga Kornievskaia wrote:
> On Thu, Jan 25, 2018 at 5:04 PM, J. Bruce Fields <bfields@fieldses.org> wrote:
> > Nit: this could use a better subject line.
> >
> > On Tue, Oct 24, 2017 at 01:47:47PM -0400, Olga Kornievskaia wrote:
> > ...
> >> +     if (!copy->cp_synchronous) {
> >> +             status = nfsd4_init_copy_res(copy, 0);
> >> +             async_copy = kzalloc(sizeof(struct nfsd4_copy), GFP_KERNEL);
> >> +             if (!async_copy) {
> >> +                     status = nfserrno(-ENOMEM);
> >> +                     goto out;
> >> +             }
> >> +             dup_copy_fields(copy, async_copy);
> >> +             memcpy(&copy->cp_res.cb_stateid, &copy->cp_dst_stateid,
> >> +                     sizeof(copy->cp_dst_stateid));
> >> +             spin_lock(&async_copy->cp_clp->async_lock);
> >> +             list_add(&async_copy->copies,
> >> +                             &async_copy->cp_clp->async_copies);
> >> +             spin_unlock(&async_copy->cp_clp->async_lock);
> >
> > At this point other threads could in theory look up this async_copy, but
> > its copy_task field is not yet initialized.  I don't *think* that's a
> > problem for nfsd4_shutdown_copy, because I don't think the server could
> > be processing rpc's for this client any more at that point.  But I think
> > a malicious client might be able to trigger a NULL dereference in
> > nfsd4_offload_cancel.
> >
> > Is there any reason not to assign copy_task before adding it to this
> > list?
> 
> Now that I'm making changes I don't believe this is an issue. A client
> can't send nfsd4_offload_cancel() because it needs a copy stateid to
> send it with. And at this point the copy has not been replied to.

Right, but a malicious client might guess that copy stateid before it
gets the reply.

We want to make sure we're safe from crashing even on input that is very
unlikely.

--b.
