From: Frank Steiner <fsteiner-mail@bio.ifi.lmu.de>
Subject: read-error on utmp file
Date: Fri, 03 Sep 2004 11:29:53 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <41383991.1020108@bio.ifi.lmu.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1C3AOO-0001Pn-VN
	for nfs@lists.sourceforge.net; Fri, 03 Sep 2004 02:30:00 -0700
Received: from acheron.informatik.uni-muenchen.de ([129.187.214.135])
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.34)
	id 1C3AOL-0004cG-RH
	for nfs@lists.sourceforge.net; Fri, 03 Sep 2004 02:30:00 -0700
Received: from internaldeliver.acheron.informatik.uni-muenchen.de (localhost [127.0.0.1])
	by acheron.informatik.uni-muenchen.de (Postfix) with ESMTP id A854A435E6
	for <nfs@lists.sourceforge.net>; Fri,  3 Sep 2004 11:29:54 +0200 (CEST)
Received: from [141.84.1.141] (galois.bio.ifi.lmu.de [141.84.1.141])
	(using TLSv1 with cipher RC4-MD5 (128/128 bits))
	(No client certificate requested)
	by acheron.informatik.uni-muenchen.de (Postfix) with ESMTP id A094A435B2
	for <nfs@lists.sourceforge.net>; Fri,  3 Sep 2004 11:29:54 +0200 (CEST)
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

I run into a strange problem which I was able to track down to the
following easy check:

Copy /var/run/utmp to some directory, export it with nfs and mount it on
a client, say at /mnt/tmp/

Then, run on the client:

   while true; do /sbin/runlevel /mnt/tmp/utmp; done

which will repeatedly print the runlevel.
Now while the first loop is still running, start it a second time
in a second shell on the client.

One of the two loops immediately aborts with "unknown". Looking at
strace I can see this:

...
9377  open("/var/run/utmp", O_RDWR)     = 5
9377  fcntl64(5, F_GETFD)               = 0
9377  fcntl64(5, F_SETFD, FD_CLOEXEC)   = 0
9377  _llseek(5, 0, [0], SEEK_SET)      = 0
9377  brk(0)                            = 0x804a000
9377  brk(0x806b000)                    = 0x806b000
9377  brk(0)                            = 0x806b000
9377  alarm(0)                          = 0
9377  rt_sigaction(SIGALRM, {0x40147da0, [], SA_RESTORER, 0x40067aa8}, {SIG_DFL}, 8) = 0
9377  alarm(1)                          = 0
9377  fcntl64(5, F_SETLKW, {type=F_RDLCK, whence=SEEK_SET, start=0, len=0}) = 0
9377  read(5, "\2\0\0\0\0\0\0\0~\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0"..., 384) = 384
9377  fcntl64(5, F_SETLKW, {type=F_UNLCK, whence=SEEK_SET, start=0, len=0}) = 0
9377  alarm(0)                          = 1
9377  rt_sigaction(SIGALRM, {SIG_DFL}, NULL, 8) = 0
9377  alarm(0)                          = 0
9377  rt_sigaction(SIGALRM, {0x40147da0, [], SA_RESTORER, 0x40067aa8}, {SIG_DFL}, 8) = 0
9377  alarm(1)                          = 0
9377  fcntl64(5, F_SETLKW, {type=F_RDLCK, whence=SEEK_SET, start=0, len=0}) = 0
9377  read(5, 0x401706e0, 384)          = -1 EIO (Input/output error)
...

where the last line would usually look like
9061  read(5, "\10\0\0\0\262\1\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0"..., 384) = 384

This I/O error occurs only when running the two loops in parallel, and
only if the utmp file is accessed via NFS, not for a local disk.

I'm running kernel 2.6.8.1 on client and server (knfsd) and mounted with
"ro,hard,intr,tcp,lock", but ro/rw or lock/nolock don't make any difference.

Any idea what could be the problem here? How can parallel reading fail?

cu,
Frank

-- 
Dipl.-Inform. Frank Steiner   Web:  http://www.bio.ifi.lmu.de/~steiner/
Lehrstuhl f. Bioinformatik    Mail: http://www.bio.ifi.lmu.de/~steiner/m/
LMU, Amalienstr. 17           Phone: +49 89 2180-4049
80333 Muenchen, Germany       Fax:   +49 89 2180-99-4049



-------------------------------------------------------
This SF.Net email is sponsored by BEA Weblogic Workshop
FREE Java Enterprise J2EE developer tools!
Get your free copy of BEA WebLogic Workshop 8.1 today.
http://ads.osdn.com/?ad_id=5047&alloc_id=10808&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
