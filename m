Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:46555 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750910AbaKYWkR (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 25 Nov 2014 17:40:17 -0500
Date: Tue, 25 Nov 2014 17:40:16 -0500
To: Steve Dickson <steved@redhat.com>
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>,
        Systemd Mailing List <systemd-devel@lists.freedesktop.org>
Subject: Re: [PATCH] rpcbind: systemd socket activation (v2)
Message-ID: <20141125224015.GC15033@fieldses.org>
References: <1416935133-7104-1-git-send-email-steved@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1416935133-7104-1-git-send-email-steved@redhat.com>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Nov 25, 2014 at 12:05:32PM -0500, Steve Dickson wrote:
> This is based on a patch originally posted by Lennart Poettering:
> <http://permalink.gmane.org/gmane.linux.nfs/33774>.

Have you run this by the reporter
of https://bugzilla.redhat.com/show_bug.cgi?id=1158164 ?

Because he tried applying that old patch and found he was still having
problems.

But they may well be problems that are fixed by your version, or he may
have applied it incorrectly, I didn't try to figure it out.

--b.

> 
> That patch was not merged due to the lack of a shared library and
> as systemd was seen to be too Fedora specific.
> 
> Systemd now provides a shared library, and it is (or very soon will
> be) the default init system on all the major Linux distributions.
> 
> This version of the patch has three changes from the original:
> 
>  * It uses the shared library.
>  * It comes with unit files.
>  * It is rebased on top of master.
> 
> Please review the patch with "git show -b" or otherwise ignoring the
> whitespace changes, or it will be extremely difficult to read.
> 
> v5: incorporated comments on the PKG_CHECK_MODULES macro.
> 
> v4: reorganized the changes to make the diff easier to read
> 	remove systemd scripts.
> 
> v3: rebase
> 	fix typos
> 	listen on /run/rpcbind.sock, rather than /var/run/rpcbind.sock (the
> 	latter is a symlink to the former, but this means the socket can be
> 	created before /var is mounted)
> 	NB: this version has been compile-tested only as I no longer use
> 	rpcbind myself
> v2: correctly enable systemd code at compile time
> 	handle the case where not all the required sockets were supplied
> 	listen on udp/tcp port 111 in addition to /var/run/rpcbind.sock
> 	do not daemonize
> 
> Tom Gundersen (1):
>   rpcbind: add support for systemd socket activation
> 
>  Makefile.am   |  6 +++++
>  configure.ac  | 12 +++++++++
>  src/rpcbind.c | 81 ++++++++++++++++++++++++++++++++++++++++++++++++++++++-----
>  3 files changed, 93 insertions(+), 6 deletions(-)
> 
> -- 
> 1.9.3
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
