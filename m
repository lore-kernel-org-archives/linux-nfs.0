From: Gopal Santhanam <gopal@nerur.com>
Subject: NFSv3 + Kerberos + x86_64 (Fedora Core 4)
Date: Wed, 1 Mar 2006 07:57:18 -0800
Message-ID: <200603010757.18563.gopal@nerur.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1FEThc-0007Jo-KV
	for nfs@lists.sourceforge.net; Wed, 01 Mar 2006 07:57:24 -0800
Received: from smtp1.stanford.edu ([171.67.16.123])
	by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1FEThZ-0002vN-Qk
	for nfs@lists.sourceforge.net; Wed, 01 Mar 2006 07:57:24 -0800
Received: from shruthi.stanford.edu (shruthi.Stanford.EDU [128.12.190.74])
	by smtp1.Stanford.EDU (8.12.11/8.12.11) with ESMTP id k21FvJDi027018
	for <nfs@lists.sourceforge.net>; Wed, 1 Mar 2006 07:57:19 -0800
To: nfs@lists.sourceforge.net
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

Hi all,

I have been using FC4's kernel-2.6.15-1.1831 on both
i686 and x86_64 architecture machines.

I want to use NFSv3 with Kerberos. =A0This works fine
on i686 with the aforementioned FC4 kernel. =A0I am
able to do the following:

1) Setup NFS server with kerberos

2) Mount on NFS client with -o sec=3Dkrb5.


Now, if I have (1) on i686 and do (2) on x86_64, things just=20
break:

{root@x86_64client:3:~} mount -o sec=3Dkrb5=20
server:/export/test /mnt
{root@x86_64client:4:~} ls -al /mnt
ls: /mnt: Broken pipe



The clients are setup exactly the same
(both have /etc/krb5.keytab, /etc/idmapd.conf).=20
They are both running rpc.idmapd and rpc.gssd.

An important thing to mention is that rpc.gssd is still running
after the mount command but then has vanished (crashed?) after=20
the ls.

This has got to be a known problem. =A0How do I fix it?

Thanks,
Gopal


p.s. I have not tried the latest patches from CITI, but that's
always a royal pain in the ass (see my recent message about
compile errors with the latest patches). =A0For example, even
the last version that I compiled
(linux-2.6.16-rc1-CITI_NFS4_ALL-4.diff) was acting strangely
on i686.


-------------------------------------------------------
This SF.Net email is sponsored by xPML, a groundbreaking scripting language
that extends applications into web and mobile media. Attend the live webcast
and join the prime developer group breaking into this new coding territory!
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=110944&bid=241720&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
