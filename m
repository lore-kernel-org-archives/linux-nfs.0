From: pwitting@Cyveillance.com
Subject: RE: NFS FAQ
Date: Fri, 25 Apr 2003 14:18:56 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <D38AFB3080F3D311807300B0D0203E53033A9559@MERCURY>
Mime-Version: 1.0
Content-Type: text/plain
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from [63.100.163.41] (helo=mercury.cyveillance.com)
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 199833-0002Wm-00
	for <nfs@lists.sourceforge.net>; Fri, 25 Apr 2003 11:35:49 -0700
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

> we invite you to visit the FAQ and send your comments
> and suggestions.

There was a discussion I initiated some months ago regarding setting the
queue sizes that contained some good information on the subject for
performance; The original script referenced a /etc/sysconfig/nfs file that
RH 8 began referencing, but included a good conversation on what the queue
sizes should be set to, and how kernel 2.4.20 was now setting those sizes
automatically. I saw a 15% performance boost in a single large file copy,
and also a significant but not quantified boost in a more dispersed NFS
system.


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
