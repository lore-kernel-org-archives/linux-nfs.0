From: howard chen <howachen@gmail.com>
Subject: [NFS] Advise on NFS performance tunning.
Date: Mon, 9 Feb 2009 12:40:04 +0800
Message-ID: <b66ddc900902082040m24aef720ybab2fd6646377246@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfs@lists.sourceforge.net
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from neil.brown.name ([220.233.11.133]:51915 "EHLO neil.brown.name"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753833AbZBIEka (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 8 Feb 2009 23:40:30 -0500
Received: from brown by neil.brown.name with local (Exim 4.69)
	(envelope-from <nfs-bounces@lists.sourceforge.net>)
	id 1LWNwa-0003Fx-IH
	for linux-nfs@vger.kernel.org; Mon, 09 Feb 2009 15:40:28 +1100
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hello, I have a busy web server, in which all HTML files are store in
a centralized NFS server.

I experienced the NFS is slow, i.e.  %wa is high in top command


My client's uptime is 144 days, has the following info by nfsstat:

==================================
calls      retrans    authrefrsh
1084310678   2347363    0


Client nfs v3:
null         getattr      setattr      lookup       access       readlink
0         0% 512606060 47% 26314540  2% 5826894   0% 143270988 13% 15        0%
read         write        create       mkdir        symlink      mknod
379396607 34% 15794239  1% 496509    0% 415960    0% 0         0% 0         0%
remove       rmdir        rename       link         readdir      readdirplus
25743     0% 153       0% 321       0% 0         0% 543       0% 697       0%
fsstat       fsinfo       pathconf     commit
6935      0% 4         0% 0         0% 154469    0%

==================================

As you can see the getattr is quite high, but my HTML files will
change every minutes.
And there are so many HTML files in NFS server in fact.


Are there any way I can tune my NFS setup?

e.g.

1. adding more memory to server?
2. adding more memory to client?
3. upgrade to NFS v4?
...

NFS mount option:
async,noatime,noexec,nosuid,hard,intr,udp,retry=3,rsize=32768,wsize=32768
NFS version: 3

Thanks.

------------------------------------------------------------------------------
Create and Deploy Rich Internet Apps outside the browser with Adobe(R)AIR(TM)
software. With Adobe AIR, Ajax developers can use existing skills and code to
build responsive, highly engaging applications that combine the power of local
resources and data with the reach of the web. Download the Adobe AIR SDK and
Ajax docs to start building applications today-http://p.sf.net/sfu/adobe-com
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
_______________________________________________
Please note that nfs@lists.sourceforge.net is being discontinued.
Please subscribe to linux-nfs@vger.kernel.org instead.
    http://vger.kernel.org/vger-lists.html#linux-nfs

