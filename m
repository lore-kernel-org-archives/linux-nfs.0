From: Michael Devogelaere <michael.devogelaere@digibel.be>
Subject: cache problem
Date: Thu, 7 Nov 2002 23:01:56 +0100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20021107230156.A27591@digibel.be>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from stingray.digibel.be ([213.193.158.19] helo=digibel.be)
	by usw-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 189uiw-0005rW-00
	for <nfs@lists.sourceforge.net>; Thu, 07 Nov 2002 14:02:02 -0800
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

Hi,

I'm having troubles with a nfs-setup. The NFS-server runs Debian Linux 2.2 with
a vanilla 2.2.19 kernel. There are 2 groups of NFS-clients: 
- old workstations running kernel 2.0.20 on a distribution which seems a
  bit based on redhat 6.2
- modern workstations running kernel 2.4.19+patches as shipped with redhat 7.3

All workstations share a few nfs-shares and 1 directory is particulary
'popular'. Today one new workstation (running redhat 7.3) modified all files
in that directory by adding some data to all those files. The old workstations
immediately 'see' the modified files, but the new workstations have problems.
If one requests file 'A', the new workstation actually gets file 'B' with the
recent modifications. I waited several hours and the problem remained. I'm 
pretty sure the data on the NFS-server is correct as the old workstations can 
read the correct files. The only solution i found to get the correct files on 
the new workstations is to remount the filesystem (or reboot). 

We reproduced the problem and i ran 'stat' on the files. It turns out that
some files seem to share the same inode-number after the modifications. As
said: with 'mount -o remount /...' i could fix the clients and see the correct
inode-numbers. I thought it was some strange nfs-read-cache problem and
tried a few options like 'timeo=0' and 'noac' but that didn't solve the
problem.

Is this a bug in the communication between nfs with kernel 2.4.19 and
kernel 2.2.19 ? Is there a way to disable the nfs-cacheing completely ? 
I tried to disable all file-cache on the computer but didn't find how to
configure this.

Any help would be greatly appreciated !!


Kind regards,
Michael Devogelaere.


-------------------------------------------------------
This sf.net email is sponsored by: See the NEW Palm 
Tungsten T handheld. Power & Color in a compact size!
http://ads.sourceforge.net/cgi-bin/redirect.pl?palm0001en
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
