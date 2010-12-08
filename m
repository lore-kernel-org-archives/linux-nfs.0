Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out1.uio.no ([129.240.10.57]:37078 "EHLO mail-out1.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755569Ab0LHTDk (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 8 Dec 2010 14:03:40 -0500
Subject: Re: [Bug 24302] Kernel crashes when repeatedly trying to mount nfs
 share that is failing
From: Trond Myklebust <trond.myklebust@fys.uio.no>
To: bugzilla-daemon@bugzilla.kernel.org
Cc: "Mr. Charles Edward Lever" <Chuck.Lever@oracle.com>,
        linux-nfs@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>,
        stefan.bader@canonical.com
In-Reply-To: <201012081830.oB8IUZ4t027387@demeter2.kernel.org>
References: <bug-24302-104@https.bugzilla.kernel.org/>
	 <201012081830.oB8IUZ4t027387@demeter2.kernel.org>
Content-Type: text/plain; charset="UTF-8"
Date: Wed, 08 Dec 2010 14:03:30 -0500
Message-ID: <1291835010.3067.4.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, 2010-12-08 at 18:30 +0000, bugzilla-daemon@bugzilla.kernel.org
wrote:
> https://bugzilla.kernel.org/show_bug.cgi?id=24302
> 
> 
> Andrew Morton <akpm@linux-foundation.org> changed:
> 
>            What    |Removed                     |Added
> ----------------------------------------------------------------------------
>           Component|Other                       |NFS
>          AssignedTo|fs_other@kernel-bugs.osdl.o |trond.myklebust@fys.uio.no
>                    |rg                          |
> 
> 
> 
> 
> --- Comment #8 from Andrew Morton <akpm@linux-foundation.org>  2010-12-08 18:30:32 ---
> OK, I reassigned it to NFS.  If that was wrong then at least the NFS guys
> should be able to help point things in the right direction.

<Switching to email interface. Please do not edit the bugzilla entry
directly, since that will lose the above Cc information>


Chuck,

Stefan appears to be hitting a panic in the nfs_umount() call from
nfs_walk_authlist(). Can you take a look, please?

Cheers
  Trond

