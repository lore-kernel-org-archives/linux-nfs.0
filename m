From: "Ogden, Aaron A." <aogden@unocal.com>
Subject: RE: NFS digest, Vol 1 #1365 - 4 msgs
Date: Wed, 19 Mar 2003 14:11:20 -0800
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <41C61615CE88D211AA3500805F9FFECE05D4B927@renegade.sugarland.unocal.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from unogate.unocal.com ([192.94.3.1])
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18vlmP-0004Bs-00
	for <nfs@lists.sourceforge.net>; Wed, 19 Mar 2003 14:11:25 -0800
Received: from saratoga.unocal.com (localhost [127.0.0.1])
	by unogate.unocal.com (8.12.8/8.12.8) with ESMTP id h2JMBLmX014527
	for <nfs@lists.sourceforge.net>; Wed, 19 Mar 2003 14:11:21 -0800 (PST)
To: "'nfs@lists.sourceforge.net'" <nfs@lists.sourceforge.net>
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



-----Original Message-----
From: nfs-request@lists.sourceforge.net
[mailto:nfs-request@lists.sourceforge.net]
Sent: Wednesday, March 19, 2003 2:02 PM
To: nfs@lists.sourceforge.net
Subject: NFS digest, Vol 1 #1365 - 4 msgs


Send NFS mailing list submissions to
	nfs@lists.sourceforge.net

To subscribe or unsubscribe via the World Wide Web, visit
	https://lists.sourceforge.net/lists/listinfo/nfs
or, via email, send a message with subject or body 'help' to
	nfs-request@lists.sourceforge.net

You can reach the person managing the list at
	nfs-admin@lists.sourceforge.net

When replying, please edit your Subject line so it is more specific
than "Re: Contents of NFS digest..."


Today's Topics:

   1. NFS and lock problems (Glover George)
   2. Mortgage Rate Alert (take action now) (Sal Parrish)
   3. NFSD Flow Control Using the TCP Transport (Steve Dickson)
   4. NFS problems (kernel locks up) (Kresimir Kukulj)

--__--__--

Message: 1
From: Glover George <dime@gulfsales.com>
To: nfs@lists.sourceforge.net
Date: 18 Mar 2003 16:00:37 -0600
Subject: [NFS] NFS and lock problems

Hello all, please bare with me as I figure this has probably been asked
a million times, but I can't find anything like what I'm looking for.

I have multiple clients and a single server.  The server I am running
redhat 8.0 on, and nfs versions that came with it.  I have a fairly
simple setup.  On the client machines, iptables is set to drop
everything, except it allows all outgoing requests and only allows
incoming ssh. On the server it is the same, except for I am allowing in
a range of ports for nfs.

$IPTABLES -A INPUT -p tcp -s 131.95.190.0/24 --dport 32765:32768 -j
ACCEPT
$IPTABLES -A INPUT -p udp -s 131.95.190.0/24 --dport 32765:32768 -j
ACCEPT

... as per the NFS HOWTO.

I am starting in the startup scripts the following:
daemon rpc.mountd -p 32767 $RPCMOUNTDOPTS
daemon rpc.statd -p 32765 -o 32766

Also, in /etc/modules.conf for lockd i have the following: 
options lockd nlm_udpport=32768 nlm_tcpport=32768

Anything else I may be missing, I'll gladly supply to you.  Let me get
to the problem and the questions. I am having problems it seems with
locking.  When users try to log in with the gnome desktop they get error
messages compaining about nfslockd possibly not running on the server. 
However it is.  Everything as far as nfs is concerned seem to be fine.
Just to be more verbose, here is the output of rpcinfo -p on server and
client respectively.

#server
    program vers proto   port
    100000    2   tcp    111  portmapper
    100000    2   udp    111  portmapper
    391002    2   tcp  32768  sgi_fam
    100011    1   udp    744  rquotad
    100011    2   udp    744  rquotad
    100011    1   tcp    747  rquotad
    100011    2   tcp    747  rquotad
    100003    2   udp   2049  nfs
    100003    3   udp   2049  nfs
    100021    1   udp  32768  nlockmgr
    100021    3   udp  32768  nlockmgr
    100021    4   udp  32768  nlockmgr
    100005    1   udp  32767  mountd
    100005    1   tcp  32767  mountd
    100005    2   udp  32767  mountd
    100005    2   tcp  32767  mountd
    100005    3   udp  32767  mountd
    100005    3   tcp  32767  mountd
    100024    1   udp  32765  status
    100024    1   tcp  32765  status

