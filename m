Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx5.framestore.com ([193.203.83.15]:56129 "EHLO
	mx5.framestore.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754751Ab3EONqj (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 15 May 2013 09:46:39 -0400
Date: Wed, 15 May 2013 14:42:42 +0100 (BST)
From: James Vanns <james.vanns@framestore.com>
Reply-To: james.vanns@framestore.com
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-ID: <1045951723.19965005.1368625362930.JavaMail.root@framestore.com>
In-Reply-To: <20130514220122.GE16811@fieldses.org>
Subject: Re: Where in the server code is fsinfo rtpref calculated?
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

> fs/nfsd/nfssvc.c:nfsd_get_default_maxblksize() is probably a good
> starting point.  Its caller, nfsd_create_serv(), calls
> svc_create_pooled() with the result that's calculated.

Hmm. If I've read this section of code correctly, it seems to me
that on most modern NFS servers (using TCP as the transport) the default
and preferred blocksize negotiated with clients will almost always be
1MB - the maximum RPC payload. The nfsd_get_default_maxblksize() function
seems obsolete for modern 64-bit servers with at least 4G of RAM as it'll
always prefer this upper bound instead of any value calculated according to
available RAM.

For what it's worth (not sure if I specified this) I'm running kernel 2.6.32.

Anyway, this file/function appears to set the default *max* blocksize. I haven't 
read all the related code yet, but does the preferred block size derive 
from this maximum too?

Thanks,

Jim

> For fsinfo see fs/nfsd/nfs3proc.c:nfsd3_proc_fsinfo, which uses
> svc_max_payload().
> 
> --b.
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs"
> in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 

-- 
Jim Vanns
Senior Software Developer
Framestore
