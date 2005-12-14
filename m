From: "=?GB2312?Q?=B3=C2=BB=B6?=" <huanchen@ncic.ac.cn>
Subject: performance problem on nfs in kernel v2.4 and v2.6
Date: Wed, 14 Dec 2005 10:14:47 +0800
Message-ID: <20051214021641.0C18CFB045@gatekeeper.ncic.ac.cn>
Mime-Version: 1.0
Content-Type: text/plain;
      charset="GB2312"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1EmMAf-0002Lx-Pi
	for nfs@lists.sourceforge.net; Tue, 13 Dec 2005 18:15:09 -0800
Received: from gatekeeper.ncic.ac.cn ([159.226.41.188] helo=ncic.ac.cn)
	by mail.sourceforge.net with smtp (Exim 4.44)
	id 1EmMAd-0004kM-3U
	for nfs@lists.sourceforge.net; Tue, 13 Dec 2005 18:15:09 -0800
Received: from chenhuan (trumpet.ncic.ac.cn [159.226.41.129])
	by gatekeeper.ncic.ac.cn (Postfix) with SMTP id 0C18CFB045
	for <nfs@lists.sourceforge.net>; Wed, 14 Dec 2005 10:16:41 +0800 (CST)
To: nfs@lists.sourceforge.net <nfs@lists.sourceforge.net>
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

nfs:

=09
=09I did some test on nfs in linux kernel v2.6 ,but there are some=
 problem i can't solve.
=09I need your help!

=09I run iozone on nfs in kernel v2.4.21 and v2.6.11.12 ,the test=
 result is as follows:
=09v2.4.21:    write performance 106MB/s   (wsize,rsize=3D8192)
=09v2.6.11.12: write performance 52MB/s ;  (wsize,rsize=3D32768)

=09the iozone test command I use is : 
=09=09iozone -c -e -f /mnt/nfs/file1 -s 1g -r 2m -i 0 -w

=09My question is why the performance is lower when using v2.6?

=09The test platform is :
=09=09client: 1G memory,
=09=09server: 4G memory, 146G disk. 2cpu.
=09=09net: 1000Mb

=09When i use the following command to chechk why v2.6 takes much=
 more time, I found that the fsync operations takes much more=
 time. the command is:
=09strace -o result -T write, close, fsync ./iozone -c -e -f=
 /mnt/nfs/file1 -s 1g -r 2m -i 0 -w
=09the result of this command is that the time of write is=
 6(ms),while the time of sync before close is 6 (s).

=09So what is wrong? how can i see performance improvement of nfs=
 in v2.6. Is there any key value I can tune ?    Or the problem=
 relates to the removal of flushd while introducing  pdflush in=
 client memory management ?

=09Thank you!  Waiting for your reply!


------------------------------------------------------------
National Research Center for Intelligent Computing Systems
Insitute of Computing Technology
Chinese Academy of Sciences=A1=A1=A1=A1=A1=A1
------------------------------------------------------------
=09=09

=A1=A1=A1=A1=A1=A1=A1=A1=A1=A1=A1=A1=A1=A1=A1=A1
=A1=A1=A1=A1=A1=A1=A1=A1=A1=A1=A1=A1=A1=A1=A1=A1huanchen@ncic.ac.cn
=A1=A1=A1=A1=A1=A1=A1=A1=A1=A1=A1=A1=A1=A1=A1=A1=A1=A1=A1=A12005-12-14




-------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc. Do you grep through log files
for problems?  Stop!  Download the new AJAX search engine that makes
searching your log files as easy as surfing the  web.  DOWNLOAD SPLUNK!
http://ads.osdn.com/?ad_id=7637&alloc_id=16865&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