#client
[root@black root]# rpcinfo -p
   program vers proto   port
    100000    2   tcp    111  portmapper
    100000    2   udp    111  portmapper
    391002    2   tcp  32769  sgi_fam
    100021    1   udp  32775  nlockmgr
    100021    3   udp  32775  nlockmgr
    100021    4   udp  32775  nlockmgr
    100024    1   udp  32778  status
    100024    1   tcp  33409  status
    100011    1   udp   1022  rquotad
    100011    2   udp   1022  rquotad
    100011    1   tcp    601  rquotad
    100011    2   tcp    601  rquotad
    100003    2   udp   2049  nfs
    100003    3   udp   2049  nfs
    100005    1   udp  32779  mountd
    100005    1   tcp  33410  mountd
    100005    2   udp  32779  mountd
    100005    2   tcp  33410  mountd
    100005    3   udp  32779  mountd
    100005    3   tcp  33410  mountd

Does this look ok for locking? Is there someway i can verify if file
locking is working ok (I only assume that it's not because of that
message, I have no idea how i would test this for sure).  Do i have to
bind the daemons to a specific port on the client as well as the
server?  Do I have to allow initiated connections to any of these
daemons from the server to the client?  I mean, turning off iptables
completely on the clients doesn't help anyway.  Still the same errors. 
Are my options to /etc/modules correct?  I noticed on the server side
that sgi_fam and nfslockmgr are both running on the same port.  Is this
ok?  If not, how do i tell sgi_fam to move to a different port.

One last thing, I haven't implemented this, but just if someone wants to
pipe in, on the server side i want to run rpc.rquotad on a specific
port.  how do i do this with redhat's packages, as i can't use a -p
option. 

I know I'm probably bugging a lot, but I have no idea what's going on
here, as everything has always worked for me when i simply use KDE, but
this problem is plaguing me.  I'd like to know if maybe i've done
something wrong or just have the whole wrong idea about it.

Much thanks in advance.

-- 
Glover George
Systems Administrator
High Performance Visualization Lab
University of Southern Mississippi
glover.george@usm.edu
(601) 266-5634



--__--__--

Message: 2
From: "Sal Parrish" <v70lh9ye@yahoo.com>
To: <netsaintplug-devel@lists.sourceforge.net>, <nfs@lists.sourceforge.net>,
<sax-devel@lists.sourceforge.net>, <sax-users@lists.sourceforge.net>
Date: Tue, 18 Mar 03 20:07:54 GMT
Subject: [NFS] Mortgage Rate Alert (take action now)

This is a multi-part message in MIME format.

--9_B_1C.FFE
Content-Type: text/html
Content-Transfer-Encoding: quoted-printable

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv=3D"Content-Type" content=3D"text/html; charset=3Diso-8859=
-1">
</head>

<body alink=3D"#0066FF" vlink=3D"#0066FF">

<table align=3D"center" width=3D"622" cellspacing=3D"12" cellpadding=3D"5"=
>
  	<tr>
    	<td align=3D"center">
			<font color=3D"#990000"face=3D"arial"
size=3D"6"><b>Finding the best ra=
tes for a new home
			 loan or refinancing an old one can be a daunting
task</b></font>
		</td>
  	</tr>
</table>
<table align=3D"center" width=3D"622" cellspacing=3D"12" cellpadding=3D"5"=
>
  	<tr>
    	<td align=3D"center">
			<font size=3D"5"><b><a
href=3D"http://www.e-bestfinancerate.com/mortgag=
e/index.asp?Afft=3DQM43">It doesn't have to be.</a></b></font>
		</td>
  	</tr>  
	<tr>
		<td align=3D"center">	
			<font face=3D"Arial">We do the work for you.  By
submitting
			your information across to hundreds of lenders, we
can get you the
			  best interest	rates around. <BR><BR>
			Interest rates are lower than they have been in over
40 years, but
			it won't stay that way for long.  Our simple form
only takes a few mome=
nts,
			there is absolutly <b>NO OBLIGATION</b>, and it's
