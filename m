From: Jos van Wezel <jvw@iwr.fzk.de>
Subject: Re: permission bits for group not honoured on directory creation
Date: Thu, 2 Sep 2004 23:36:06 +0200 (CEST)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.LNX.4.44.0409022332120.18039-100000@hikjos.fzk.de>
References: <20040902210005.GB4801@janus>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1C2zFg-0008T9-Pb
	for nfs@lists.sourceforge.net; Thu, 02 Sep 2004 14:36:16 -0700
Received: from fzkmail2.fzk.de ([141.52.27.52])
	by sc8-sf-mx1.sourceforge.net with smtp (Exim 4.34)
	id 1C2zFf-0000aL-Vl
	for nfs@lists.sourceforge.net; Thu, 02 Sep 2004 14:36:16 -0700
Received: from hikjos.fzk.de (localhost [127.0.0.1])
	by hikjos.fzk.de (8.12.3/8.12.3/SuSE Linux 0.6) with ESMTP id i82La6Jm018141
	for <nfs@lists.sourceforge.net>; Thu, 2 Sep 2004 23:36:06 +0200
Received: from localhost (jvw@localhost)
	by hikjos.fzk.de (8.12.3/8.12.3/Submit) with ESMTP id i82La6Te018138
	for <nfs@lists.sourceforge.net>; Thu, 2 Sep 2004 23:36:06 +0200
To: nfs@lists.sourceforge.net
In-Reply-To: <20040902210005.GB4801@janus>
Errors-To: nfs-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

As Trond correctly hinted it had to do with the underlying file system
which in our case is GPFS. Permissions on an exported ext3 fs work as
expected.

Thanks

Jos

On Thu, 2 Sep 2004, Trond Myklebust wrote:

> You've checked that the setgid bit is not set on the parent directory
> and that the filesystem has not been mounted with the grpid/bsdgroups
> option on the server?

On Thu, 2 Sep 2004, Frank van Maarseveen wrote:

>
> cannot reproduce. I would surely be bitten by such a bug.
>
>




-------------------------------------------------------
This SF.Net email is sponsored by BEA Weblogic Workshop
FREE Java Enterprise J2EE developer tools!
Get your free copy of BEA WebLogic Workshop 8.1 today.
http://ads.osdn.com/?ad_id=5047&alloc_id=10808&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
