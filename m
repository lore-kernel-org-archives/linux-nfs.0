Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:42667 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759547Ab3EORmr (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 15 May 2013 13:42:47 -0400
Date: Wed, 15 May 2013 13:42:45 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: James Vanns <james.vanns@framestore.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: Where in the server code is fsinfo rtpref calculated?
Message-ID: <20130515174245.GN16811@fieldses.org>
References: <20130515144749.GI16811@fieldses.org>
 <1706515764.20038371.1368635535864.JavaMail.root@framestore.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1706515764.20038371.1368635535864.JavaMail.root@framestore.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, May 15, 2013 at 05:32:15PM +0100, James Vanns wrote:
> <snip>
> 
> > > I've just returned from nfsd3_proc_fsinfo() and found what I would
> > > consider an odd decision - perhaps nothing better was suggested at
> > > the time. It seems to me that in response to an FSINFO call the
> > > reply stuffs the max_block_size value in  both the maximum *and*
> > > preferred block sizes for both read and write. A 1MB block size
> > > for a preferred default is a little high! If a disk is reading at
> > > 33MB/s and we have just a single server running 64 knfsd and each
> > > READ call is requesting 1MB of data then all of a sudden we have
> > > an aggregate read speed of ~512k/s
> > 
> > I lost you here.
> 
> OK, so what we're seeing is the large majority of our nr. ~700 clients
> (all Linux 2.6.32 based NFS clients) issuing READ requests of 1MB in
> size.

Knowing nothing about your situation, I'd assume the clients are doing
that because they actually want that 1MB of data.

Would you prefer they each send 1024 1k READs?  I don't understand why
it's the read size you're focused on here.

--b.

> 
> After the initial MOUNT request has been granted an FSINFO call is
> made. The contents of the REPLY from the server (another Linux 2.6.32
> server) include rtmax, rtpref, wtmax and wtpref all of which are set
> to 1MB. This 1MB appears to come from that code/explanation I
> described earlier  - all values are basically getting set to whatever
> comes out of nfsd_get_default_max_blksize().