<b>100% FREE</b>.  Yo=
u have nothing
			to lose, and everything to gain.  </font>
		</td>
  	</tr>
</table>
<table align=3D"center" width=3D"622" cellspacing=3D"12" cellpadding=3D"5"=
>
  	<tr>
    	<td align=3D"center">
			<a
href=3D"http://www.e-bestfinancerate.com/mortgage/index.asp?Afft=3DQ=
M43"><b><font face=3D"arial" size=3D"6">Let us start working for YOU!</fon=
t></b></a>
		</td>
  	</tr>
</table>
<table align=3D"center" width=3D"622" cellspacing=3D"12" cellpadding=3D"5"=
>
  	<tr>
    	<td>
			<font face=3D"Arial, Helvetica, sans-serif"
size=3D1><p align=3Dcenter>=

			Please know that we do not want to send you
information regarding our 
			special offers if you do not wish to receive it.  
			If you<br> would no longer like us to contact you or
feel that you have=
 received 
			this email in error, please
			<a
href=3D"http://www.e-bestfinancerate.com/Automatic/index.htm"><font =
color=3D"#0000ee"> 
			click here to unsubscribe</a>.</font>	
		</td>
  	</tr>
</table>

</body>
</html>

vowxskyyllufeiaqy lq pwaya 
--9_B_1C.FFE--



--__--__--

Message: 3
Date: Wed, 19 Mar 2003 10:05:15 -0500
From: Steve Dickson <SteveD@RedHat.com>
To: nfs@lists.sourceforge.net
Subject: [NFS] NFSD Flow Control Using the TCP Transport

Hello,

