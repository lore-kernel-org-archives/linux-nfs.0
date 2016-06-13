Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:55224 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1424417AbcFMPwi (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 13 Jun 2016 11:52:38 -0400
Date: Mon, 13 Jun 2016 11:52:37 -0400
To: sebastien cabaniols <sebastien.cabaniols@gmail.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: does the linux NFS client support for failover to a replica
 share (read-only share)
Message-ID: <20160613155237.GC17866@fieldses.org>
References: <CALipME=i0H5bAHf3AuXU2EnEDOmmzK58x4D7Oz+YDp5MsUao4g@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <CALipME=i0H5bAHf3AuXU2EnEDOmmzK58x4D7Oz+YDp5MsUao4g@mail.gmail.com>
From: bfields@fieldses.org (J. Bruce Fields)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Jun 07, 2016 at 10:02:19PM +0200, sebastien cabaniols wrote:
> Hello linux-nfs mailing list.
> 
> I would like to know if the linux nfs client included in current
> versions of the kernel supports fail-over to a replica on another nfs
> server, I am using (manually) synchronized read-only shares...
> 
> I found very few information on Google about this topic and I suspect
> this is not implemented.

That's correct (unless I've missed something!).

> I actually tried to setup this using SLES12SP1 (3.12.49 kernel) but I
> failed so far. I am not attached to this distribution/version in
> particular, just trying to see it working for real.
> 
> ( I did some "rpcdebug -m nfs" session and it seems the fs_locations
> is not getting properly populated on my setup )
> 
> Any confirmation this should work or not would actually help me.
> 
> THX.
> 
> 
> note from the exports man page:
> 
>        replicas=path@host[+host][:path@host[+host]]
>               If  the  client  asks for alternative locations for the
> export point, it will be given this list of alternatives.
>               (Note that actual replication of the filesystem must be
> handled elsewhere.)

Yes, the server side (assuming you've got the backend replication
working) is pretty easy, and should work (though I don't know if it's
gotten any testing).  The client has the harder job here.

--b.
