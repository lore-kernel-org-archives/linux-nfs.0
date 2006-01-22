From: Piers Kittel <ed@biased.org>
Subject: Mounting DVDs via NFS problem
Date: Sun, 22 Jan 2006 17:52:46 +0000
Message-ID: <43D3C66E.4060509@biased.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1F0jOZ-0003xb-Eu
	for nfs@lists.sourceforge.net; Sun, 22 Jan 2006 09:52:55 -0800
Received: from englishdude.plus.com ([81.174.246.186] helo=destiny.biased.org)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1F0jOY-0003tx-Sh
	for nfs@lists.sourceforge.net; Sun, 22 Jan 2006 09:52:55 -0800
Received: from akane.10sca.intranet ([192.168.1.17])
	by destiny.biased.org with esmtp (Exim 4.50)
	id 1F0jOP-0005vy-Kl
	for nfs@lists.sourceforge.net; Sun, 22 Jan 2006 17:52:45 +0000
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

Hello all,

Am trying to mount a DVD drive via NFS and am having problems.  For
note, 192.168.1.2 (hostname - destiny) is the client and 192.168.1.15
(hostname - mythtv) is the server.

I have this in my /etc/exports:

/media/cdrom0 192.168.1.2(ro,sync)

and 192.168.1.2 is in the /etc/hosts.allow.

If the DVD is not mounted, it works perfectly fine:

destiny:/mnt# mount mythtv:/media/cdrom0 /mnt/mythtv
destiny:/mnt# df
Filesystem           1K-blocks      Used Available Use% Mounted on
<snip>
mythtv:/media/cdrom0   1829192   1547128    184472  90% /mnt/mythtv
destiny:/mnt#

If I unmount the above, and then mount the DVD on mythtv:

mythtv:/home/piers# mount /cdrom
mythtv:/home/piers#

and try again on destiny, I get:

destiny:/# mount mythtv:/media/cdrom0 /mnt/mythtv
mount: mythtv:/media/cdrom0 failed, reason given by server: Permission
denied
destiny:/#

and in the logs, I get:

Jan 21 21:57:08 localhost kernel: UDF-fs INFO UDF 0.9.8.1 (2004/29/09)
Mounting volume 'FIREFLY_D3', timestamp 2003/09/08 20:08 (1000)
Jan 21 21:57:39 localhost rpc.mountd: authenticated mount request from
destiny.10sca.intranet:923 for /media/cdrom0 (/media/cdrom0)
Jan 21 21:57:39 localhost rpc.mountd: getfh failed: Operation not permitted

I've googled for a long time with the last message but I can't find any
help anywhere.

I've tried this on my 2 Macs but had the exact same problem:

Jan 21 20:34:55 localhost rpc.mountd: authenticated mount request from
ukyo.10sca.intranet:982 for /media/cdrom0 (/media/cdrom0)
Jan 21 20:34:55 localhost rpc.mountd: getfh failed: Operation not permitted
Jan 21 21:29:59 localhost rpc.mountd: authenticated mount request from
akane.10sca.intranet:972 for /media/cdrom0 (/media/cdrom0)
Jan 21 21:29:59 localhost rpc.mountd: getfh failed: Operation not permitted

I'm hoping you guys can tell me what I'm doing wrong here?

Thanks very much in advance!

Cheers - Piers


-------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc. Do you grep through log files
for problems?  Stop!  Download the new AJAX search engine that makes
searching your log files as easy as surfing the  web.  DOWNLOAD SPLUNK!
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=103432&bid=230486&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
