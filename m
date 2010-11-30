Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:9811 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752066Ab0K3VoV convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 30 Nov 2010 16:44:21 -0500
Subject: Re: [PATCH v2 0/4] Allow the admin to turn off NFSv4 uid/gid
 mapping
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org
In-Reply-To: <20101130192441.GD29091@fieldses.org>
References: <1291124043-5074-1-git-send-email-Trond.Myklebust@netapp.com>
	 <20101130192441.GD29091@fieldses.org>
Content-Type: text/plain; charset="UTF-8"
Date: Tue, 30 Nov 2010 16:44:13 -0500
Message-ID: <1291153453.2998.9.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Tue, 2010-11-30 at 14:24 -0500, J. Bruce Fields wrote:
> On Tue, Nov 30, 2010 at 08:33:59AM -0500, Trond Myklebust wrote:
> > The following patches allow the admin to turn off NFSv4 uid/gid mapping
> > if mounting using AUTH_SYS security.
> 
> Maybe that should be "when a mountpoint allows only AUTH_SYS security"?
> 
> (Once we start allowing auth_flavor_len > 1, presumably we don't want to
> change mappings depending on which flavor an individual getattr used!)

> Also, maybe it's right, but I'm a little weirded about by the dependency
> on the auth flavor.

The reason for wanting to restrict this to AUTH_SYS is that the latter
authenticates us using the uid/gid rather than a principal. In that case
(and only in that case), it makes sense to add the assumption that there
is an identity mapping between uids and gids on the client and server,
and that we should make use of that identity mapping.

In the case where auth_flavor_len > 1 (if ever we implement that), I
think we should in fact change mappings depending on the flavour
actually used for the RPC call. The reason is that principals may
authenticate to completely different users/groups on the server, even if
the above identity map between uids and gids exists.

Cheers
  Trond
-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

