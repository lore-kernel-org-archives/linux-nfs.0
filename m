From: nobody@nowhere.invalid (Unknown)
Subject: Re: How to enable debugging on NFS (dprintk)?
Date: Thu, 17 Jul 2003 10:51:12 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20030717145111.GA26740@fieldses.org>
References: <20030717110725.GA24400@pelvoux.gotadsl.co.uk> <3F16B3C0.4050103@cinesite.co.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from dsl093-002-214.det1.dsl.speakeasy.net
	([66.93.2.214] helo=pumpkin.fieldses.org ident=mail)
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19dA7G-0006kM-00
	for <nfs@lists.sourceforge.net>; Thu, 17 Jul 2003 07:52:19 -0700
Received: from bfields by pumpkin.fieldses.org with local (Exim 3.35 #1 (Debian))
	id 19dA6j-0006zj-00
	for <nfs@lists.sourceforge.net>; Thu, 17 Jul 2003 10:51:45 -0400
To: Danny Smith <dannys@cinesite.co.uk>
In-Reply-To: <3F16B3C0.4050103@cinesite.co.uk>
Resent-Message-Id: <E19dA6j-0006zj-00@pumpkin.fieldses.org>
Errors-To: nfs-admin@lists.sourceforge.net
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

On Thu, Jul 17, 2003 at 03:33:36PM +0100, Danny Smith wrote:
> It's controlled by /proc/sys/sunrpc/nfs_debug (or nfsd_debug for the 
> server).
> 
> Not totally sure of the valid values

See include/linux/sunrpc/debug.h, include/linux/nfs_fs.h (the very end,
where the NFSDBG_* macros are defined), and include/linux/nfsd/debug.h.

--Bruce Fields

> but it's an int bit field, so this 
> will turn most things on (client side):
> 
> echo 65535 > /proc/sys/sunrpc/nfs_debug


-------------------------------------------------------
This SF.net email is sponsored by: VM Ware
With VMware you can run multiple operating systems on a single machine.
WITHOUT REBOOTING! Mix Linux / Windows / Novell virtual machines at the
same time. Free trial click here: http://www.vmware.com/wl/offer/345/0
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
