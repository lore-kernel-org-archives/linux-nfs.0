From: Christoph Simon <ciccio@kiosknet.com.br>
Subject: NFS lock and timeout problems
Date: Fri, 13 Sep 2002 14:45:48 -0300
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20020913144548.455bc477.ciccio@kiosknet.com.br>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from adsl-nrp3-sao-c8b6cf1e.brdterra.com.br ([200.182.207.30] helo=tione.haus)
	by usw-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 17puWB-0000ri-00
	for <nfs@lists.sourceforge.net>; Fri, 13 Sep 2002 10:46:12 -0700
Received: from baco.haus (baco.haus [192.168.254.15])
	by tione.haus (8.12.3/8.12.3/Debian -4) with ESMTP id g8DHjnjD003279
	(version=TLSv1/SSLv3 cipher=EDH-RSA-DES-CBC3-SHA bits=168 verify=NO)
	for <nfs@lists.sourceforge.net>; Fri, 13 Sep 2002 14:45:49 -0300
Received: from baco.haus (localhost [127.0.0.1])
	by baco.haus (8.12.6/8.12.6/Debian-4) with SMTP id g8DHjm2n028518
	for <nfs@lists.sourceforge.net>; Fri, 13 Sep 2002 14:45:48 -0300
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

Hi!

I'm experiencing two problems, one seems to be related to NFS locking,
and the other seems to be some kind of timeout.

I'm trying to create a CD which will boot the root file system on
NFS. The CD can mount the nfs file system and run programs from
there. Also makeing this the root file system works fine. But when
init starts, I get error messages on the server and client, related to
lockd and rpc.statd. The system boots and I can make a user login from
outside via ssh. But getting super-user will take some 3 minutes. I'm
also running an X server there. Sometimes I can make a login there but
it also would take some 3 minutes to succeed. Other times, it just
hangs there, or the keyboard stops working. The keyboard actually
fails always, because if I manage to login, at most after a few
minutes it's dead.

The files on the server are the extraction of a tarball I created
from a working HD. There are no firewalls running and both the server
and client use pidentd. I used tcpdump to see if there are any network
errors, but I couldn't find any.

The server is a debian sid machine with an unpatched 2.4.19 kernel und
the official debian packages for the kernel server. The client is a
debian 3.0 (stable) machine with the same kernel, but having only NFS
client compiled into it, not the kernel nfs server.

This is what the client reports (repeatedly).

	nsm_mon_unmon: rpc failed, status=-13
	lockd: cannot monitor 192.168.254.15
	lockd: failed to monitor 192.168.254.15

I tried to trace the command from the rcS.d scripts which would cause
them, and, if there is no delay, the first comes in checkroot.sh, when
"mount -f -o remount /" is given. I've read that status=-13 tells that
statd is missing, but at this time it's running on the server and on
the client (I checked it inserting a ps command into that
script). There seem to be other commands which also trigger these
error messages.

At the same times, the server reports in /var/log/daemon.log:

	rpc.statd[9117]: Can't callback 127.0.0.1 (100021,4), giving up.
	rpc.statd[9117]: Received erroneous SM_UNMON request from baco \
		for 192.168.254.101
	rpc.statd[9117]: notify_host: failed to notify 127.0.0.1 

192.168.254.15 is the server (baco) and 192.168.254.101 is the client.

The /etc/exports file on the server has:

	/nfsvol      192.168.254.101(rw,sync,no_root_squash)

I also tried with no_auth_nlm, but there was no change. Also on the
server, /etc/hosts.allow has:

	ALL: 127.0.0.1
	ALL: 192.168.254.0/255.255.255.0

I added the first line later for the error message, but that didn't
help neither. /etc/hosts.deny on the server has no uncommented
line. The /etc/export and /etc/hosts.deny files on the client is also
empty, while /etc/hosts.allow on the client has:

	portmap: 192.168.254.15
	lockd:   192.168.254.15
	rquotad: 192.168.254.15
	mountd:  192.168.254.15
	statd:   192.168.254.15

This is the server's IP. As soon as I can log in, "rpcinfo -p" on the
client answers:

   program vers proto   port
    100000    2   tcp    111  portmapper
    100000    2   udp    111  portmapper
    100024    1   udp   1025  status
    100024    1   tcp   1024  status

and on the server:

   program vers proto   port
    100000    2   tcp    111  portmapper
    100000    2   udp    111  portmapper
    100024    1   udp  37824  status
    100024    1   tcp  57427  status
    100003    2   udp   2049  nfs
    100003    3   udp   2049  nfs
    100021    1   udp  37825  nlockmgr
    100021    3   udp  37825  nlockmgr
    100021    4   udp  37825  nlockmgr
    100005    1   udp  37826  mountd
    100005    1   tcp  57428  mountd
    100005    2   udp  37826  mountd
    100005    2   tcp  57428  mountd
    100005    3   udp  37826  mountd
    100005    3   tcp  57428  mountd

The client's /etc/fstab is:

	192.168.254.15:/nfsvol / nfs rw,hard,intr       0     0

I also tried with nolock, but that didn't change it.

I also found it strange, that "cat /proc/mount" on the client will
always give:

	192.168.254.15:/nfsvol / \
	  nfs rw,v3,rsize=8192,wsize=8192,hard,udp,lock,addr=192.168.254.15

where v3, rsize, wsize, udp and lock are options I never gave. I've
read that the defaults for rsize,wsize is 1024, so I don't know where
it comes from. While watching tcpdump, I've seen fragmentations, but
assembling seems to have succeeded always.

I would be grateful for any hint for how to solve this. Please CC me,
as I am not on this mailing list.

-- 
Christoph Simon
ciccio@kiosknet.com.br


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
