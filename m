From: Pete Flugstad <peteflugstad@mchsi.com>
Subject: nfs-utils on uClibc based system?  mount failures
Date: Thu, 19 Feb 2004 10:08:20 -0600
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <4034DF74.9090208@mchsi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1AtqoL-0005pC-7n
	for nfs@lists.sourceforge.net; Thu, 19 Feb 2004 08:14:01 -0800
Received: from sccimhc02.asp.att.net ([63.240.76.164])
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.30)
	id 1Atqau-0004ha-RS
	for nfs@lists.sourceforge.net; Thu, 19 Feb 2004 08:00:08 -0800
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

(resend after subscribing to list...)

Hello,

    Has anyone gotten nfs-utils to work as a server on a Linux uClibc 
based system.  I'm using Linux 2.4.25 (yup, just built it yesterday) 
with all the NFS server stuff compiled in (semi-embedded system, no 
modules).  Root and userspace are mostly from the pre-built uClibc 
development system (http://www.uclibc.org/toolchains.html) - I'm 
currently using 0.9.23, which is a little old, but I hope that doesn't 
matter.  This is GCC 3.3.1 based.

    I managed to get nfs-utils (1.0.6) built for this system after 
hacking up a fake getrpcbynumber_r, which uClibc doesn't have (I called 
getrpcbynumber and copied the result into the result buffer - yes, I 
know it's not thread safe, but I don't see how that would be causing my 
problems).  BTW, is getrpcbynumber_r actually documented anywhere - all 
the man pages I found had the wrong (not enough) parameters - I had to 
kind of guess what was going on.

    Anyway I got it running, but what I'm seeing now is while I can 
export things OK, any mount request for something I've exported are 
failing.  I've debugged mountd, and it looks like all the auth stuff is 
working.  What seems to be failing is a call to nfsctl(NFSCTL_EXPORT, 
...).  This is the call stack when that happens:

     ...
     mount_mnt_3_svc
     get_rootfh
     export_export
     nfsexport
     nfsctl
     syscall

    Everything before the nfsctl/syscall seems to work just fine. 
get_rootfs does the authentication and that works OK.   The syscall 
however, returns -1, and sets errno to be 22 (EINVAL).

    I have the system setup if anyone else wants more debugging info. 
I'll see if I can get a dump of the arguments in nfsctl when it dies.  I 
could even let someone ssh into if they wish.

   I don't see how uClibc could be causing a problem, but I don't know 
for sure.

Thanks,
Pete


-------------------------------------------------------
SF.Net is sponsored by: Speed Start Your Linux Apps Now.
Build and deploy apps & Web services for Linux with
a free DVD software kit from IBM. Click Now!
http://ads.osdn.com/?ad_id=1356&alloc_id=3438&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
