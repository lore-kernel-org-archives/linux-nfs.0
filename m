From: "Dr. David Alan Gilbert" <gilbertd@treblig.org>
Subject: of rmtab and 'Invalid argument' and permission denied
Date: Sat, 8 Mar 2003 19:20:21 +0000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20030308192021.GB747@gallifrey>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from parcelfarce.linux.theplanet.co.uk
	([195.92.249.252] helo=www.linux.org.uk ident=exim)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 18rjsO-00033i-00
	for <nfs@lists.sourceforge.net>; Sat, 08 Mar 2003 11:20:57 -0800
Received: from dsl-212-23-14-246.zen.co.uk ([212.23.14.246] helo=gallifrey.home.treblig.org)
	by www.linux.org.uk with esmtp (Exim 3.33 #5)
	id 18rjrp-0002uw-00
	for nfs@lists.sourceforge.net; Sat, 08 Mar 2003 19:20:21 +0000
Received: from dg by gallifrey.home.treblig.org with local (Exim 3.36 #1 (Debian))
	id 18rjrp-0002LE-00
	for <nfs@lists.sourceforge.net>; Sat, 08 Mar 2003 19:20:21 +0000
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
  I have a problem with an NFS server running SuSE 8.1 and serving
to a mix of different systems; the server runs the kernel server.

Sometimes the client will get a permission denied on attempting to mount
=66rom the server even though it managed it a few hours earlier with no
change to config of the server.

Restarting the nfs server gives a line of the form:

clienthostname: Invalid argument

Going into /var/lib/nfs/rmtab and removing the entries for the client
and then restarting cause both the Invalid argument error and the
mounting problems to disappear.

I'm not sure but one observation is that for the clients which have the
problem the rmtab contains two entries for the same file system - e.g.

clienthostname:/mountpoint:0x00000005
clienthostname:/mountpoint/a/sub/directory:0x00000002

I haven't been able to replicate the problem on a Debian (sid) box that I
happen to have here (even with the SuSE mountd binaries).

So questions:
  1) Has this been seen before - what are the known causes/cures.
	2) What exactly reads rmtab (is it mountd?) - are there any easy ways
	to track the problem?

Thanks in advance,

Dave
 ---------------- Have a happy GNU millennium! ----------------------  =20
/ Dr. David Alan Gilbert    | Running GNU/Linux on Alpha,68K| Happy  \=20
\ gro.gilbert @ treblig.org | MIPS,x86,ARM,SPARC,PPC & HPPA | In Hex /
 \ _________________________|_____ http://www.treblig.org   |_______/


-------------------------------------------------------
This SF.net email is sponsored by: Etnus, makers of TotalView, The debugger 
for complex code. Debugging C/C++ programs can leave you feeling lost and 
disoriented. TotalView can help you find your way. Available on major UNIX 
and Linux platforms. Try it free. www.etnus.com
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
