From: Marc Schmitt <mschmitt@inf.ethz.ch>
Subject: bad cookie size 20 (only cookies under 8 bytes are supported.)
Date: Sun, 02 Nov 2003 15:20:34 +0100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <3FA512B2.1080109@inf.ethz.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 1AGJ5p-000843-00
	for <nfs@lists.sourceforge.net>; Sun, 02 Nov 2003 06:20:37 -0800
Received: from medoc.inf.ethz.ch ([129.132.178.200])
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.24)
	id 1AGJ5p-0007mi-Ft
	for nfs@lists.sourceforge.net; Sun, 02 Nov 2003 06:20:37 -0800
Received: from localhost (localhost [127.0.0.1])
	by medoc.inf.ethz.ch (Postfix) with ESMTP id F0FA9AEB7
	for <nfs@lists.sourceforge.net>; Sun,  2 Nov 2003 15:20:34 +0100 (MET)
Received: from medoc.inf.ethz.ch ([127.0.0.1])
 by localhost (medoc [127.0.0.1]) (amavisd-new, port 10024) with LMTP
 id 08599-01-10 for <nfs@lists.sourceforge.net>;
 Sun,  2 Nov 2003 15:20:34 +0100 (MET)
Received: from inf.ethz.ch (ikarus.inf.ethz.ch [129.132.10.58])
	by medoc.inf.ethz.ch (Postfix) with ESMTP id 81127AEB0
	for <nfs@lists.sourceforge.net>; Sun,  2 Nov 2003 15:20:34 +0100 (MET)
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

Hi all,

I did upgrade yesterday my RedHat 7.3 box (2.4.20-20.7smp) from 
nfs-utils 1.0.5 to 1.0.6, after that, messages was full with:

Nov  2 15:02:56 server kernel: lockd: bad cookie size 20 (only cookies 
under 8 bytes are supported.)
Nov  2 15:02:56 server kernel: svc: failed to decode args
Nov  2 15:02:57 server kernel: lockd: bad cookie size 20 (only cookies 
under 8 bytes are supported.)
Nov  2 15:02:57 server kernel: svc: failed to decode args
Nov  2 15:03:16 server kernel: lockd: bad cookie size 20 (only cookies 
under 8 bytes are supported.)

I've never had those messages before, does 1.0.6 require a certain 
minimum kernel version (ex. >= 2.4.22)?

TIA

Regards,
    Marc



-------------------------------------------------------
This SF.net email is sponsored by: SF.net Giveback Program.
Does SourceForge.net help you be more productive?  Does it
help you create better code?   SHARE THE LOVE, and help us help
YOU!  Click Here: http://sourceforge.net/donate/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
