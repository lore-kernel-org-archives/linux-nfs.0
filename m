From: Ed Swierk <eswierk@kealia.com>
Subject: Determining version, current block size, setting default
Date: Wed, 19 Mar 2003 17:16:52 -0800
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <3E791684.4070403@kealia.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from [216.101.126.244] (helo=hawaii.kealia.com)
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18vofr-0000T4-00
	for <nfs@lists.sourceforge.net>; Wed, 19 Mar 2003 17:16:51 -0800
Received: from kealia.com (hawaii.kealia.com [10.42.69.4])
	by hawaii.kealia.com (Postfix) with ESMTP id 3CA25B95D
	for <nfs@lists.sourceforge.net>; Wed, 19 Mar 2003 17:16:51 -0800 (PST)
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

I'm running Linux 2.4.18 kernels on my NFS server and clients, and am trying 
to debug what seems to be an incorrectly configured block size.

Are there ways to:

- determine what version of the NFS protocol is being used by an existing 
NFS mount?

- determine what block size is being used for an existing NFS mount?

- set the default block size on the NFS (v3?) server, so I don't have to 
specify rsize and wsize on every client?

Any help would be appreciated.

--Ed



-------------------------------------------------------
This SF.net email is sponsored by: Does your code think in ink? 
You could win a Tablet PC. Get a free Tablet PC hat just for playing. 
What are you waiting for?
http://ads.sourceforge.net/cgi-bin/redirect.pl?micr5043en
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
