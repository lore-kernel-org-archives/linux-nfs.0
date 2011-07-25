Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:16802 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751595Ab1GYTa7 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 25 Jul 2011 15:30:59 -0400
Subject: Re: Umount and delegation release thread syncronization
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Ian Kent <raven@themaw.net>
Cc: linux-nfs@vger.kernel.org, Chuck Lever <chuck.lever@oracle.com>
Date: Mon, 25 Jul 2011 15:30:52 -0400
In-Reply-To: <1310442708.25348.10.camel@perseus.themaw.net>
References: <1308555929.3306.43.camel@perseus.themaw.net>
	 <1310442708.25348.10.camel@perseus.themaw.net>
Content-Type: text/plain; charset="UTF-8"
Message-ID: <1311622252.28209.21.camel@lade.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Tue, 2011-07-12 at 11:51 +0800, Ian Kent wrote: 
> On Mon, 2011-06-20 at 15:45 +0800, Ian Kent wrote:
> > Hi all,
> > 
> > I'm having difficulty working out how delegation release threads are
> > synchronized with umount.
> > 
> > For an information about the problem please see
> > https://bugzilla.kernel.org/show_bug.cgi?id=30882 and in particular
> > comment #28.
> > 
> > Can someone please give me a description of the sequence of events at
> > umount (aka. nfs4_kill_super() function calls). In particular how does
> > nfs_free_server() know that if nfs_super_return_all_delegations() starts
> > a thread that it is finished before freeing the server struct.
> 
> No response in almost a month. everyone must be really busy.
> 
> But does no-one know how this works?
> 
> Trond, could you have a look at the above bug and offer your input
> please.

The only code that seems dubious there is the line

clp = NFS_SERVER(delegation->inode)->nfs_client;

Both the delegation and the nfs_client are guaranteed to still be around
whenever nfs_expire_unreferenced_delegations() is called: the RCU
protection of the clp->cl_superblock and server->delegations lists
ensures that.

However the delegation->inode is not guaranteed to still exist...

The obvious fix is to pass the struct nfs_server as a parameter to
nfs_mark_return_delegation() instead of trying to derive it from the
inode.

Cheers
  Trond

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

