Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:49040 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751388AbcLIU7t (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 9 Dec 2016 15:59:49 -0500
Date: Fri, 9 Dec 2016 15:59:47 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <schumakeranna@gmail.com>
Cc: Andreas Gruenbacher <agruenba@redhat.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: NFSv4.2 mode_umask support
Message-ID: <20161209205947.GC8999@fieldses.org>
References: <20161203035302.GC21785@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20161203035302.GC21785@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Ping--is there anything holding these up?

--b.

On Fri, Dec 02, 2016 at 10:53:02PM -0500, J. Bruce Fields wrote:
> Since the last version, just two minor changes:
> 
> 	- client uses the stored supported attribute results instead of
> 	  a new capability flag.
> 	- if a nutty client attempts to set both mode and new attribute,
> 	  the server returns INVAL instead of ignoring the mode.
> 
> Description, as before:
> 
> The following patches allow the umask to be ignored in the presence of
> inheritable NFSv4 ACLs.  Otherwise inheritable ACLs can be rendered
> mostly useless whenever the umask masks out group bits.
> 
> This solves a problem we've seen complaints about for some time, both
> upstream and from RHEL users.
> 
> The new protocol has been discussed in the IETF working group and is
> documented at:
> 
> 	https://tools.ietf.org/html/draft-ietf-nfsv4-umask-02
> 
> It's unlikely that we'll discover problems requiring an incompatible
> change, so I think we should consider this for 4.10.
> 
> --b.
