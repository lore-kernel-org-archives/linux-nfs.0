From: Frank van Maarseveen <frankvm@frankvm.com>
Subject: Re: V3 ACCESS call fails after server reboot
Date: Mon, 10 Dec 2007 19:17:09 +0100
Message-ID: <20071210181709.GA9326@janus>
References: <20071210172004.GA8094@janus> <20071210174117.GK17209@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux NFS mailing list <linux-nfs@vger.kernel.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from frankvm.xs4all.nl ([80.126.170.174]:53911 "EHLO
	janus.localdomain" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752533AbXLJSRL (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 10 Dec 2007 13:17:11 -0500
In-Reply-To: <20071210174117.GK17209@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Dec 10, 2007 at 12:41:17PM -0500, J. Bruce Fields wrote:
> On Mon, Dec 10, 2007 at 06:20:04PM +0100, Frank van Maarseveen wrote:
> > Tested on 2.6.22.10 and 2.6.23.9, client and server running same version.
> > export options: rw,sync,no_root_squash,no_subtree_check,mp
> > 
> > After a substantial amount of time (days) but also after a server
> > reboot a process loses access to its current working directory when
> > access to a parent directory two (or more) levels up has been revoked:
> > 
> > 	$ cd /mnt
> > 	$ mkdir -p a/b/c
> > 	$ cd a/b/c
> > 	$ chmod 0 ../..
> > 	$ ls -a
> > 	. ..
> > 	$
> > 		(wait a loong time or reboot server)
> > 	$ ls -a
> > 	ls: .: Permission denied
> > 
> > Network traffic capture showed a V3 ACCESS call for above "." failing
> > on the server after the reboot with NFS3ERR_ACCES. It succeeded before.
> > 
> > I have the impression the server is internally rechecking the entire
> > path when its caches have been flushed. This behavior is problematic
> > for daemons which change uid, for example.
> 
> What are your export options?  (Do you have nosubtreecheck turned on?)
yes, see above export options.

-- 
Frank
