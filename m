From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH] nfs4: fix segfult on errors returned that are < -1000
Date: Mon, 13 Mar 2006 11:12:52 -0500
Message-ID: <1142266372.8017.6.camel@lade.trondhjem.org>
References: <20060313160503.GA27685@hmsreliant.homelinux.net>
Mime-Version: 1.0
Content-Type: text/plain
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1FIpfU-00076X-V0
	for nfs@lists.sourceforge.net; Mon, 13 Mar 2006 08:13:12 -0800
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1FIpfU-0000TS-Fb
	for nfs@lists.sourceforge.net; Mon, 13 Mar 2006 08:13:12 -0800
To: Neil Horman <nhorman@tuxdriver.com>
In-Reply-To: <20060313160503.GA27685@hmsreliant.homelinux.net>
Sender: nfs-admin@lists.sourceforge.net
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

On Mon, 2006-03-13 at 11:05 -0500, Neil Horman wrote:
> Hey all-
> 	This was reported to me last week.  If you attempt to mount an nfsv4
> share, and the mount syscall for that filesystem returns an error code that is
> less than -1000 (of which NFS4 has many), The IS_ERR macro function will
> erroniously return false, and do_kern_mount will pass the error code to called
> functions as though it were a valid pointer.  This patch fixes up the missed
> point in nfs4_get_sb that allows such an error to propogate to do_kern_mount.

Nice catch! I will apply.

Thanks,
  Trond



-------------------------------------------------------
This SF.Net email is sponsored by xPML, a groundbreaking scripting language
that extends applications into web and mobile media. Attend the live webcast
and join the prime developer group breaking into this new coding territory!
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=110944&bid=241720&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
