Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx4.framestore.com ([193.203.83.5]:54053 "EHLO
	mx4.framestore.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751813Ab3EOJZD (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 15 May 2013 05:25:03 -0400
Date: Wed, 15 May 2013 10:21:06 +0100 (BST)
From: James Vanns <james.vanns@framestore.com>
Reply-To: james.vanns@framestore.com
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-ID: <689306088.19845834.1368609666236.JavaMail.root@framestore.com>
In-Reply-To: <20130514220122.GE16811@fieldses.org>
Subject: Re: Where in the server code is fsinfo rtpref calculated?
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

> There's no way to specify that as an export option.  You can
> configure
> it server-wide using /proc/fs/nfsd/max_block_size.

Ah ha! Bingo. There it is. I can see it on our SL6 (2.6.32)
servers but not on older RHEL5 (2.6.18) servers so I guess
at some point this was hardcoded to 32k?

> > and so I need to
> > find where this negotiated value between server->client actually
> > comes
> > from. How does the server reach the preferred block size for a
> > given
> > export?
> 
> fs/nfsd/nfssvc.c:nfsd_get_default_maxblksize() is probably a good
> starting point.  Its caller, nfsd_create_serv(), calls
> svc_create_pooled() with the result that's calculated.

Thanks. I shall look there.

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

