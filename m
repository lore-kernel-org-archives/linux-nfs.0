From: linuxkernel@arcor.de
Subject: Re: several oopses of nfsd in 2.6.16.29
Date: Fri, 1 Dec 2006 11:59:13 +0100 (CET)
Message-ID: <3606592.1164970753868.JavaMail.ngmail@webmail13>
References: <139134.1164970331572.JavaMail.ngmail@webmail13>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Gq678-0003Z0-7D
	for nfs@lists.sourceforge.net; Fri, 01 Dec 2006 02:59:30 -0800
Received: from mail-in-07.arcor-online.net ([151.189.21.47])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1Gq678-0003hM-CE
	for nfs@lists.sourceforge.net; Fri, 01 Dec 2006 02:59:31 -0800
Received: from mail-in-01-z2.arcor-online.net (mail-in-05-z2.arcor-online.net
	[151.189.8.17])
	by mail-in-07.arcor-online.net (Postfix) with ESMTP id A2FE91F5F5F
	for <nfs@lists.sourceforge.net>; Fri,  1 Dec 2006 11:59:27 +0100 (CET)
Received: from mail-in-02.arcor-online.net (mail-in-02.arcor-online.net
	[151.189.21.42])
	by mail-in-01-z2.arcor-online.net (Postfix) with ESMTP id 9641F2DABC0
	for <nfs@lists.sourceforge.net>; Fri,  1 Dec 2006 11:59:27 +0100 (CET)
Received: from webmail13 (webmail13.arcor-online.net [151.189.8.66])
	by mail-in-02.arcor-online.net (Postfix) with ESMTP id D2E0227FEF
	for <nfs@lists.sourceforge.net>; Fri,  1 Dec 2006 11:59:26 +0100 (CET)
To: nfs@lists.sourceforge.net
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

 
(forgot to cc to the list)

----- Original Nachricht ----
Von:     linuxkernel@arcor.de
An:      okir@suse.de
Datum:   01.12.2006 11:52
Betreff: Re: [NFS] several oopses of nfsd in 2.6.16.29

 Hello,

thanks for your reply!

> On Fri, Dec 01, 2006 at 09:06:35AM +0100, linuxkernel@arcor.de wrote:
> > it happened again, but this time without /proc/fs/nfsd mounted.  This is
> getting on my nerves.
> > Please see attached the oopses.  Now I switched to 2.6.16.33.
> 
> It doesn't look like this is necessarily nfsd's fault; this looks more

ok, I only saw "Process: nfsd" in the oops, that's why I report it here.

> like memory corruption to me.  Something stomped on either the inode or
> (less likely) the inode->ops of some file.

possible but oopses also occured on the other machine, although
they weren't logged, but okay I'll run a memtest.    And the filesystems
of these machines are synced via rsync, not via drbd, so the inodes
are different.

> 
> I'd suggest building the kernel with slab debugging enabled and
> see whether that turns up anything useful.

do I have to do anything special besides building with CONFIG_DEBUG_SLAB?

> 
> There's a remote chance this is related to ACLs though, as the
> first crash is in an ACL call. Are you using ACLs at all?

yes, they are mounted with acl, but it is not used at the moment,
I don't even think there is any file with acls set.

Thanks again,

      Peter


-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys - and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
