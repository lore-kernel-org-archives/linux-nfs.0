From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: nfsroot problems on RedHat 8 with kernel linux-2.4.18-27.8.0
Date: Fri, 23 May 2003 16:31:57 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <16078.12509.988134.109974@charged.uio.no>
References: <3ECE0EF3.5080004@ti.com>
	<shs4r3lx1ux.fsf@charged.uio.no>
	<3ECE2479.3000706@ti.com>
Reply-To: trond.myklebust@fys.uio.no
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from pat.uio.no ([129.240.130.16])
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19JDae-0000sJ-00
	for <nfs@lists.sourceforge.net>; Fri, 23 May 2003 07:32:12 -0700
To: martynas@ti.com
In-Reply-To: <3ECE2479.3000706@ti.com>
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

>>>>> " " == Martynas Buozis <martynas@ti.com> writes:

     > When system is booted up (same IP and host name but using
     > another boot tree with identical file shared on SUN/Solaris) I
     > can mount there file systems shared on Celerra (simple "mount
     > cellera:/share /mnt" command) In this case usual mount command
     > sends all information Celerra expects to get. So I think that
     > problem is really in nfsroot module itself. Maybe it is too
     > old, because it does not support all options available for
     > usual command line mount command as specified in "man nfs" ?

NFS uses the hostname as specified in /proc/sys/kernel/hostname (alias
system_utsname.nodename) whether or not it is running from NFSroot.

If you have set the hostname in bootp, then ipconfig will set it, and
will print it out as 'host=%s" in the "IP-Config: Complete"
information...

Cheers,
  Trond


-------------------------------------------------------
This SF.net email is sponsored by: ObjectStore.
If flattening out C++ or Java code to make your application fit in a
relational database is painful, don't do it! Check out ObjectStore.
Now part of Progress Software. http://www.objectstore.net/sourceforge
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
