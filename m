From: Pete Flugstad <pete.flugstad@icon-labs.com>
Subject: nfs-utils on uClibc based system?  mount failures
Date: Wed, 18 Feb 2004 16:56:21 -0600
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <4033ED95.7050501@icon-labs.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1AtahC-0008Ho-Q7
	for nfs@lists.sourceforge.net; Wed, 18 Feb 2004 15:01:34 -0800
Received: from [216.161.118.235] (helo=mail.icon-labs.com)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.30)
	id 1AtacD-0000o7-9t
	for nfs@lists.sourceforge.net; Wed, 18 Feb 2004 14:56:25 -0800
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

(please reply to me directly as I'm not subscribed to this list)

Hello,

   Has anyone gotten nfs-utils to work on a uClibc based system.  I'm 
using Linux 2.4.25 (yup, just built it today) with all the NFS server 
stuff compiled in.  Root and userspace are from the pre-built uClibc 
development system (http://www.uclibc.org/toolchains.html) - I'm 
currently using 0.9.23, which is a little old, but I hope that doesn't 
matter.  This is GCC 3.3.1 based.

   I managed to get nfs-utils (1.0.6) built for this system after 
hacking up a fake getrpcbynumber_r, which uClibc doesn't have (I called 
getrpcbynumber and copied the result into the result buffer - yes, I 
know it's not thread safe, but I don't see how that would be causing my 
problems).  BTW, is getrpcbynumber_r actually documented anywhere - all 
the man pages I found had the wrong parameters.

   Anyway I got it running, but what I'm seeing now is that all mount 
requests are failing.  I've debugged mountd, and it looks like all the 
auth stuff is working. What seems to be failing is a call to 
nfsctl(NFSCTL_EXPORT, ...).  This is the call stack when that happens:

    ...
    mount_mnt_3_svc
    get_rootfh
    export_export
    nfsexport
    nfsctl
    syscall

   Everything before the nfsctl/syscall seems to work just fine.  All 
the exports seem to be setup just fine.

   I have the system setup if anyone else wants more debugging info. 
I'll see if I can get a dump of the arguments in nfsctl when it dies.  I 
   could even let someone ssh in if they wish.

Pete

PS: please reply to me directly as I'm not subscribed to this list.


-------------------------------------------------------
SF.Net is sponsored by: Speed Start Your Linux Apps Now.
Build and deploy apps & Web services for Linux with
a free DVD software kit from IBM. Click Now!
http://ads.osdn.com/?ad_id=1356&alloc_id=3438&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
