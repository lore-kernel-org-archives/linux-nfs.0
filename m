From: Miklos Szeredi <miklos@szeredi.hu>
Subject: Re: [PATCH 0/2] vfs: ensure that dentries are revalidated on open (try #2)
Date: Wed, 11 Nov 2009 08:57:02 +0100
Message-ID: <E1N884c-0006Br-Je@pomaz-ex.szeredi.hu>
References: <1257870456-31188-1-git-send-email-jlayton@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
	linux-nfs@vger.kernel.org, ebiederm@xmission.com,
	adobriyan@gmail.com, viro@ZenIV.linux.org.uk, jamie@shareable.org
To: Jeff Layton <jlayton@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fxip-0047f.externet.hu ([88.209.222.127]:41160 "EHLO
	pomaz-ex.szeredi.hu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751685AbZKKH5F (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 11 Nov 2009 02:57:05 -0500
In-reply-to: <1257870456-31188-1-git-send-email-jlayton@redhat.com> (message
	from Jeff Layton on Tue, 10 Nov 2009 11:27:34 -0500)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 10 Nov 2009, Jeff Layton wrote:
> This is the second attempt to fix this problem. The first one attempted
> to fix this in procfs, but Eric Biederman pointed out that file bind
> mounts have a similar problem. This set attempts to fix the issue at a
> higher level, in the generic VFS layer.

I suspect the correct fix would be to clean up the open API so that
NFSv4 doesn't have to hack its stateful open routine into the
->lookup() and ->d_revalidate() methods.

Having said that, doing revalidation for proc symlinks and bind mounts
(and not just for opens) might make sense.  This is something similar
to FS_REVAL_DOT, so perhaps make it conditional on this flag (or a
new, appropriately named one).

Thanks,
Miklos
