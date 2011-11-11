Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:36656 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751400Ab1KKWl7 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 11 Nov 2011 17:41:59 -0500
Message-ID: <1321051317.4810.17.camel@lade.trondhjem.org>
Subject: Re: [PATCH] KEYS: Allow special keyrings to be cleared
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: David Howells <dhowells@redhat.com>
Cc: jmorris@redhat.com, keyrings@linux-nfs.org,
        linux-security-module@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-cifs@vger.kernel.org, linux-kernel@vger.kernel.org
Date: Fri, 11 Nov 2011 17:41:57 -0500
In-Reply-To: <20111111160753.5190.36069.stgit@warthog.procyon.org.uk>
References: <20111111160753.5190.36069.stgit@warthog.procyon.org.uk>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 2011-11-11 at 16:07 +0000, David Howells wrote: 
> The kernel contains some special internal keyrings, for instance the DNS
> resolver keyring :
> 
> 2a93faf1 I-----     1 perm 1f030000     0     0 keyring   .dns_resolver: empty
> 
> It would occasionally be useful to allow the contents of such keyrings to be
> flushed by root (cache invalidation).
> 
> Allow a flag to be set on a keyring to mark that someone possessing the
> sysadmin capability can clear the keyring, even without normal write access to
> the keyring.
> 
> Set this flag on the special keyrings created by the DNS resolver, the NFS
> identity mapper and the CIFS identity mapper.
> 
> Signed-off-by: David Howells <dhowells@redhat.com>
> Acked-by: Jeff Layton <jlayton@redhat.com>
> Acked-by: Steve Dickson <steved@redhat.com>
Acked-by: Trond Myklebust <Trond.Myklebust@netapp.com>


-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

