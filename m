Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:3894 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754384Ab2AQPiv (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 17 Jan 2012 10:38:51 -0500
Subject: Re: svcgssd: Allow administrators to specify timeout for the cached
 context
From: Sachin Prabhu <sprabhu@redhat.com>
To: Jim Rees <rees@umich.edu>
Cc: linux-nfs <linux-nfs@vger.kernel.org>, Steve Dickson <steved@redhat.com>
Date: Tue, 17 Jan 2012 15:38:47 +0000
In-Reply-To: <20120117134951.GA15479@umich.edu>
References: <1326800668.2747.55.camel@sprabhu.fab.redhat.com>
	 <20120117134951.GA15479@umich.edu>
Content-Type: text/plain; charset="UTF-8"
Message-ID: <1326814728.2747.59.camel@sprabhu.fab.redhat.com>
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 2012-01-17 at 08:49 -0500, Jim Rees wrote:
> Sachin Prabhu wrote:
> 
>   We had a user report that for an export shared with sec=krb5*, any
>   changes in user credentials(ex: add user to a secondary group) take some
>   time before they take effect over the NFS share.
> 
> Re-authenticating, either by removing the service ticket or by re-running
> kinit at the client, should also flush the old credentials.  Can you confirm
> that works?

We have tried it but it doesn't work unless you actually clean up the
cache on the NFS server with the command 
echo `date +'%s'` > /proc/net/rpc/auth.rpcsec.context/flush

To reproduce:
1) Export a nfs4 share using kerberos authentication
/export-krb5 *(rw,sec=krb5)
2) Create user foo part of group foo. Make sure that the user details
for this user are available both on client and server.
3) Create group bar.
4) Create 2 directories on the nfs share.
Directory foo with ownership root.foo and mode set to 2775
Directory bar with ownership root.bar and mode set to 2775

On the client, 
1) mount the share export from the nfs server from step1
2) Login and obtain a kerberos principal for user foo.
3) create file in /mnt/foo/ and confirm that the user can write to the
directory
4) try and create file in /mnt/bar. This should fail since the user
doesn't have permissions to write to this directory.
5) Modify user foo to add additional group bar. Make sure that these
details are available on both the nfs server and client.
6) Re-login as foo and confirm that the user is part of group bar using
the id command. Re-initialise the kerberos ticket.
7) try creating file in /mnt/foo. This is successful.
8) try creating file in /mnt/bar. This fails even though user has
permission to write to this directory.

Sachin Prabhu

