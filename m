From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: nfs + Reiser4
Date: Wed, 07 Apr 2010 17:09:27 -0400
Message-ID: <1270674567.3177.2.camel@localhost.localdomain>
References: <op.vaq49joctxpshh@localhost.localdomain>
	 <20100407173438.GA25614@fieldses.org> <4BBCD271.5040100@oracle.com>
	 <20100407185157.GF26072@fieldses.org> <4BBCD618.50301@oracle.com>
	 <20100407192025.GH26072@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Chuck Lever <chuck.lever@oracle.com>, linux-nfs@vger.kernel.org,
	gg-B3jsHfKwJfLR7s880joybQ@public.gmane.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out2.uio.no ([129.240.10.58]:48164 "EHLO mail-out2.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750810Ab0DGVJf (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 7 Apr 2010 17:09:35 -0400
In-Reply-To: <20100407192025.GH26072@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 2010-04-07 at 15:20 -0400, J. Bruce Fields wrote: 
> On Wed, Apr 07, 2010 at 02:59:36PM -0400, Chuck Lever wrote:
> > On 04/07/2010 02:51 PM, J. Bruce Fields wrote:
> >> On Wed, Apr 07, 2010 at 02:44:01PM -0400, Chuck Lever wrote:
> >>> On 04/07/2010 01:34 PM, J. Bruce Fields wrote:
> >>>> On Tue, Apr 06, 2010 at 07:52:21PM +0200, gg-B3jsHfKwJfLR7s880joybQ@public.gmane.org wrote:
> >>>>> I am having serious headaches using nfs between a reiser4 server and arm
> >>>>> client.
> >>>>> Both on 2.6.29 vintage kernels.
> >>>>>
> >>>>> Files are constantly getting out of sync.
> >>>>>
> >>>>> Example :
> >>>>>
> >>>>> boot ARM via nfs
> >>>>> edit lighttpd.conf on ARM
> >>>>> check edit is visible on server. OK
> >>>>>
> >>>>> reboot ARM
> >>>>> check file : reverted to an earlier state.
> >>>>> check server: edited version still showing.
> >>>>
> >>>> So, on a freshly booted NFS client, you're opening and reading a file
> >>>> and seeing file data that isn't even on the NFS server any more?
> >>>>
> >>>> That's beyond bizarre.  Do you have a reliable way to reproduce the
> >>>> problem?
> >>>
> >>> Could be XID replay.
> >>
> >> I'm not following you.  You're thinking of a read request after the
> >> reboot that unluckily reuses an old XID and gets stale data from the
> >> servers reply cache?  Or something else?
> >
> > Nothing unlucky about it.  Just after a boot, if the client  
> > implementation isn't careful about choosing an initial XID, (eg it  
> > always starts with a psuedorandom number but uses the same seed every  
> > time), it will hit the server's replay cache.
> 
> Hm, OK.
> 
> > This can be quite reproducible for NFSROOT and a quiescent server.
> 
> The Linux server doesn't cache READ results as far as I can tell.
> 
> --b.

Is he perhaps using the Debian unfsd or some other user space nfs
server?

Cheers
  Trond

