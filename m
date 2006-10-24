From: "Shane Presley" <shane.presley@gmail.com>
Subject: Problem with NFS from RedHat4 to Solaris
Date: Tue, 24 Oct 2006 13:05:23 -0400
Message-ID: <27ae92160610241005x7c7bca01v4986fc40d77fba19@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GcPid-0008UV-Ul
	for nfs@lists.sourceforge.net; Tue, 24 Oct 2006 10:05:40 -0700
Received: from nf-out-0910.google.com ([64.233.182.188])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1GcPiX-0002Yd-4c
	for nfs@lists.sourceforge.net; Tue, 24 Oct 2006 10:05:36 -0700
Received: by nf-out-0910.google.com with SMTP id p46so378475nfa
	for <nfs@lists.sourceforge.net>; Tue, 24 Oct 2006 10:05:25 -0700 (PDT)
To: nfs@lists.sourceforge.net
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

Hello,

We have a RedHat3 server, with some NFS mounts to Solaris9 servers.
That works nicely.  We also run samba on top of that, for Windows
access to the NFS shares.  Works fine.

However, on a RedHat4 system, using the exact same mount, we
experience odd behavior.  Through the command line, CAT'ing a file
will show the file, but fail to return you back to the command line
immediately.  It's as if it's waiting for the EOF characters?
Eventually (2-5 minutes) it returns you to the command prompt.

My mount looks like

mount -t nfs  -o soft,intr,rsize=1024,wsize=1024,nosuid,udp
mysolariserver:/opt/path /misc/path

Same results autofs vs command line mount.  I have tried playing with
the rsize/wsize, seems to have no effect.  Also, I have tried removing
the udp option, same result.

RedHat3 system that works...
autofs-4.1.3-186
nfs-utils-1.0.6-44EL

RedHat4 system that hangs...
autofs-4.1.3-187
nfs-utils-lib-1.0.6-3
nfs-utils-1.0.6-70.EL4


Looking at a snoop of the traffic between the servers shows that the
RedHat4 system seems to get hung up in a loop with about two minutes
of this:

myredhat4server -> mysolaris9server          PORTMAP C GETPORT
prog=100021 (NLM) vers=4 proto=UDP
         mysolaris9server -> myredhat4server PORTMAP R GETPORT port=0
myredhat4server -> cs8          PORTMAP C GETPORT prog=100021 (NLM)
vers=4 proto=UDP
         mysolaris9server -> myredhat4server PORTMAP R GETPORT port=0

Where as on the RedHat3 snoop, I never see any of that PORTMAP traffic?

Any idea where I should look?

Thanks
Shane

-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
