From: Marc Schmitt <mschmitt@inf.ethz.ch>
Subject: rpc.mountd: getfh failed: Operation not permitted
Date: Wed, 06 Aug 2003 17:08:21 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <3F3119E5.2040207@inf.ethz.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from medoc.inf.ethz.ch ([129.132.178.200])
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19kPtr-0003k4-00
	for <nfs@lists.sourceforge.net>; Wed, 06 Aug 2003 08:08:27 -0700
Received: from localhost (localhost [127.0.0.1])
	by medoc.inf.ethz.ch (Postfix) with ESMTP id 7DAC065119
	for <nfs@lists.sourceforge.net>; Wed,  6 Aug 2003 17:08:23 +0200 (MEST)
Received: from medoc.inf.ethz.ch ([127.0.0.1])
 by localhost (medoc [127.0.0.1]) (amavisd-new, port 10024) with LMTP
 id 13758-01-8 for <nfs@lists.sourceforge.net>;
 Wed,  6 Aug 2003 17:08:23 +0200 (MEST)
Received: from inf.ethz.ch (ikarus.inf.ethz.ch [129.132.10.58])
	by medoc.inf.ethz.ch (Postfix) with ESMTP id D67B86510C
	for <nfs@lists.sourceforge.net>; Wed,  6 Aug 2003 17:08:22 +0200 (MEST)
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

Hi (again)

I don't get any rest with my Linux NFS server... after you helped me 
with the mountd RPC issues, today another problem occured, it was the 
third time this happened.

All of a sudden, the server comes into a state where it will fill the 
logs with the error message in the subject. Clients with active mounts 
will continue working fine, but some mount requests (only some!) will be 
denied with that error. Restarting the nfs daemon helps, after that some 
users reported that their homes were hanging with a stale handle, though.

After googling around, I found various suggestions:

- upgrade to kernel >= 2.4.20 (which is something I have to do tonight 
anyway, the server currently suffers from the quota bug in 2.4.18-27 
that was solved in 2.4.20-18, too: "kernel: VFS: find_free_dqentry(): 
Data block full but it shouldn't. kernel: VFS: Error -5 occured while 
creating quota.")

- increase the number of open file handles
Is this really related? file-max is currently set to 399763, which 
should be enough...

- locking issues
Samba is running on the server, too. Could this potentially lead to this 
error? Or serveral clients accessing the same file over NFS?

Hopefully, the problem will go away with the kernel upgrade.

The underlying filesystem is ext3, mounted with usrquota and 
data=journal, btw.

Please let me know if you see other potential reasons for this problem, 
thanks.

Greetings
     Marc





-------------------------------------------------------
This SF.Net email sponsored by: Free pre-built ASP.NET sites including
Data Reports, E-commerce, Portals, and Forums are available now.
Download today and enter to win an XBOX or Visual Studio .NET.
http://aspnet.click-url.com/go/psa00100003ave/direct;at.aspnet_072303_01/01
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
