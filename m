Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.linuxfoundation.org ([140.211.169.12]:41767 "EHLO
	mail.linuxfoundation.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751331AbbLIUKh (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 9 Dec 2015 15:10:37 -0500
Date: Wed, 9 Dec 2015 15:10:35 -0500
From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
To: Fabian Frederick <fabf@skynet.be>
Cc: linux-kernel@vger.kernel.org, Alexander Viro <viro@zeniv.linux.org.uk>,
        Joel Becker <jlbec@evilplan.org>, Joern Engel <joern@logfs.org>,
        Prasad Joshi <prasadjoshi.linux@gmail.com>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        Jeff Layton <jlayton@poochiereds.net>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        linux-fsdevel@vger.kernel.org, logfs@logfs.org,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH 1/1] fs.h: import umode to DT conversion
Message-ID: <20151209201035.GB10341@kroah.com>
References: <1449690448-18021-1-git-send-email-fabf@skynet.be>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1449690448-18021-1-git-send-email-fabf@skynet.be>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Dec 09, 2015 at 08:47:28PM +0100, Fabian Frederick wrote:
> The same umode -> DT calculation existed in different
> filesystems.
> 
> Signed-off-by: Fabian Frederick <fabf@skynet.be>
> ---
>  fs/configfs/dir.c  | 8 +-------
>  fs/kernfs/dir.c    | 8 +-------
>  fs/libfs.c         | 9 ++-------
>  fs/logfs/dir.c     | 4 ++--
>  fs/logfs/logfs.h   | 5 -----
>  fs/nfs/internal.h  | 9 ---------
>  fs/nfs/nfs3xdr.c   | 2 +-
>  fs/nfs/nfs4xdr.c   | 2 +-
>  fs/nfs/nfstrace.h  | 2 +-
>  include/linux/fs.h | 2 ++
>  10 files changed, 11 insertions(+), 40 deletions(-)

For fs/kernfs/dir.c:

Acked-by: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
