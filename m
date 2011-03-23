Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cantor.suse.de ([195.135.220.2]:55070 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750898Ab1CWVz3 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 23 Mar 2011 17:55:29 -0400
Date: Thu, 24 Mar 2011 08:55:17 +1100
From: NeilBrown <neilb@suse.de>
To: <Daniel.Muntz@emc.com>
Cc: <Trond.Myklebust@netapp.com>, <peter.staubach@emc.com>,
        <bfields@fieldses.org>, <bjschuma@netapp.com>,
        <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 3/3] NFS: Detect loops in a readdir due to bad cookies
Message-ID: <20110324085517.77584ced@notabene.brown>
In-Reply-To: <DE966DA98A4ABE438D726BDF1699CF6104B53F7F0C@MX05A.corp.emc.com>
References: <4D8A3060.807@netapp.com>
	<20110323182524.GB25284@fieldses.org>
	<1300905243.11677.53.camel@lade.trondhjem.org>
	<5E6794FC7B8FCA41A704019BE3C70E8B0693F05F@MX31A.corp.emc.com>
	<1300906115.11677.58.camel@lade.trondhjem.org>
	<20110324082754.76f199a6@notabene.brown>
	<DE966DA98A4ABE438D726BDF1699CF6104B53F7F0C@MX05A.corp.emc.com>
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, 23 Mar 2011 17:36:38 -0400 <Daniel.Muntz@emc.com> wrote:

>  
> 
> > -----Original Message-----
> > From: linux-nfs-owner@vger.kernel.org 
> > [mailto:linux-nfs-owner@vger.kernel.org] On Behalf Of NeilBrown
> > Sent: Wednesday, March 23, 2011 2:28 PM
> > To: Trond Myklebust
> > Cc: Staubach, Peter; bfields@fieldses.org; 
> > bjschuma@netapp.com; linux-nfs@vger.kernel.org
> > Subject: Re: [PATCH 3/3] NFS: Detect loops in a readdir due 
> > to bad cookies
> > 
> > On Wed, 23 Mar 2011 14:48:35 -0400 Trond Myklebust
> > <Trond.Myklebust@netapp.com> wrote:
> > 
> > > On Wed, 2011-03-23 at 14:42 -0400, peter.staubach@emc.com wrote:
> > > > Although I think that it is a good thing to protect the 
> > client against broken servers, it does seem like the right 
> > solution is to get the server fixed...
> > > 
> > > Don't get me wrong: I fully agree with that!
> > 
> > Ack.
> > 
> > As I understand it, ext4 (and ext3) use the hash of the 
> > basename as the
> > cookie.  This hash has a per-directory random seed which is 
> > hidden so it is
> > not possible to deliberately create files with the same hash, 
> > but thanks to
> > the birthday paradox it isn't too hard to get collisions in a 
> > suitably large
> > directory.
> > 
> > For 'readdir' ext4 keeps extra state in the 'struct file' so 
> > that it knows
> > where it was up to in a list of names with the same hash and 
> > so won't return
> > duplicates.  
> 
> Would it be possible to use this "extra state" to uniqify the cookie used by NFS?  Having no idea what this extra state is, I'm just wildly speculating.
> 

No, it is all hidden inside filp->private_data.  It is just a linked-list of
file names  (see 'extra_fname' in fs/ext4/dir.c).
The best you could do would be to shift the cookie up a few bits (ext4
cookies are 62 bit already!) and add a sequence counter.
But I don't think that approach will really give more reliability than just
trying to hide cookie-runs by making sure they don't cross from one packet to
the next.

NeilBrown
