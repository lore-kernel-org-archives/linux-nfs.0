From: "Dennis, Richard" <Richard.Dennis@lehman.com>
Subject: NFS insecure ports
Date: Wed, 25 Jun 2003 11:42:55 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <0073ECCF4F99D611810B0002A58F26560EB3153C@exnyc03.lehman.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from mail-ny2.bigfish.com ([63.161.60.93] helo=mail5-ny2-R.bigfish.com)
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19VCQX-0005I9-00
	for <nfs@lists.sourceforge.net>; Wed, 25 Jun 2003 08:43:17 -0700
Received: from mail5-ny2.bigfish.com (localhost.localdomain [127.0.0.1])
	by mail5-ny2-R.bigfish.com (Postfix) with ESMTP id 0C6FC90158
	for <nfs@lists.sourceforge.net>; Wed, 25 Jun 2003 15:43:11 +0000 (UCT)
Received: from extrelay2.lehman.com (extrelay2.Lehman.COM [192.147.58.145])
	by mail5-ny2.bigfish.com (Postfix) with ESMTP id F0AB390158
	for <nfs@lists.sourceforge.net>; Wed, 25 Jun 2003 15:43:10 +0000 (UCT)
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


When does a Linux NFS tcp client determine to use insecure ports?  I've
witnessed that sometimes it has used high ports.  But I just put together a
test where I had netcat listening on every privileged port, and then tried
to mount a tcp export from a Solaris server but got this message:

# mount -t nfs -orw,hard,nosuid,intr,nfsvers=3,vers=3,proto=tcp
solarisserver:/local/0/opt /opt/foobar
nfs bindresvport: Address already in use
#

So I'm confused as to how to reproduce the behavior that I saw where
"netstat -an|grep solarisserver" produced:
# netstat -a | grep solarisserver
  tcp        0      0 linuxclient:49479 solarisserver:nfs ESTABLISHED
#

------------------------------------------------------------------------------
This message is intended only for the personal and confidential use of the designated recipient(s) named above.  If you are not the intended recipient of this message you are hereby notified that any review, dissemination, distribution or copying of this message is strictly prohibited.  This communication is for information purposes only and should not be regarded as an offer to sell or as a solicitation of an offer to buy any financial product, an official confirmation of any transaction, or as an official statement of Lehman Brothers.  Email transmission cannot be guaranteed to be secure or error-free.  Therefore, we do not represent that this information is complete or accurate and it should not be relied upon as such.  All information is subject to change without notice.




-------------------------------------------------------
This SF.Net email is sponsored by: INetU
Attention Web Developers & Consultants: Become An INetU Hosting Partner.
Refer Dedicated Servers. We Manage Them. You Get 10% Monthly Commission!
INetU Dedicated Managed Hosting http://www.inetu.net/partner/index.php
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
