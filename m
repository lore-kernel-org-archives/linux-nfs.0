From: Nicolas Kowalski <Nicolas.Kowalski@imag.fr>
Subject: nfs "storm"
Date: Fri, 13 Jun 2003 15:15:44 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <vqowufqktj3.fsf@astazou.imag.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from imag.imag.fr ([129.88.30.1])
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 19QoPG-0004MP-00
	for <nfs@lists.sourceforge.net>; Fri, 13 Jun 2003 06:15:50 -0700
Received: from mail-veri.imag.fr (pave.imag.fr [129.88.43.12])
	by imag.imag.fr (8.12.9/8.12.9) with ESMTP id h5DDFi9H011390
	for <nfs@lists.sourceforge.net>; Fri, 13 Jun 2003 15:15:44 +0200 (CEST)
Received: from astazou.imag.fr
	([129.88.43.102] helo=astazou.imag.fr.imag.fr ident=kowalski)
	by mail-veri.imag.fr with esmtp (Exim 3.35 #1 (Debian))
	id 19QoPA-00055U-00
	for <nfs@lists.sourceforge.net>; Fri, 13 Jun 2003 15:15:44 +0200
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


Hello.

On a Linux (2.4.21-rc7-xfs) fileserver running knfsd, I just
experienced what I call a "nfs storm" : the NFS server was completely
overloaded (load average of 11). Here is what top showed me during
this overload.

  PID USER     PRI  NI  SIZE  RSS SHARE STAT %CPU %MEM   TIME COMMAND
  299 root       9   0     0    0     0 SW   99.9  0.0  53:45 nfsd
  301 root      18   0     0    0     0 SW   99.9  0.0  53:23 nfsd
  302 root      10   0     0    0     0 RW   99.9  0.0  52:52 nfsd
  304 root      12   0     0    0     0 DW   99.9  0.0  53:33 nfsd
  297 root      17   0     0    0     0 RW   92.4  0.0  53:45 nfsd
  303 root      14   0     0    0     0 DW   52.1  0.0  53:52 nfsd
  300 root       9   0     0    0     0 SW   48.5  0.0  53:51 nfsd
  298 root       9   0     0    0     0 DW   40.2  0.0  51:56 nfsd

I investigated things using tcpdump, and it showed me that *only one*
of our linux 2.4.20 nfs clients running a particular application (with
a lots of IO) was causing this overload. A strange thing was that the
"rpciod" process on that client was not so heavy (around 1-2% CPU)...

The server is a Dual-Xeon 2.4Ghz, with 1GB of memory and SCSI3 disks,
connected on a 100/FD switch. The client is connected on to the same
switch. The NFS mounts are done through automount, and do not use any
options. There are approximatively 50 NFS clients (SunOS & Linux), and
50 Windows stations (Samba shares) using this server, for home
directories and shared applications.

What can I do to make this server less "overload-prone" ?

Many thanks in advance.

-- 
Nicolas



-------------------------------------------------------
This SF.NET email is sponsored by: eBay
Great deals on office technology -- on eBay now! Click here:
http://adfarm.mediaplex.com/ad/ck/711-11697-6916-5
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
