From: Wade Hampton <wade.hampton@nsc1.net>
Subject: Linux client on Solaris 7 NFS server
Date: Wed, 24 Dec 2003 10:12:27 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <3FE9ACDB.4060004@nsc1.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.24)
	id 1AZAge-0002Dq-DI
	for nfs@lists.sourceforge.net; Wed, 24 Dec 2003 07:12:36 -0800
Received: from www.nsc1.net ([4.22.175.200] helo=mail.nsc1.net)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.24)
	id 1AZAge-0000xV-0N
	for nfs@lists.sourceforge.net; Wed, 24 Dec 2003 07:12:36 -0800
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

Merry Christmas and Happy Holidays!

I have a Fedora Core 1.0 client connecting to a
Solaris X86 Version 7 NFS server.  The Solaris server
has locked up several times since I started accessing
it from Linux (this is the only change to the Solaris
system's environment).  I was wondering if this
was an NFS problem on Solaris 7 or could be a
hardware problem with the NIC.

The options I was using for NFS mount were
auto,ro,bg,soft.  

After reading the NFS howto, it indicated that 
"Solaris servers are especially sensitive to packet size".
This is vague and does not tell what the consequences of
default values or values other than 32768 might be....

Could "sensitive" mean bad performance, lost data, lost connections,
disconnects, locked up clients, or locked up servers?

Could this be a reason that the Solaris server is locking up?

Has anyone else experienced this? 

If this is the case, does Sun have a patch that addresses this?

Any Solaris Admins out there that can tell me how I can
check the Solaris server to see if such a patch (if it exists)
is applied?

I did change my mount to the following options:  
    auto,rsize=32768,wsize=32768,ro,bg,soft.

So far, I have not had any server lockups (since yesterday).
However, I need to be sure that I am not introducing a problem
by using Linux boxes with these servers.....

Also, if my Fedora box is accessing the server via a WAN,
should I use NFS over TCP/IP?   If my network goes down,
do I have to unmount and remount if I am using TCP/IP?

Thanks,
--
Wade Hampton



-------------------------------------------------------
This SF.net email is sponsored by: IBM Linux Tutorials.
Become an expert in LINUX or just sharpen your skills.  Sign up for IBM's
Free Linux Tutorials.  Learn everything from the bash shell to sys admin.
Click now! http://ads.osdn.com/?ad_id=1278&alloc_id=3371&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
