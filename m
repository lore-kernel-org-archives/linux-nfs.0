From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: Memory corruption in nfs3_xdr_setaclargs()
Date: Thu, 05 Mar 2009 13:53:08 -0500
Message-ID: <1236279188.13361.30.camel@heimdal.trondhjem.org>
References: <49760685.4030409@redhat.com>
	 <1232475301.7055.14.camel@heimdal.trondhjem.org>
	 <alpine.LFD.1.10.0903050829420.3949@w-kevinr.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-nfs@vger.kernel.org
To: "Kevin W. Rudd" <solgato@us.ibm.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out2.uio.no ([129.240.10.58]:53198 "EHLO mail-out2.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750786AbZCESxO (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 5 Mar 2009 13:53:14 -0500
In-Reply-To: <alpine.LFD.1.10.0903050829420.3949-mupu0Q0mUPfkOmf+N4b0O9FgqiXiwxn+0E9HWUfgJXw@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 2009-03-05 at 08:33 -0800, Kevin W. Rudd wrote:
> On Tue, 20 Jan 2009, Trond Myklebust wrote:
> 
> > Date: Tue, 20 Jan 2009 13:15:01 -0500
> > From: Trond Myklebust <trond.myklebust@fys.uio.no>
> > To: Sachin S. Prabhu <sprabhu@redhat.com>
> > Cc: linux-nfs@vger.kernel.org
> > Subject: Re: Memory corruption in nfs3_xdr_setaclargs()
> > 
> > On Tue, 2009-01-20 at 17:14 +0000, Sachin S. Prabhu wrote:
> >> A mistake in calculating the space left in the header in nfs3_xdr_setaclargs()
> >> can cause memory corruption when setting a large number of acls.
> >>
> >> Reproducer:
> >>
> >> On Server:
> >> 1) Create directory /test and set mode 777.
> >> mkdir /test; chmod 777 /test
> >> 2) Add 200 users and set default acl for user on /test
> >> for i in {1..200}; do echo $i; useradd user$i; setfacl -m d:u:user$i:rwx
> >> /test;done
> >> 3) Add export /test  in /etc/exports
> >> /test *(rw)
> >>
> >> On client
> >> 1) Mount server:/test
> >> mount server:/test /mnt
> >> 2) Create large number of directories on the the share.
> >> cd/mnt; for i in {1..1000}; do mkdir $i; done
> >> At this point, the client should crash.
> >>
> >> A change in call_header changes the value req->rq_snd_buf->head[0]->iov_len to
> >> reflect the exact size of the header.
> >> [PATCH] RPC: Ensure XDR iovec length is initialized correctly in call_header
> >> 334ccfd545bba9690515f2c5c167d5adb161989b
> >>
> >> The iov_len is set to the size of the header in  call_header().
> >> req->rq_slen = xdr_adjust_iovec(&req->rq_svec[0], p);
> >>
> >> nfs3_xdr_setaclargs() depends on the older behavior and uses this value when
> >> calculating the number of ACLs it can fit into the header.
> >>
> >>         /* put as much of the acls into head as possible. */
> >>         len_in_head = min_t(unsigned int, buf->head->iov_len - base, len);
> >>         len -= len_in_head;
> >>         req->rq_slen = xdr_adjust_iovec(req->rq_svec, p + (len_in_head >> 2));
> >>
> >> Since at this stage, iov_len < base, len_in_head will always be set to len. For
> >> a large number of ACLs, this will end up over-writing other parts of memory on
> >> the nfs client.
> >>
> >> The following patch which set len_in_head to 0 was tested with the reproducer
> >> and was found to fix the problem.
> >>
> >
> > Looks alright. Could you please add a s-o-b line?
> >
> > Cheers
> >  Trond
> >
> >> --- fs/nfs/nfs3xdr.c.orig	2009-01-20 15:18:12.000000000 +0000
> >> +++ fs/nfs/nfs3xdr.c	2009-01-20 15:33:45.000000000 +0000
> >> @@ -691,7 +691,10 @@ nfs3_xdr_setaclargs(struct rpc_rqst *req
> >>  	*p++ = htonl(args->mask);
> >>  	base = (char *)p - (char *)buf->head->iov_base;
> >>  	/* put as much of the acls into head as possible. */
> >> -	len_in_head = min_t(unsigned int, buf->head->iov_len - base, len);
> >> +	if ( buf->head->iov_len > base )
> >> +		len_in_head = min_t(unsigned int, buf->head->iov_len - base, len);
> >> +	else
> >> +		len_in_head = 0;
> >>  	len -= len_in_head;
> >>  	req->rq_slen = xdr_adjust_iovec(req->rq_svec, p + (len_in_head >> 2));
> >>
> >> Thanks to Kevin Rudd who did the major legwork here to figure the problem and
> >> create the patch.
> >>
> >> Sachin Prabhu
> >>
> 
> Trond,
> 
> Do you know what happened to this patch?  Given the nasty corruption
> aspect to the bug, we were expecting to see a fix for this merged into
> the mainline by now.

Going over that particular procedure reveals a number of bugs that all
should be fixed.

Trying to estimate how many bytes are free in the header is _WRONG_.
That memory is allocated with certain assumptions, which are set in the
definition of ACL3_setaclargs_sz. In this case, the assumptions appear
to be that we will fit a maximum of 5 ACEs in the header.
IOW: the real fix for your corruption problem is simply to set
len_in_head to 2*(2+5*3). Currently, the patch supplied by Sachin will
always set it to zero.

Secondly, doing page allocation in the XDR routine is _WRONG_. For one
thing, look at the major memory leak which happens if the client needs
to resend the request (which can happen every now and again due to a
dropped tcp connection, or all the time due to UDP retransmits).
Those pages should have been allocated in nfs3_proc_getacl(), and indeed
that is where the wretched things are freed.

Trond

