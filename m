From: miyoshi@hpc.bs1.fc.nec.co.jp
Subject: getcwd() returns wrong pathname
Date: Tue, 03 Dec 2002 11:45:45 +0900
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20021203114545W.miyoshi@hpc.bs1.fc.nec.co.jp>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from tyo202.gate.nec.co.jp ([202.32.8.202])
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18J33R-0006Du-00
	for <nfs@lists.sourceforge.net>; Mon, 02 Dec 2002 18:44:57 -0800
Received: from mailgate4.nec.co.jp ([10.7.69.195])
	by TYO202.gate.nec.co.jp (8.11.6/3.7W01080315) with ESMTP id gB32ill08184
	for <nfs@lists.sourceforge.net>; Tue, 3 Dec 2002 11:44:47 +0900 (JST)
Received: from mailsv.nec.co.jp (mailgate51.nec.co.jp [10.7.69.196]) by mailgate4.nec.co.jp (8.11.6/3.7W-MAILGATE-NEC) with ESMTP
	id gB32ijx01348 for <nfs@lists.sourceforge.net>; Tue, 3 Dec 2002 11:44:45 +0900 (JST)
Received: from mailsv.bs1.fc.nec.co.jp (venus.d2.bs1.fc.nec.co.jp [10.34.77.164]) by mailsv.nec.co.jp (8.11.6/3.7W-MAILSV-NEC) with ESMTP
	id gB32hBm15118 for <nfs@lists.sourceforge.net>; Tue, 3 Dec 2002 11:44:44 +0900 (JST)
Received: from localhost (pingu.hpc.bs1.fc.nec.co.jp [10.34.77.220])
	by mailsv.bs1.fc.nec.co.jp (8.12.0/3.7W-HPC5.2F(mailsv)01041614) with ESMTP id gB32ZpnK001887
	for <nfs@lists.sourceforge.net>; Tue, 3 Dec 2002 11:35:52 +0900 (JST)
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


Hello,

I'm having problems with linux NFS. Here is my situation.

When mounting remote linux NFS filesystem to /mnt/xxx/yyy,
pwd or getcwd() sometimes returns imcomplete pathname.
We are using linux kernel 2.4.17.

% mount linuxserver:/mnt/xxx /mnt/xxx
% cd /mnt/xxx/yyy
% pwd
/xxx/yyy       <--- should be /mnt/xxx/yyy

Is there any ideas or fixes?
I'll be very gratefull to any suggestion.

Regards,
--
MIYOSHI Kazuto <miyoshi@hpc.bs1.fc.nec.co.jp>
 HPC Operating System Group, 1st Computers Software Division,
 Computers Software Operations Unit, NEC Solutions.


-------------------------------------------------------
This SF.net email is sponsored by: Get the new Palm Tungsten T 
handheld. Power & Color in a compact size! 
http://ads.sourceforge.net/cgi-bin/redirect.pl?palm0002en
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
