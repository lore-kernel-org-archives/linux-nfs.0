Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:54916 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1030661AbaDJNMl (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 10 Apr 2014 09:12:41 -0400
Date: Thu, 10 Apr 2014 09:12:40 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: "Mkrtchyan, Tigran" <tigran.mkrtchyan@desy.de>
Cc: linux-nfs@vger.kernel.org
Subject: Re: nfsd 3.14 status
Message-ID: <20140410131240.GA32568@fieldses.org>
References: <20140407165820.GE21195@fieldses.org>
 <1907491201.2131087.1396895725338.JavaMail.zimbra@desy.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1907491201.2131087.1396895725338.JavaMail.zimbra@desy.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Apr 07, 2014 at 08:35:25PM +0200, Mkrtchyan, Tigran wrote:
> 
> 3.15, I believe.

Curses, my plot to go back in time and fix 3.14 has been foiled....

(I'm no good at version numbers.  Maybe we should start using code
names.)

--b.

> 
> Tigran.
> 
> ----- Original Message -----
> > From: "J. Bruce Fields" <bfields@fieldses.org>
> > To: linux-nfs@vger.kernel.org
> > Sent: Monday, April 7, 2014 6:58:20 PM
> > Subject: nfsd 3.14 status
> > 
> > The below is what I'm intending to merge for 3.14.  I think I've caught
> > up with my mailbox; please let me know if I've missed anything from you.
> > 
> > Also, I'll be mostly offline for three weeks starting Friday--if you
> > want anything from me before early May, ask now.
> > 
> > I decided to let the rest of the xdr patches sit a little longer.  I'll
> > plan to get that queued up quickly for 3.16 once I'm back.
> > 
> > --b.
> > 
> > J. Bruce Fields (18):
> >       nfsd4: buffer-length check for SUPPATTR_EXCLCREAT
> >       nfsd4: session needs room for following op to error out
> >       nfsd4: make set of large acl return efbig, not resource
> >       nfsd4: leave reply buffer space for failed setattr
> >       nfsd4: fix test_stateid error reply encoding
> >       nfsd: notify_change needs elevated write count
> >       nfsd: typo in nfsd_rename comment
> >       rpc: Allow xdr_buf_subsegment to operate in-place
> >       nfsd4: update comments with obsolete function name
> >       nfsd4: nfsd4_replay_cache_entry should be static
> >       nfsd4: minor nfsd4_replay_cache_entry cleanup
> >       nfsd4: use more generous NFS4_ACL_MAX
> >       nfsd4: remove redundant check from nfsd4_check_resp_size
> >       nfsd4: fix setclientid encode size
> >       nfsd4: fix nfs4err_resource in 4.1 case
> >       nfsd: revert v2 half of "nfsd: don't return high mode bits"
> >       nfsd4: don't create unnecessary mask acl
> >       nfsd4: fix delegation cleanup on error
> > 
> > Jeff Layton (5):
> >       svcrdma: fix printk when memory allocation fails
> >       svcrpc: explicitly reject compounds that are not padded out to 4-byte
> >       multiple
> >       lockd: ensure we tear down any live sockets when socket creation fails
> >       during lockd_up
> >       xprtrdma: add separate Kconfig options for NFSoRDMA client and server
> >       support
> >       svcrdma: fix offset calculation for non-page aligned sge entries
> > 
> > Kinglong Mee (9):
> >       NFSD: Traverse unconfirmed client through hash-table
> >       NFSD: simplify saved/current fh uses in nfsd4_proc_compound
> >       SUNRPC: fix memory leak of peer addresses in XPRT
> >       NFSD: Using free_conn free connection
> >       NFSD: Clear wcc data between compound ops
> >       NFSD: Free backchannel xprt in bc_destroy
> >       SUNRPC: New helper for creating client with rpc_xprt
> >       NFSD/SUNRPC: Check rpc_xprt out of xs_setup_bc_tcp
> >       SUNRPC: Clear xpt_bc_xprt if xs_setup_bc_tcp failed
> > 
> > Rashika Kheria (1):
> >       net: Mark functions as static in net/sunrpc/svc_xprt.c
> > 
> > Stanislav Kinsbursky (1):
> >       nfsd: check passed socket's net matches NFSd superblock's one
> > 
> > Tom Tucker (1):
> >       Fix regression in NFSRDMA server
> > 
> > Trond Myklebust (1):
> >       nfsd: Don't return NFS4ERR_STALE_STATEID for NFSv4.1+
> > 
> > Yan, Zheng (1):
> >       nfsd4: fix memory leak in nfsd4_encode_fattr()
> > 
> > --
> > To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> > the body of a message to majordomo@vger.kernel.org
> > More majordomo info at  http://vger.kernel.org/majordomo-info.html
> > 
