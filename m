From: Paul Jakma <paul@clubi.ie>
Subject: gss/krb doesnt work with nfsv3?
Date: Wed, 2 Jun 2004 17:24:19 +0100 (IST)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.LNX.4.58.0406021704290.3160@fogarty.jakma.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BVYXQ-0002pm-EV
	for nfs@lists.sourceforge.net; Wed, 02 Jun 2004 09:24:24 -0700
Received: from hibernia.jakma.org ([212.17.55.49])
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.30)
	id 1BVYXP-0007S2-LT
	for nfs@lists.sourceforge.net; Wed, 02 Jun 2004 09:24:23 -0700
Received: from fogarty.jakma.org (fogarty.jakma.org [192.168.0.4])
	by hibernia.jakma.org (8.12.11/8.12.11) with ESMTP id i52GOaUX027195
	for <nfs@lists.sourceforge.net>; Wed, 2 Jun 2004 17:24:37 +0100
To: Linux NFS <nfs@lists.sourceforge.net>
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

Hi,

I can not get gss/krb exports to work with NFSv3:

# exportfs -v | grep test ; showmount -e | grep test
/exports/test   gss/krb5(rw,wdelay,no_root_squash)
# /etc/init.d/rpcgssd status
rpc.gssd (pid 1556) is running...
# /etc/init.d/rpcsvcgssd status
rpc.svcgssd (pid 26833) is running...

If I try to mount from a client, I get the following:

# mount -o sec=krb5 hibernia:/exports/test /mnt/backup/
mount: hibernia:/exports/test failed, reason given by server: 
Permission denied

And in the server logs:

Jun  2 17:08:15 hibernia rpc.mountd: refused mount request from 
fogarty.jakma.org for /exports/test (/): not exported

It works if i export with fsid=0 and mount with nfs4 sec=on the 
client. Is krb5 supposed to work with NFSv3?

regards,
-- 
Paul Jakma	paul@clubi.ie	paul@jakma.org	Key ID: 64A2FF6A
	warning: do not ever send email to spam@dishone.st
Fortune:
Before Xerox, five carbons were the maximum extension of anybody's ego.


-------------------------------------------------------
This SF.Net email is sponsored by the new InstallShield X.
