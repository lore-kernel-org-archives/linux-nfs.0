Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:3778 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933323Ab1CWUwM convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 23 Mar 2011 16:52:12 -0400
Subject: Re: [PATCH 08/12] NFSv4.1: add generic layer hooks for pnfs COMMIT
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Benny Halevy <bhalevy@panasas.com>
Cc: Fred Isaman <iisaman@netapp.com>, linux-nfs@vger.kernel.org
In-Reply-To: <4D8A5A68.7060302@panasas.com>
References: <1300886875-5016-1-git-send-email-iisaman@netapp.com>
	 <1300886875-5016-9-git-send-email-iisaman@netapp.com>
	 <4D8A4D16.1060702@panasas.com>
	 <AANLkTi=_9nmyg4j1LqC61QBAGD5q0y0ndBMgzNLN_0Py@mail.gmail.com>
	 <4D8A5A68.7060302@panasas.com>
Content-Type: text/plain; charset="UTF-8"
Date: Wed, 23 Mar 2011 16:52:09 -0400
Message-ID: <1300913529.11677.77.camel@lade.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, 2011-03-23 at 22:39 +0200, Benny Halevy wrote:
> On 2011-03-23 22:30, Fred Isaman wrote:
> > 2011/3/23 Benny Halevy <bhalevy@panasas.com>:
> >>> +}
> >>> +
> >>> +static inline struct list_head *
> >>> +pnfs_choose_commit_list(struct nfs_page *req, struct list_head *mds)
> >>> +{
> >>> +       struct list_head *rv;
> >>> +
> >>> +       if (test_and_clear_bit(PG_PNFS_COMMIT,&req->wb_flags)) {
> >>
> >> nit: space after comma
> >>
> >>> +               struct inode *inode =
> >>> req->wb_commit_lseg->pls_layout->plh_inode;
> >>> +
> >>> +               set_bit(NFS_INO_PNFS_COMMIT,&NFS_I(inode)->flags);
> >>
> >> nit: ditto
> >>
> >>> +               rv =
> >>> NFS_SERVER(inode)->pnfs_curr_ld->choose_commit_list(req);
> >>> +               /* matched by ref taken when PG_PNFS_COMMIT is set */
> >>> +               put_lseg(req->wb_commit_lseg);
> >>
> >> Since wb_commit_lseg and wb_list are in a union, how about
> >>                INIT_LIST_HEAD(&req->wb_list);
> > 
> > I actually had that there.  Trond pointed out it was unnecessary and
> > asked that it be removed.
> > 
> 
> Seems fragile to me. I hope Trond's around to fix it when it breaks ;-)

Why would it break? The point is that you are initialising the list
header and then immediately clobbering that initialisation by adding it
to a list.
It's like initialising 'foo' to the value 0 and then immediately
assigning the value 1. That's not defensive programming, just a waste of
CPU cycles (or compiler cycles if the compiler is smart).

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

