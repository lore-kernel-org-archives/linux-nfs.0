From: Reimar Bauer <r.bauer@fz-juelich.de>
Subject: speed for NFS
Date: Tue, 27 Aug 2002 09:08:56 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <3D6B2588.938F375E@fz-juelich.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from zam197.zam.kfa-juelich.de ([134.94.172.215] helo=fz-juelich.de)
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17jaTJ-0007GT-00
	for <nfs@lists.sourceforge.net>; Tue, 27 Aug 2002 00:09:06 -0700
Received: from zam197.zam.kfa-juelich.de (localhost [127.0.0.1])
	by fz-juelich.de (8.9.3+Sun/8.9.3) with ESMTP id JAA12736
	for <nfs@lists.sourceforge.net>; Tue, 27 Aug 2002 09:08:57 +0200 (MEST)
Received: from fz-juelich.de (ich230.ich.kfa-juelich.de [134.94.153.232])
	by zam197.zam.kfa-juelich.de (8.9.3+Sun/8.9.3) with ESMTP id JAA12729
	for <nfs@lists.sourceforge.net.>; Tue, 27 Aug 2002 09:08:56 +0200 (MEST)
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
List-Archive: <http://www.geocrawler.com/redir-sf.php3?list=nfs>

Dear all,

in the next few years we will have  much amount of
data something about 70 - 100 TByte.

At the moment with our configuration nfs speed is 
quite less against the network speed.
I believe this could be extended and this is necessary.

The max transfer rate we have is about 3MByte/sec.

Is there a possibility to increase this to 30MByte/sec.
Is this relalistic? 
Where can I get a description about this? 


For the scenario clients are mostly linux, aix or cray.
The server is momentanly an aix system.


regards

Reimar Bauer





-- 
Reimar Bauer 

Institut fuer Stratosphaerische Chemie (ICG-I)
Forschungszentrum Juelich
email: R.Bauer@fz-juelich.de 
-------------------------------------------------------------------
        a IDL library at ForschungsZentrum Juelich
 http://www.fz-juelich.de/icg/icg-i/idl_icglib/idl_lib_intro.html
===================================================================


-------------------------------------------------------
This sf.net email is sponsored by: OSDN - Tired of that same old
cell phone?  Get a new here for FREE!
https://www.inphonic.com/r.asp?r=sourceforge1&refcode1=vs3390
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
