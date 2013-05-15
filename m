Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx4.framestore.com ([193.203.83.5]:59547 "EHLO
	mx4.framestore.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759168Ab3EOQgP (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 15 May 2013 12:36:15 -0400
Date: Wed, 15 May 2013 17:32:15 +0100 (BST)
From: James Vanns <james.vanns@framestore.com>
Reply-To: james.vanns@framestore.com
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-ID: <1706515764.20038371.1368635535864.JavaMail.root@framestore.com>
In-Reply-To: <20130515144749.GI16811@fieldses.org>
Subject: Re: Where in the server code is fsinfo rtpref calculated?
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

<snip>

> > I've just returned from nfsd3_proc_fsinfo() and found what I would
> > consider an odd decision - perhaps nothing better was suggested at
> > the time. It seems to me that in response to an FSINFO call the
> > reply
> > stuffs the max_block_size value in  both the maximum *and*
> > preferred
> > block sizes for both read and write. A 1MB block size for a
> > preferred
> > default is a little high! If a disk is reading at 33MB/s and we
> > have just
> > a single server running 64 knfsd and each READ call is requesting
> > 1MB of
> > data then all of a sudden we have an aggregate read speed of
> > ~512k/s
> 
> I lost you here.

OK, so what we're seeing is the large majority of our nr. ~700 clients
(all Linux 2.6.32 based NFS clients) issuing READ requests of 1MB in size.

After the initial MOUNT request has been granted an FSINFO call is made. The
contents of the REPLY from the server (another Linux 2.6.32 server) include
rtmax, rtpref, wtmax and wtpref all of which are set to 1MB. This 1MB appears
to come from that code/explanation I described earlier  - all values are basically
getting set to whatever comes out of nfsd_get_default_max_blksize().

> > that is without network latencies. And of course we will probably
> > have 100s of
> > requests queued behind each knfsd waiting for these 512k reads to
> > finish. All of a
> > sudden our user experience is rather poor :(
> 
> Note the preferred size is not a minimum--the client isn't forced to
> do
> 1MB reads if it really only wants 1 page, for example, if that's what
> you mean.

If no r/wsize has been specified on the client mount then the negotiated
values above will be used by the client for any read() by an application
exceeding that maximum. That maximum (the default 1MB) is still quite
large I reckon.

I'm not sure at which point the preferred or optimal block size will
be used by the client - because they're set as the same on the server
side, I can't tell which is being used ;)

> (I haven't actually looked at how typical clients used rt/wtpref.)
> 
> --b.
> 
> > Perhaps a better suggestion would be to at least expose the maximum
> > and preferred
> > block sizes (for both read and write) via a sysctl key so an
> > administrator can set
> > it to the underlying block sizes of the file system or physical
> > device?
> > 
> > Perhaps the defaults should at least be a smaller multiple of the
> > page size or somewhere
> > between that and the PDU of the network layer the service is bound
> > too.
> > 
> > Just my tuppence - and my maths might be flawed ;)
> > 
> > Jim
> > 
> > > I'm not sure what the history is behind that logic, though.
> > > 
> > > --b.
> > > 
> > 
> > --
> > Jim Vanns
> > Senior Software Developer
> > Framestore
> 

-- 
Jim Vanns
Senior Software Developer
Framestore
