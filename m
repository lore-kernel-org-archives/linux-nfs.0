From: "Chris Fanning" <christopher.fanning@gmail.com>
Subject: lockd: couldn't create RPC handle for
Date: Thu, 27 Apr 2006 11:04:22 +0200
Message-ID: <215ff4410604270204x3e7cf525u8d019e4d1b1ac9d0@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1FZ2QE-0003x5-2z
	for nfs@lists.sourceforge.net; Thu, 27 Apr 2006 02:04:26 -0700
Received: from nproxy.gmail.com ([64.233.182.190])
	by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1FZ2QC-0004OC-OB
	for nfs@lists.sourceforge.net; Thu, 27 Apr 2006 02:04:26 -0700
Received: by nproxy.gmail.com with SMTP id x30so1257446nfb
        for <nfs@lists.sourceforge.net>; Thu, 27 Apr 2006 02:04:22 -0700 (PDT)
To: nfs@lists.sourceforge.net
Sender: nfs-admin@lists.sourceforge.net
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

Hello all,

I'm new aboard and, although I've been using nfs for some time now,
I've never really stopped to learn much about it.
Now I've got a problem.

I'm exporting homes.
on the server (192.168.172.30)
/home client(rw,no_root_squash,sync)

on the client(192.168.172.31) fstab
server:/home      /home           nfs     tcp,rw          0       0

This seemed to be working ok until I upgraded the kernel on the nfs
server to 2.6.16

Now, when a users opens his X session the nfs client console says
lockd: couldn't create RPC handle for 192.168.172.30

I have found a thread on this list not long ago so I tried followed it.
Below, I answer some of the same questions asked on that thread hoping
this will give some clues.

>Does 'rpcinfo -u w.x.y.z 100021' work from the server?

rpcinfo -u 192.168.172.31 100021
program 100021 version 1 ready and waiting
rpcinfo: RPC: Program/version mismatch; low version =3D 1, high version =3D=
 4
program 100021 version 2 is not available
program 100021 version 3 ready and waiting
program 100021 version 4 ready and waiting

on the client (192.168.172.31) console is says
svc: unknown version (0)
svc: unknown version (2)

> Is anything at all listening on port 32768 on '192.168.172.31'?
netstat -ap | grep 32768
udp        0      0 *:32768                 *:*

on client
ps -ef|grep lock
root      1152     1  0 10:05 ?        00:00:00 [lockd]

/home is mounted and I can use it.
But why does the nfs client console fill up with these "lockd:
couldn't create RPC handle for 192.168.172.30" ?

Thankyou for any help.
Chris.


-------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
