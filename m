From: Marian Eichholz <marian.eichholz@freenet-ag.de>
Subject: strange kernel freeze during "exportfs -a" w/2.6.9-rc1
Date: Wed, 6 Oct 2004 08:31:45 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20041006063145.GA23464@urmel.freenet-ag.de>
Reply-To: marian.eichholz@freenet-ag.de
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CF5L5-0003UH-BW
	for nfs@lists.sourceforge.net; Tue, 05 Oct 2004 23:31:51 -0700
Received: from mout1.freenet.de ([194.97.50.132])
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1CF5L1-00066a-TK
	for nfs@lists.sourceforge.net; Tue, 05 Oct 2004 23:31:51 -0700
Received: from [194.97.55.147] (helo=mx4.freenet.de)
	by mout1.freenet.de with esmtpa (Exim 4.42)
	id 1CF5Kz-0001qt-RY
	for nfs@lists.sourceforge.net; Wed, 06 Oct 2004 08:31:45 +0200
To: nfs@lists.sourceforge.net
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

Hello all, hi Neil, hi Olaf,

we recently found a strange bug in the recent 2.6 kernels
that freezes the whole kernel (down to even no response to
the Magic SysRq keys). And in fact sticks us to the 2.4
series we want to get rid of :)

This happens during "exportfs -a" when the following
sequence commences (tested by manual command execution,
with some seconds betweeen the commands):

	rpc.nfsd 128
	rpc.mountd
	rpc.statd
	exportfs -a

We cannot reproduce it on a "normal" machine.

The most recently tested kernel is a 2.6.9-rc1 (since each
test breaks the production service). exportfs is 1.0.6.

The particular server is the NFS file repository for a high
volume FTP cluster, thus beeing requested by the still
online 4 ftp backend servers *heavily*.

It has 2 Fast Ethernet ports in *bonding* mode (in peak hours they can
be filled with ease).

Probably it is this combinations that makes a problem.

There are only two directories being exported to 5 machines
each with really standard options.

The freeze can be reproduced even when the exported
directories are empty (no mount of the *some* GB to be
checked afterwards, nice for testing :)) and even with "strace
exportfs -a".

strace stops during the call of

	nfsservctl(0x1,...,0)

right after reading the still empty /proc/fs/nfs/exports.

I just hope that something helps.
If we can run a special test or provide suitable
information about the system, please let me know.

Thank You in advance, probably it's something easily fixed.

Yours sincerely,
- Marian


-------------------------------------------------------
This SF.net email is sponsored by: IT Product Guide on ITManagersJournal
Use IT products in your business? Tell us what you think of them. Give us
Your Opinions, Get Free ThinkGeek Gift Certificates! Click to find out more
http://productguide.itmanagersjournal.com/guidepromo.tmpl
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
