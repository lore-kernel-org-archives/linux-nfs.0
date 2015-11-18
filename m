Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:39971 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932216AbbKRUWW (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 18 Nov 2015 15:22:22 -0500
Date: Wed, 18 Nov 2015 15:22:20 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Jeff Layton <jlayton@poochiereds.net>
Cc: trond.myklebust@primarydata.com, linux-nfs@vger.kernel.org,
        Eric Paris <eparis@parisplace.org>,
        Alexander Viro <viro@zeniv.linux.org.uk>,
        linux-fsdevel@vger.kernel.org
Subject: Re: [PATCH v1 38/38] nfs: add a Kconfig option for NFS reexporting
 and documentation
Message-ID: <20151118202220.GA992@fieldses.org>
References: <1447761180-4250-1-git-send-email-jeff.layton@primarydata.com>
 <1447761180-4250-39-git-send-email-jeff.layton@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1447761180-4250-39-git-send-email-jeff.layton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Nov 17, 2015 at 06:53:00AM -0500, Jeff Layton wrote:
> +Filehandle size:
> +----------------
> +The maximum filehandle size is governed by the NFS version. Version 2
> +used fixed 32 byte filehandles. Version 3 moved to variable length
> +filehandles that can be up to 64 bytes in size. NFSv4 increased that
> +maximum to 128 bytes.
> +
> +When reexporting an NFS filesystem, the underlying filehandle from the
> +server must be embedded inside the filehandles presented to clients.
> +Thus if the underlying server presents filehandles that are too big, the
> +reexporting server can fail to encode them. This can lead to
> +NFSERR_OPNOTSUPP errors being returned to clients.
> +
> +This is not a trivial thing to programatically determine ahead of time
> +(and it can vary even within the same server), so some foreknowledge of
> +how the underlying server constructs filehandles, and their maximum
> +size is a must.

This is the trickiest one, since it depends on an undocumented
implementation detail of the server.

Do we even know if this works for all the exportable Linux filesystems?

If proxying NFSv4.x servers is actually useful, could we add a per-fs
maximum-filesystem-size attribute to the protocol?

--b.
