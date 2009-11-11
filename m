From: Miklos Szeredi <miklos@szeredi.hu>
Subject: Re: [PATCH 0/2] vfs: ensure that dentries are revalidated on open
 (try #2)
Date: Wed, 11 Nov 2009 09:33:56 +0100
Message-ID: <E1N88eK-0006Im-1F@pomaz-ex.szeredi.hu>
References: <1257870456-31188-1-git-send-email-jlayton@redhat.com>
	 <E1N884c-0006Br-Je@pomaz-ex.szeredi.hu> <1257927970.5138.24.camel@heimdal.trondhjem.org>
Cc: miklos@szeredi.hu, jlayton@redhat.com,
	linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
	linux-nfs@vger.kernel.org, ebiederm@xmission.com,
	adobriyan@gmail.com, viro@ZenIV.linux.org.uk, jamie@shareable.org
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fxip-0047f.externet.hu ([88.209.222.127]:46658 "EHLO
	pomaz-ex.szeredi.hu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755719AbZKKIeA (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 11 Nov 2009 03:34:00 -0500
In-reply-to: <1257927970.5138.24.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org> (message from
	Trond Myklebust on Wed, 11 Nov 2009 17:26:10 +0900)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 11 Nov 2009, Trond Myklebust wrote:
> > Having said that, doing revalidation for proc symlinks and bind mounts
> > (and not just for opens) might make sense.  This is something similar
> > to FS_REVAL_DOT, so perhaps make it conditional on this flag (or a
> > new, appropriately named one).
> 
> Aren't both proc symlinks and bind mounts pretty much guaranteed to
> point to a valid dentry?

It could for example happen that client bind mounts a regular file,
then the file is unlinked on the server.  Then the bind mounted dentry
is no longer valid.

Thanks,
Miklos
