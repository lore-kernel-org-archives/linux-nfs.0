From: Steve Bush <sbush@scitegic.com>
Subject: fcntl() problem
Date: Fri, 16 Jul 2004 18:11:51 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <5.2.1.1.2.20040716175623.01ba83e0@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; format=flowed
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BldkB-0001zf-Af
	for nfs@lists.sourceforge.net; Fri, 16 Jul 2004 18:12:03 -0700
Received: from scitegic-2.access.nethere.net ([66.63.144.242] helo=mercury.internal.scitegic.net)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.34)
	id 1BldkB-0005Fc-1S
	for nfs@lists.sourceforge.net; Fri, 16 Jul 2004 18:12:03 -0700
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

Hi,

We have a problem with calls to fcntl() on an NFS shared drive within a 
tiny cluster (only 2 computers) on one of our Redhat Enterprise WS systems 
(freshly installed).  Whenever we call fcntl() with F_SETLK as either 
F_RDLCK or F_WRLCK, fcntl returns -1 and errno is set to EACCES (Permission 
Denied).  However, on an identical system here we've been unable to 
duplicate the problem seen on this remote set-up.

We've checked to make sure that the user running the application are 
correct for the file being accessed (they are, and indeed the 
fopen(filename, boolWriting ? "w" : "r") call immediately prior to fcntl 
works fine)

We've checked to make sure that rpc.statd and lockd are running and that 
the rpc.statd process is owned by rpcuser.

We've confirmed that fcntl() works perfectly fine when run on the server on 
the exact same files.

We've checked for blocking pids via fcntl(fd, F_GETLK, &flock), but the pid 
returned is -1.

Any ideas or suggestions?
--
Steve Bush (sbush@scitegic.com)
"There was a point to this narrative, but it has presently escaped the 
chronicler's mind."  --Douglas Adams



-------------------------------------------------------
This SF.Net email is sponsored by BEA Weblogic Workshop
FREE Java Enterprise J2EE developer tools!
Get your free copy of BEA WebLogic Workshop 8.1 today.
http://ads.osdn.com/?ad_id=4721&alloc_id=10040&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
