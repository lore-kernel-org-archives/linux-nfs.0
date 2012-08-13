Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:56684 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751250Ab2HMOaR (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 13 Aug 2012 10:30:17 -0400
Date: Mon, 13 Aug 2012 10:30:16 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Rajesh Ghanekar <rajeshsg@gmail.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: reconnect_path fails with EACCES
Message-ID: <20120813143016.GA2497@fieldses.org>
References: <CAOn_VZbzhGMtYmOZJe-kGqhFLRsWpw6B3+uv+d4UAx9t1-Ew=A@mail.gmail.com>
 <20120809181233.GB9914@fieldses.org>
 <CAOn_VZaNU1_WT+XsvHabi=4fhMnyJg5eKp_p=e=1ruWfHC76DQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <CAOn_VZaNU1_WT+XsvHabi=4fhMnyJg5eKp_p=e=1ruWfHC76DQ@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Aug 13, 2012 at 07:24:56PM +0530, Rajesh Ghanekar wrote:
> Its no_subtree_check exported.
> 
> Underneath filesystem (->permission) doesn't support capabilities and
> hence EACCES is being returned. The filesystem is proprietary.
> I figured it out later that they don't support capabilities.

That sounds like a bug in their permission method.  We won't be able to
help with a proprietary filesystem here.

--b.

> 
> Thanks,
> Rajesh
> 
> 
> On Thu, Aug 9, 2012 at 11:42 PM, J. Bruce Fields <bfields@fieldses.org> wrote:
> > On Thu, Aug 09, 2012 at 02:55:28AM +0530, Rajesh Ghanekar wrote:
> >> Hi,
> >> I am facing problem with reconnect_path failing with EACCES when doing
> >> lookup_one_len. I have 2 users goind to same directory, one with uid=0
> >> and another with uid=xxx. Sometime for uid=0 request, nfsd is still is using
> >> uid=xxx (as it was used previously), as uid=xxx doesn't have any permissions
> >> on the directory.
> >>
> >> Should this probably do nfsd_setuser_and_check_port before
> >> the below code in nfsd_set_fh_dentry()? As it carries older
> >> fsuid and fsgid, can it create issues. This always happens
> >> with disconnected dentries.
> >>
> >>         if (exp->ex_flags & NFSEXP_NOSUBTREECHECK) {
> >>                 /* Elevate privileges so that the lack of 'r' or 'x'
> >>                  * permission on some parent directory will
> >>                  * not stop exportfs_decode_fh from being able
> >>                  * to reconnect a directory into the dentry cache.
> >>                  * The same problem can affect "SUBTREECHECK" exports,
> >>                  * but as nfsd_acceptable depends on correct
> >>                  * access control settings being in effect, we cannot
> >>                  * fix that case easily.
> >
> > Are you exporting with subtree_check or no_subtree_check?  (What does
> > "exportfs -v" say?)
> >
> > In the no_subtree_check case, the cap_raise_nfsd_set() is intended to
> > override file permissions, so the uid and gid shouldn't matter.
> >
> > --b.
