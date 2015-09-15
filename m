Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from elasmtp-curtail.atl.sa.earthlink.net ([209.86.89.64]:56123 "EHLO
	elasmtp-curtail.atl.sa.earthlink.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751904AbbIOQdj (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 15 Sep 2015 12:33:39 -0400
From: "Frank Filz" <ffilzlnx@mindspring.com>
To: "'Chuck Lever'" <chuck.lever@oracle.com>,
        "'Linux NFS Mailing List'" <linux-nfs@vger.kernel.org>
References: <7A550B5E-9EAB-4431-BBBA-1C77EE86539F@oracle.com>
In-Reply-To: <7A550B5E-9EAB-4431-BBBA-1C77EE86539F@oracle.com>
Subject: RE: NFSv4 security negotiation issue
Date: Tue, 15 Sep 2015 09:33:26 -0700
Message-ID: <019501d0efd4$401f4240$c05dc6c0$@mindspring.com>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

> We've found an unexpected behavior with mount security negotiation in the
> current Linux NFS client.
> 
> Given two real shares on an NFS server: one is a sys-only share, and the
> other is a krb5-only share. When we try to mount the sys-only share
without
> specifying a sec= option, it fails. Specifying sec=sys is successful.
> 
> What is seen on the wire:
> 
> 1. The client attempts to access the pseudofs, and negotiates
> krb5
> 
> 2. The client walks down the pseudofs namespace to the sys-only share
> 
> 3. The client attempts to access the sys-only share with krb5 and gets
> WRONGSEC
> 
> 4. The client negotiates sys, and continues setting up the mount
> 
> 5. nfs_fs_mount_common() invokes nfs_get_root(), but it uses the
> pseudofs superblock, so it does a GETATTR on the share's root directory
with
> krb5, and that fails
> 
> At this point the client gives up, and the mount attempt fails.
> 
> We could alter the server to allow a GETATTR with the same flavor as the
> underlying directory. But seems like the problem is on the client: it
should
> use the negotiated flavor that is appropriate to the share, not the flavor
> appropriate for the pseudofs.
> 
> Any thoughts?

Hmm, I thought maybe this was a scenario I had not tested, but I think I'm
misunderstanding the sequence. Could you summarize the ops and response for
each COMPOUND request?

I don't think the server should have to do anything special here.

Frank



---
This email has been checked for viruses by Avast antivirus software.
https://www.avast.com/antivirus

