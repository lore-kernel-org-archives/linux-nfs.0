Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:45693 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757775Ab3KHVJd (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 8 Nov 2013 16:09:33 -0500
Date: Fri, 8 Nov 2013 16:09:29 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: Jeff Layton <jlayton@redhat.com>, Steve Dickson <SteveD@redhat.com>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] Adding the nfs4_use_min_auth module parameter
Message-ID: <20131108210929.GH3533@fieldses.org>
References: <A8E8F2C4-8CB7-434E-8520-B2B53F0582D9@oracle.com>
 <527C07B4.800@RedHat.com>
 <44CA89EA-8B5E-4B83-A622-78A78F760FF1@oracle.com>
 <527CDBFC.3070903@RedHat.com>
 <20131108082202.4032f1a2@tlielax.poochiereds.net>
 <20131108150435.GA3533@fieldses.org>
 <08D3FAB2-6163-4C77-9F7E-43DBF55050D6@oracle.com>
 <20131108161409.GC3533@fieldses.org>
 <A016BF31-6C9B-45BF-83AB-E240810D9CA8@oracle.com>
 <03B1CF27-6760-4364-9DB6-818E3A28A38E@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <03B1CF27-6760-4364-9DB6-818E3A28A38E@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Nov 08, 2013 at 10:46:26AM -0800, Chuck Lever wrote:
> The fly in this ointment is allowing clients with no keytab to mount
> with sec=krb5.
> 
> We can use ENOKEY to allow lease management with AUTH_SYS but data
> access using Kerberos and a user's credential.

So "mount -osec=krb5*" means "use krb5* or stronger for everything",
unless you have no keytab in which case it means "use krb5* for all file
access but allow auth_sys for lease maintenance".  Huh.  I guess that
works.

--b.

> 
> Otherwise, a user has to login as root, kinit as themselves, and then
> mount.  That makes automounter configurations a little dodgy.
