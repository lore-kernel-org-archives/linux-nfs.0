From: =?UTF-8?Q?Piotr_Kandziora?= <raveen@tlen.pl>
Subject: (no subject)
Date: Thu, 02 Aug 2007 09:24:28 +0200
Message-ID: <6efae230.53ea6361.46b186ac.d4e1b@o2.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IGV2s-0006Oc-Hm
	for nfs@lists.sourceforge.net; Thu, 02 Aug 2007 00:24:30 -0700
Received: from rekin23.go2.pl ([193.17.41.16])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IGV2v-0002RB-5y
	for nfs@lists.sourceforge.net; Thu, 02 Aug 2007 00:24:34 -0700
Received: from o2.pl (unknown [10.0.0.17])
	by rekin23.go2.pl (Postfix) with SMTP id 03B4212885B
	for <nfs@lists.sourceforge.net>; Thu,  2 Aug 2007 09:24:29 +0200 (CEST)
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

Server NFS: 192.168.0.166
client 1: 192.168.0.169
client 2: 192.168.0.183

showmount output on server:
# showmount -a
All mount points on hostname:
*:/aa
*:/bb
192.168.0.169:*
192.168.0.183:*

# cat /var/lib/nfs/rmtab
192.168.0.183:*:0x00000001
*:/aa:0x00000002
192.168.0.169:*:0x00000002
*:/bb:0x00000002

client 1:
# mount|grep 166
192.168.0.166:/aa on /mnt/tmp0 type nfs (rw,addr=192.168.0.166)
192.168.0.166:/bb on /mnt/tmp1 type nfs (rw,addr=192.168.0.166)

client 2:
# mount|grep 166
192.168.0.166:/aa on /mnt/tmp0 type nfs
(rw,vers=3,rsize=32768,wsize=32768,hard,proto=udp,timeo=7,retrans=3,addr=192.168.0.166)

On client 1 there are mounted two shares (aa and bb), on client 2 only one share (aa).

My questions are:

How to get information about mounted shares on concrete clients from showmount or other command?

What is meaning of asterisks in showmount output?




-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
