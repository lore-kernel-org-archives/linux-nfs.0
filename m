Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:57536 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754682Ab2AQQ2V (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 17 Jan 2012 11:28:21 -0500
Date: Tue, 17 Jan 2012 11:28:20 -0500
To: Sachin Prabhu <sprabhu@redhat.com>
Cc: Jim Rees <rees@umich.edu>, linux-nfs <linux-nfs@vger.kernel.org>,
        Steve Dickson <steved@redhat.com>
Subject: Re: svcgssd: Allow administrators to specify timeout for the
 cached context
Message-ID: <20120117162820.GA13977@fieldses.org>
References: <1326800668.2747.55.camel@sprabhu.fab.redhat.com>
 <20120117134951.GA15479@umich.edu>
 <1326814728.2747.59.camel@sprabhu.fab.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1326814728.2747.59.camel@sprabhu.fab.redhat.com>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Jan 17, 2012 at 03:38:47PM +0000, Sachin Prabhu wrote:
> On Tue, 2012-01-17 at 08:49 -0500, Jim Rees wrote:
> > Sachin Prabhu wrote:
> > 
> >   We had a user report that for an export shared with sec=krb5*, any
> >   changes in user credentials(ex: add user to a secondary group) take some
> >   time before they take effect over the NFS share.
> > 
> > Re-authenticating, either by removing the service ticket or by re-running
> > kinit at the client, should also flush the old credentials.  Can you confirm
> > that works?
> 
> We have tried it but it doesn't work unless you actually clean up the
> cache on the NFS server with the command 
> echo `date +'%s'` > /proc/net/rpc/auth.rpcsec.context/flush
> 
> To reproduce:
> 1) Export a nfs4 share using kerberos authentication
> /export-krb5 *(rw,sec=krb5)
> 2) Create user foo part of group foo. Make sure that the user details
> for this user are available both on client and server.
> 3) Create group bar.
> 4) Create 2 directories on the nfs share.
> Directory foo with ownership root.foo and mode set to 2775
> Directory bar with ownership root.bar and mode set to 2775
> 
> On the client, 
> 1) mount the share export from the nfs server from step1
> 2) Login and obtain a kerberos principal for user foo.
> 3) create file in /mnt/foo/ and confirm that the user can write to the
> directory
> 4) try and create file in /mnt/bar. This should fail since the user
> doesn't have permissions to write to this directory.
> 5) Modify user foo to add additional group bar. Make sure that these
> details are available on both the nfs server and client.
> 6) Re-login as foo and confirm that the user is part of group bar using
> the id command. Re-initialise the kerberos ticket.
> 7) try creating file in /mnt/foo. This is successful.
> 8) try creating file in /mnt/bar. This fails even though user has
> permission to write to this directory.

I think that's because none of these client operations actually destroy
the context kept in the kernel on the client side.  You probably will
see the change if you add an umount/mount step between client steps 5
and 6.

That should be fixed too, some day.

It might also be nice to have a server-side command that does the
/proc/net/rpc/auth.rpcsec.context/flush thing.  I'm not sure what a good
UI would be.

But the configurable timeout also seems like a reasonable thing to have.

--b.
