Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx0a-001b2d01.pphosted.com ([148.163.156.1]:62801 "EHLO
	mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1030193AbcFNALJ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 13 Jun 2016 20:11:09 -0400
Received: from pps.filterd (m0098394.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.11/8.16.0.11) with SMTP id u5E08lmS028918
	for <linux-nfs@vger.kernel.org>; Mon, 13 Jun 2016 20:11:08 -0400
Received: from e33.co.us.ibm.com (e33.co.us.ibm.com [32.97.110.151])
	by mx0a-001b2d01.pphosted.com with ESMTP id 23gf59141y-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-nfs@vger.kernel.org>; Mon, 13 Jun 2016 20:11:08 -0400
Received: from localhost
	by e33.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-nfs@vger.kernel.org> from <malahal@us.ibm.com>;
	Mon, 13 Jun 2016 18:11:07 -0600
Date: Mon, 13 Jun 2016 19:10:56 -0500
From: Malahal Naineni <malahal@us.ibm.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: sebastien cabaniols <sebastien.cabaniols@gmail.com>,
        linux-nfs@vger.kernel.org
Subject: Re: does the linux NFS client support for failover to a replica
 share (read-only share)
References: <CALipME=i0H5bAHf3AuXU2EnEDOmmzK58x4D7Oz+YDp5MsUao4g@mail.gmail.com>
 <20160613155237.GC17866@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20160613155237.GC17866@fieldses.org>
Message-Id: <20160614001055.GB2634@us.ibm.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

J. Bruce Fields [bfields@fieldses.org] wrote:
> On Tue, Jun 07, 2016 at 10:02:19PM +0200, sebastien cabaniols wrote:
> > Hello linux-nfs mailing list.
> > 
> > I would like to know if the linux nfs client included in current
> > versions of the kernel supports fail-over to a replica on another nfs
> > server, I am using (manually) synchronized read-only shares...
> > 
> > I found very few information on Google about this topic and I suspect
> > this is not implemented.
> 
> That's correct (unless I've missed something!).
> 
> > I actually tried to setup this using SLES12SP1 (3.12.49 kernel) but I
> > failed so far. I am not attached to this distribution/version in
> > particular, just trying to see it working for real.
> > 
> > ( I did some "rpcdebug -m nfs" session and it seems the fs_locations
> > is not getting properly populated on my setup )
> > 
> > Any confirmation this should work or not would actually help me.
> > 
> > THX.
> > 
> > 
> > note from the exports man page:
> > 
> >        replicas=path@host[+host][:path@host[+host]]
> >               If  the  client  asks for alternative locations for the
> > export point, it will be given this list of alternatives.
> >               (Note that actual replication of the filesystem must be
> > handled elsewhere.)
> 
> Yes, the server side (assuming you've got the backend replication
> working) is pretty easy, and should work (though I don't know if it's
> gotten any testing).

Bruce, we did test the server side couple years ago. I don't remember
any issues on the server side. We did some rudimentary support on the
client side (we were using rsync for replication and our exports were
read-only!). I remember "find" having an issue with inode number change
while it was running, but don't remember any other issues. The client
patches never made it to mainline though.

Regards, Malahal.

