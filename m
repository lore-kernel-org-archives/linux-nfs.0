From: Marco.Schwarz@Freudenberg.de
Subject: Update: URGENT: Problems with NFS-Root-Clients
Date: Wed, 28 Aug 2002 10:49:20 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <95AF67BA7F70D511829B0002A551737001C9C6@faw-e01.faw.freudenberg.de>
Mime-Version: 1.0
Content-Type: text/plain
Cc: bogdan.costescu@iwr.uni-heidelberg.de
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from [153.95.95.71] (helo=itnts96.freudenberg.de)
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17jyXS-0006yM-00
	for <nfs@lists.sourceforge.net>; Wed, 28 Aug 2002 01:50:58 -0700
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
List-Archive: <http://www.geocrawler.com/redir-sf.php3?list=nfs>

I did some more testing and here are some things I found:

This particular server has 2 EEpro 100 NICs, and the problem seems to be
with clients on the 192.x adresses only. I already interchanged adresses
between ETH0/ETH1, so it does not seem to be a hardware problem with the
NIC. Here is my configuration which I use on the server:

ETH0: 153.95.240.235
ETH1: 192.168.0.235

Boot Params for 153.x from /tftpboot/pxelinux.cfg/default:

DEFAULT netboot root=/dev/nfs rw nfsaddrs=153.95.169.113 vga=0x317


Boot Params for 192.x from /tftpboot/pxelinux.cfg/C0:

DEFAULT netboot root=/dev/nfs rw nfsaddrs=192.168.0.235 vga=0x305


Here is part of my /etc/bootptab (I am using bootpd):

#
global.prof:\
  :sm=255.255.255.0:\
  :gw=153.95.240.254:\
  :ht=ethernet:\
  :bf=pxelinux.0:

#
local.prof:\
  :sm=255.255.255.0:\
  :gw=192.168.0.235:\
  :ht=ethernet:\
  :bf=pxelinux.0:

# One of the 192.x clients
qsclient01.fds:\
    :hd=/tftpboot:\
    :tc=local.prof:\
    :ha=0002B3330B7F:\
    :ip=192.168.0.191:\
    :sa=192.168.0.235:\
    :rp=/netclients/192.168.0.191,rsize=4096,wsize=4096:

# One of the 153.x clients
lvobw01.fds:\
    :hd=/tftpboot:\
    :tc=global.prof:\
    :ha=0002B3284915:\
    :ip=153.95.240.192:\
    :rp=/netclients/153.95.240.192,rsize=4096,wsize=4096:

Thanks for the help,
Marco


-------------------------------------------------------
This sf.net email is sponsored by: Jabber - The world's fastest growing 
real-time communications platform! Don't just IM. Build it in! 
http://www.jabber.com/osdn/xim
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
