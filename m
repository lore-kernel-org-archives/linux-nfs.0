From: Rejaine Monteiro <rejaine@bhz.jamef.com.br>
Subject: nfsserver hangs randomly
Date: Tue, 25 Oct 2005 10:25:17 -0200
Message-ID: <1130243117.21685.14.camel@acesup2.bhz.jamef>
Mime-Version: 1.0
Content-Type: text/plain
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1EUNrQ-0000xK-Hp
	for nfs@lists.sourceforge.net; Tue, 25 Oct 2005 05:25:00 -0700
Received: from jamef.com.br ([200.243.222.66] helo=mail.jamef.com.br)
	by mail.sourceforge.net with smtp (Exim 4.44)
	id 1EUNrO-0001OF-SG
	for nfs@lists.sourceforge.net; Tue, 25 Oct 2005 05:25:00 -0700
Received: from acesup2.bhz.jamef ([172.22.10.30])
          (envelope-sender <rejaine@bhz.jamef.com.br>)
          by mail.bhz.jamef (qmail-ldap-1.03) with SMTP
          for <nfs@lists.sourceforge.net>; 25 Oct 2005 12:24:55 -0000
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

Hi, 

My nfsserver is stable, but sometimes (at least 1 or time per week) the
service just hangs (ONLY the service nfsserver) 

When this happens, "rcnfsserver stop/start/restart/reload" or "exportfs
-a" don't work (just hangs), can't do a "cat /proc/fs/nfs/exports" or
"cat /etc/exports" (hangs to) and cpu load is very high (but all others
services on server is OK) and all clients hangs up (home's users is a
nfs mounted folder...)

My /var/log/messages reports only this:

saobkp rpc.statd[1152]: Can't callback saobkp (100021,4), giving up.

ps: saobkp is the nfsserver 

The last resource is a hard boot (power off) !!!

My configuration:

#Server Suse 9.0
#Linux saobkp 2.4.21-273-smp4G #1 SMP i686 i686 i386 GNU/Linux
#nfs-utils-1.0.6-114

# /etc/exports

/home              *(insecure,sync,rw)
/cdrom             *(insecure,sync,ro)

# /etc/hosts

127.0.0.1       localhost
# special IPv6 addresses
::1             localhost ipv6-localhost ipv6-loopback
fe00::0         ipv6-localnet
ff00::0         ipv6-mcastprefix
ff02::1         ipv6-allnodes
ff02::2         ipv6-allrouters
ff02::3         ipv6-allhosts
172.22.50.6     saobkp.sao.jamef        saobkp

# eth0 = 172.22.50.1

# host saobkp
saobkp.sao.jamef has address 172.22.50.6 

# /etc/sysconfig/nfs

USE_KERNEL_NFSD_NUMBER="10"
STATD_HOSTNAME="saobkp"

# CLIENTS CONFIGURATION uses autofs (automount)

# /etc/auto.master

/server/u /etc/auto.u

# /etc/auto.u 

*       -fstype=nfs     nfs:/home/u/&

# And "host nfs"
nfs.sao.jamef has address 172.22.50.6

What is wrong?

Rejaine da Silveira Monteiro



-------------------------------------------------------
This SF.Net email is sponsored by the JBoss Inc.
Get Certified Today * Register for a JBoss Training Course
Free Certification Exam for All Training Attendees Through End of 2005
Visit http://www.jboss.com/services/certification for more information
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
