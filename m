From: pascal <pascal@deception.nl>
Subject: Unable to mount nfs share
Date: Sat, 10 Dec 2005 04:24:40 +0100
Message-ID: <439A4A78.6070807@deception.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1EkvLs-0005JG-9A
	for nfs@lists.sourceforge.net; Fri, 09 Dec 2005 19:24:48 -0800
Received: from [84.246.52.99] (helo=mail.deception.nl)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1EkvLr-0007g7-S4
	for nfs@lists.sourceforge.net; Fri, 09 Dec 2005 19:24:48 -0800
Received: from [192.168.0.21] (helo=[192.168.0.21])
	by router with esmtp (Exim 4.54)
	id 1EkvLk-00078O-Mp
	for nfs@lists.sourceforge.net; Sat, 10 Dec 2005 04:24:40 +0100
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

I'm unable to mount a nfs share. I've followed the howto from
nfs.sourceforge.
Error: 
mount: permission denied.
Is there anything else I have to think of in Debian? Or am I just plain
stupid?
Can't get it to work.

On the client:

rpcinfo -p 192.168.0.21 gives me:
programma versie protocol poort
    100000    2   tcp    111  portmapper
    100000    2   udp    111  portmapper
    100003    2   udp   2049  nfs
    100003    3   udp   2049  nfs
    100021    1   udp  32768  nlockmgr
    100021    3   udp  32768  nlockmgr
    100005    1   udp   1014  mountd
    100005    1   tcp   1017  mountd
    391002    2   tcp    625  sgi_fam
    100024    1   udp    633  status
    100024    1   tcp    636  status

On the server:

cat /proc/fs/nfs/exp*
# Version 1.1
# Path Client(Flags) # IPs
/data   *(rw,no_root_squash,sync,wdelay)

syslog:
Dec 10 02:29:58 mainframe mountd[5502]: authenticated mount request from
router.deception.lan:819 for /data (/data)

I'm trying to mount as root, since I haven't added the share to fstab yet.

Thx.



-------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc. Do you grep through log files
for problems?  Stop!  Download the new AJAX search engine that makes
searching your log files as easy as surfing the  web.  DOWNLOAD SPLUNK!
http://ads.osdn.com/?ad_id=7637&alloc_id=16865&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