There seems to be some issues (probably known) with the flow control
over  TCP connections (on an SMP machine) to NFSD. Unfortunately,
the fstress benchmark brings these issues out fairly nicely :-(
This is occurring in a 2.4.20 kernel.

When fstress starts  it's stress tests,  svc_tcp_sendto() immediately 
starts failing
with -EGAINs. Initially, this caused  an oops because svc_delete_socket()
was being called twice for the same socket [ which was easily fixed by 
checking
 for the SK_DEAD bit in svsk->sk_flags],  but now the tests just fail.

The problem seems to stem from the fact that the queued memory in
the TCP send buffer (i.e. sk->wmem_queued) is not being released ( i.e
tcp_wspace(sk)  becomes negative and  never recovers).

Here is what's (appears to be)  happening:
Fstress opens one TCP connection and then start sending
multiple nfs ops with different fhandles . The problems start when
a nfs op, with a large responses (like a read), gets 'stuck' in the nfs code
for a few microseconds and in the meantime other nfs ops, with smaller
responses are being processed.  With every smaller response, the
sk->wmem_queued value is incremented. Now when the 'stuck' nfs read
tries to send its responses the send buffer is full (i.e. 
tcp_memory_free(sk)
in tcp_sendmsg() fails) and  after a 30 second sleep (in tcp_sendmsg())
-EAGAIN is returned and the show is over.....

I _guess_ what is suppose  to happen is that the queued memory  will be
freed (or reclaimed) when a socket buffer is freed (via kfree_skb()).
Which in turn causes the threads waiting for memory (i.e. sleeping
in tcp_sendmsg()) to be woke up via a  call to sk->write_space().
But this does not seem to be happening even when the smaller
replies are processed....

Can anyone shed some light on what the heck is going on here
and if there are any patches or solutions or ideas addressing this
problem.

TIA,

SteveD.




--__--__--

Message: 4
Date: Wed, 19 Mar 2003 19:22:41 +0100
From: Kresimir Kukulj <madmax@iskon.hr>
To: nfs@lists.sourceforge.net
Subject: [NFS] NFS problems (kernel locks up)

Hi

We are trying to assess if linux could perform as a NFS server to linux
client(s). In our test we moved part of mailboxes of a freemail service
(after some initial testing) to a NFS storage (linux NFS server). It worked
ok, and used very little resources. But, during the nightly backup, NFS
server crashed. Symptoms were that:
  1. client detected that NFS server is not responding
  2. NFS server responded to ping, but you could not log in to it. Every
     attempt to log-in stopped at TCP connection being established, but
     daemon did not respond (I presume, that at that particular moment
     TCP/IP stack was still working).
  3. After cca 10 minutes, it locks up (not ping-able).
  4. I have serial console attached to the server, and kernel did not
     respond to SYS-REQ.
  5. After turning off the power and then back on, server booted, and
     resumed its function.

This happened three times, every time during the backup (Networker),
sometimes only 5 minutes after backup started, sometimes after 1.5 hours.
This was all using 2.4.20 kernel (no extra patches), using NFSv3, udp,
async.
NFS client was using: rw,hard,intr,udp,rsize=8192,wsize=8192,nodev,nosuid
NFS server used: rw,no_root_squash (default is async).

Then, I have put 2.4.21-pre5 because it contained some NFS fixes. After
that, server survived three days (2 incrementals and one full backup
completed successfully). Then it crashed during the day for no apparent
reason (we have the server monitored with 'cricket', and there were no
unusual activities...).

I have changed to NFSv2,sync,udp and it crashed during the backup that
night,
and then again during the day. This resulted with filesystem corruption
(replaying the ext3 journal caused fsck to be invoked - couple of hours was
wasted on checking).

Now I have reverted back to NFSv3,udp, but kept 'sync'. I will see tonight
will it survive or not. 

Filesystem is 99Gb ext3 partition, with 1024 block size, internal journal.
That fs is 50% full, and contains around 290000 files (13.7% fragmentation).
Files are between few kilobytes up to 10 Mb.

Normal filesystem usage is ~200kb read, 300Kb write per second with < 5%
disk utilization. When backup runs, reading gets ~ 5Mb/sec with disk
utilization of ~ 100%.

Client and server are connected to the same switch, with no dropped packets.

We are satisfied with performance (while the server works).

Can anybody give a suggestion ? I have tried everything I can think of.
We would like to use linux as a NFS server, but if this does not work, we
will be forced to consider alternatives like Solaris x86.
Can anyone here suggest a good alternative NFS server OS (for x86) with a
good support for SCSI HW RAID controllers ? ICP Vortex unfortunately is
not supported under Solaris x86, but what other controllers (let's say for
Solaris x86) do you reccommend ?

Also, I am concerned about filesystem. Will ext3 be able to handle, let's
say, 10 million files ? If not, will Solaris x86 UFS be any better.
[ For us, reiser proved to be sometimes difficult, and we had couple of fs
related crashes, so we are trying to find alternatives. Filesystem check
on that amount of files is measured in days. ]

Some info about hardware:
Dell PowerApp 200 with 2 x Pentium III (Coppermine), each 1GHz.
1Gb memory, with CONFIG_HIGHMEM4G=y.
eepro100 ethernet
ServerWorks chipset but nothing except CDROM is connected to it.
ICP Vortex Hardware RAID model GDT8523RZ
Driver for this (SCSI) controller is from 2.4.20 kernel (its pretty new).
5 FUJITSU MAJ3364MC 34Gb drives in RAID5 (4+hotfix).
Filesystem is ext3 with journal=ordered.

Kernel is vanilla 2.4.20, and 2.4.21-pre5.
I can provide 'dmesg' and '.config' for that kernel.

Distribution is Debian stable 3.0.
These packages are installed:
ii  nfs-common              1.0-2                   NFS support files common
to client and server
ii  nfs-kernel-server       1.0-2                   Kernel NFS server
support

NFS server and client use fixed ports as described at NFS-Howto:
Kernel command line: root=/dev/sda2 lockd.udpport=32768 \
                     lockd.tcpport=32768 console=tty0 console=ttyS0,9600
statd, mountd are fixed as well, and iptables are configured to pass
fragmented packets. By default, NFS server runs with 8 kernel threads
(knfsd). According to /proc/net/rpc/nfsd there is no need for more kernel
threads.

Services that run on NFS client are POP3 and SMTP daemons and a web based
frontend that uses them. Both daemons are configured to use their version of
dot locking (as recommended).

Thanks.

-- 
Kresimir Kukulj
Iskon Internet d.d.
ISS
Savska 41/X.
10000 Zagreb



--__--__--

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs


End of NFS Digest


-------------------------------------------------------
This SF.net email is sponsored by: Does your code think in ink? 
You could win a Tablet PC. Get a free Tablet PC hat just for playing. 
What are you waiting for?
http://ads.sourceforge.net/cgi-bin/redirect.pl?micr5043en
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
