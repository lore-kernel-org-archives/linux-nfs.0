From: "Gareth" <gareth@bim7.com>
Subject: Premission denied
Date: Wed, 29 Oct 2003 09:59:58 -0000 (GMT)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <10334.62.49.205.2.1067421598.squirrel@squirrelmail.bim7.com>
Mime-Version: 1.0
Content-Type: text/plain;charset=iso-8859-1
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 1AEn7T-0005vV-00
	for <nfs@lists.sourceforge.net>; Wed, 29 Oct 2003 02:00:03 -0800
Received: from bim7dsl.plus.com ([81.174.146.28] helo=mailgate.bim7.com)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.24)
	id 1AEn7S-0001Mu-3J
	for nfs@lists.sourceforge.net; Wed, 29 Oct 2003 02:00:02 -0800
Received: from squirrelmail.bim7.com (unknown [127.0.0.1])
	by mailgate.bim7.com (Postfix) with SMTP id 269CA102A7
	for <nfs@lists.sourceforge.net>; Wed, 29 Oct 2003 09:59:58 +0000 (GMT)
To: nfs@lists.sourceforge.net
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

Hi Guys

I'm trying to install Debian on a Cobalt Raq2, this is installed using NFS
running on a remote server, but am having problems with NFS. I can't even
mount an NFS drive locally.

I'm running RH8.0, and nfs-utils 1.0.6.

I've got the following entries in my /etc/export file

/nfsroot        192.168.17.0/255.255.255.0(ro)
/mnt/nfsroot    192.168.17.0/255.255.255.0(ro)

My hosts.allow and hosts.deny are completely empty, I assume this allows
everyone and anyone access. I have also disabled my firewall, iptables
during testing.

When I run 'showmount -e localhost', nothing is returned :-(

I am running 'exportfs -ra' after making changes to /etc/exports.

Running 'rpcinfo -p' produces the following....

   program vers proto   port
    100000    2   tcp    111  portmapper
    100000    2   udp    111  portmapper
    100024    1   udp  32768  status
    100024    1   tcp  32768  status
    391002    2   tcp  32769  sgi_fam
    100011    1   udp    849  rquotad
    100011    2   udp    849  rquotad
    100003    2   udp   2049  nfs
    100003    3   udp   2049  nfs
    100021    1   udp  32788  nlockmgr
    100021    3   udp  32788  nlockmgr
    100021    4   udp  32788  nlockmgr
    100005    1   udp    867  mountd
    100005    1   tcp    870  mountd
    100005    2   udp    867  mountd
    100005    2   tcp    870  mountd
    100005    3   udp    867  mountd
    100005    3   tcp    870  mountd

When I try to mount an NFS drive (even locally), I get the following error
on the screen...

# mount paris:/nfsroot /tmp/test
mount: paris:/nfsroot failed, reason given by server: Permission denied

In /var/log/messages, I get...

Oct 29 09:25:44 paris rpc.mountd: Fake hostname paris.bim for 192.168.17.4
- forward lookup doesn't match reverse
Oct 29 09:25:44 paris rpc.mountd: refused mount request from 192.168.17.4
for /nfsroot (/): no export entry
Oct 29 09:29:09 paris rpc.mountd: export request from 127.0.0.1
Oct 29 09:39:37 paris rpc.mountd: refused mount request from paris.bim for
/nfsroot (/): no export entry

Someone at work suggested its a reverse DNS problem... but running
nslookup hostname returns my IP address, and vice versa.

Sorry this post is long... has anyone got any useful suggestions?



Gareth


-------------------------------------------------------
This SF.net email is sponsored by: SF.net Giveback Program.
Does SourceForge.net help you be more productive?  Does it
help you create better code?   SHARE THE LOVE, and help us help
YOU!  Click Here: http://sourceforge.net/donate/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
