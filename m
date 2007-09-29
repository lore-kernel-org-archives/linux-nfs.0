From: "Steinar H. Gunderson" <sesse@debian.org>
Subject: Re: [PATCH] Properly ignore quota options
Date: Sat, 29 Sep 2007 15:08:59 +0200
Message-ID: <20070929130859.GA32536@uio.no>
References: <20070718170931.GA30174@uio.no>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Ibc43-0000Y7-LR
	for nfs@lists.sourceforge.net; Sat, 29 Sep 2007 06:08:59 -0700
Received: from cassarossa.samfundet.no ([129.241.93.19] ident=Debian-exim)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1Ibc48-0002sC-Dy
	for nfs@lists.sourceforge.net; Sat, 29 Sep 2007 06:09:04 -0700
Received: from trofast.ipv6.sesse.net ([2001:700:300:1803:20e:cff:fe36:a766]
	helo=trofast.sesse.net) by cassarossa.samfundet.no with esmtps
	(TLS-1.0:RSA_AES_256_CBC_SHA1:32) (Exim 4.63)
	(envelope-from <sesse@samfundet.no>) id 1Ibc43-0007Hj-W4
	for nfs@lists.sourceforge.net; Sat, 29 Sep 2007 15:09:00 +0200
Received: from root by trofast.sesse.net with local (Exim 4.67)
	(envelope-from <sesse@samfundet.no>) id 1Ibc43-0008TX-EU
	for nfs@lists.sourceforge.net; Sat, 29 Sep 2007 15:08:59 +0200
In-Reply-To: <20070718170931.GA30174@uio.no>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

On Wed, Jul 18, 2007 at 07:09:31PM +0200, Steinar H. Gunderson wrote:
> The mount(5) man page states that the noquota, quota, usrquota and
> grpquota options are ignored. (They are, however, used by the quota
> tools, so having them in fstab can be useful.) Make mount.nfs ignore
> them properly, matching the man page. There are a few aliases (like
> usrjquota) that are parsed by quota, but as these are not documented
> nor seem to be widely used, they are not included.
> 
> Signed-off-by: Steinar H. Gunderson <sesse@debian.org>

This patch was also dropped on the floor. Neil?

/* Steinar */ 
-- 
Homepage: http://www.sesse.net/

-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2005.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
