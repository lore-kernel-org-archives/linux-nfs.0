Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx4.framestore.com ([193.203.83.5]:52133 "EHLO
	mx4.framestore.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753653Ab3EQLrI convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 17 May 2013 07:47:08 -0400
Date: Fri, 17 May 2013 12:43:02 +0100 (BST)
From: James Vanns <james.vanns@framestore.com>
Reply-To: james.vanns@framestore.com
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-ID: <1246706961.20581741.1368790982374.JavaMail.root@framestore.com>
In-Reply-To: <20130515174245.GN16811@fieldses.org>
Subject: Re: Where in the server code is fsinfo rtpref calculated?
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

> Knowing nothing about your situation, I'd assume the clients are
> doing that because they actually want that 1MB of data.

Possibly. But we have no control over that (the application read size,
I mean).

> Would you prefer they each send 1024 1k READs?  I don't understand
> why it's the read size you're focused on here.

No. But 32x 32k reads is reasonable (because it gives other RPCs a
look-in). I'm focused on reads because it makes up the majority of
our NFS traffic. I'm concerned because as it stands (out of the box)
if the majority of our n knfsd threads are waiting for a 1MB read to
return then no other RPC request will be serviced and will just
contribute to the backlog. This backlog itself will probably also contain
a hefty no. of 1MB read requests too. In short, a lot of other RPC calls
that are not reads will just be blocking and this will appear to an end
user as poor performance.

We deal with a great number of fairly large files - 10s of GBs in size. We just
don't want others to suffer because of large request sizes coming in (writes
end up being of the same size too but there are less of them). Our use cases are
varied but they all have to share the same resource (the array of NFS servers).

We've only really seen this since our upgrade to SL6/kernel 2.6.32. I guess 
previously that 32k was some sort of default or limit?

Related to this was my query on when/how the (Linux) client may honour the preferred
or optimal block size given in the FSINFO reply. Any ideas? Is it if a read of
less than that preferred block size is requested then the preferred is used anyway
because it comes at the same cost?

Thanks,

Jim

> --b.
> 
> > 
> > After the initial MOUNT request has been granted an FSINFO call is
> > made. The contents of the REPLY from the server (another Linux
> > 2.6.32
> > server) include rtmax, rtpref, wtmax and wtpref all of which are
> > set
> > to 1MB. This 1MB appears to come from that code/explanation I
> > described earlier  - all values are basically getting set to
> > whatever
> > comes out of nfsd_get_default_max_blksize().
> 
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs"
> in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 

-- 
Jim Vanns
Senior Software Developer
Framestore

