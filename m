From: "Jeffrey S. Mulliken" <mulliken@v-stor.com>
Subject: Help with NFS and automount
Date: Fri, 15 Mar 2002 23:41:13 -0800
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <3C92F719.2070507@v-stor.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Received: from [64.160.42.140] (helo=mail.v-stor.com)
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 16m8oU-0008Rh-00
	for <nfs@lists.sourceforge.net>; Fri, 15 Mar 2002 23:41:14 -0800
Received: from v-stor.com (mulliken-l-home [10.200.70.5])
	by mail.v-stor.com (8.9.3/linuxconf) with ESMTP id XAA10828
	for <nfs@lists.sourceforge.net>; Fri, 15 Mar 2002 23:41:07 -0800
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
List-Archive: <http://www.geocrawler.com/redir-sf.php3?list=nfs>

Dear Brainiacs,  

    I am having a problem and have come to the end of what I can think 
of to try.   Scenario:

    CLIENT MACHINE:
    RH 7.2  Base
    2.413-ac8 Kernel
    autofs 4.0.0
    mount 2.11g
    pptp-linux v 1.0.3-1
    Linksys BESFR41 4 port router

    HOST MACHINES:
    Gateway = RH 6.2 running firewall and VPN over PPTP
    RH 6.2 machine serving NIS (yp) and DNS
    SUN Ultras w/Solaris 2.51 and 2.6 serving NFS shares.

    PROBLEM:
    Client machine IPL's without any problems.  All of the machines in 
the host network are accessible via ftp or telnet.  
    Several nfs mounts are mounted via the /etc/fstab, and mount without 
problems, and are useable
    A particular nfs mount point gets mounted by the automounter 
successfully via a file /etc/auto.ccwork.  No problems there.
    However, trying to access the same machine as above using the 
program /etc/auto.net, results in "No such file or directory".  
    No errors in /var/log/messages, nor in /var/adm/messages on the 
Solaris host.  I will attach the pertinent files.  
   
    Any suggestions with be greatly appreciated.  



/etc/auto.master
---------------------
/ccwork /etc/auto.ccwork        -retrans=10,rsize=8192,wsize=8192,timeo=15
/net    /etc/auto.net           
-nosuid,retrans=10,rsize=8192,wsize=8192,timeo=15 etc/nsswitch.conf

/etc/auto.ccwork
----------------------
ccStore19 dev3:/ccStore19
ccStore20 dev3:/ccStore20
ccStore16 dev3:/ccStore16
ccStore22 dev3:/ccStore22
ccStore21 dev3:/ccStore21

/etc/modules.conf
------------------------
alias eth0 tulip
alias parport_lowlevel parport_pc
alias usb-controller usb-uhci
alias autofs autofs4

/etc/rc.d/init.d/autofs status
-------------------------------------
Configured Mount Points:
------------------------
/usr/sbin/automount  /ccwork file /etc/auto.ccwork 
retrans=10,rsize=8192,wsize=8192,timeo=15
/usr/sbin/automount  /net program /etc/auto.net 
nosuid,retrans=10,rsize=8192,wsize=8192,timeo=15

Active Mount Points:
--------------------
/usr/sbin/automount /ccwork file /etc/auto.ccwork 
retrans=10,rsize=8192,wsize=8192,timeo=15
/usr/sbin/automount /net program /etc/auto.net 
nosuid,retrans=10,rsize=8192,wsize=8192,timeo=15

/etc/auto.net
----------------
#!/bin/sh

# $Id: //depot/autofs-4.0/samples/auto.net#4 $

# Look at what a host is exporting to determine what we can mount.
# This is very simple, but it appears to work surprisingly well

key="$1"

# add "nosymlink" here if you want to suppress symlinking local filesystems
opts="-fstype=nfs,hard,intr,nodev,nosuid"

# Showmount comes in a number of names and varieties.  "showmount" is
# typically an older version which accepts the '--no-headers' flag
# but ignores it.  "kshowmount" is the newer version installed with knfsd,
# which both accepts and acts on the '--no-headers' flag.
#SHOWMOUNT="kshowmount --no-headers -e $key"
#SHOWMOUNT="showmount -e $key | tail +2"

# Newer distributions get this right
SHOWMOUNT="showmount --no-headers -e $key"

$SHOWMOUNT | sort +0 | \
        awk -v key="$key" -v opts="$opts" -- '
        BEGIN           { ORS=""; print opts }
                        { print " \\\n\t" $1, key ":" $1 }
        END             { print "\n" }
        '

mount
---------
/dev/hda1 on / type ext3 (rw)
none on /proc type proc (rw)
usbdevfs on /proc/bus/usb type usbdevfs (rw)
/dev/hda7 on /private type ext3 (rw)
/dev/hda5 on /usr type ext3 (rw)
none on /dev/shm type tmpfs (rw)
none on /dev/pts type devpts (rw,gid=5,mode=620)
automount(pid837) on /net type autofs 
(rw,fd=5,pgrp=837,minproto=2,maxproto=4)
automount(pid835) on /ccwork type autofs 
(rw,fd=5,pgrp=835,minproto=2,maxproto=4)
nas1:/shared on /osd type nfs 
(rw,retrans=10,rsize=8192,wsize=8192,timeo=15,bg,addr=10.200.10.2)
nas1:/h11 on /home/h11 type nfs 
(rw,retrans=10,rsize=8192,wsize=8192,timeo=15,bg,addr=10.200.10.2)
nas1:/h12 on /home/h12 type nfs 
(rw,retrans=10,rsize=8192,wsize=8192,timeo=15,bg,addr=10.200.10.2)
nas1:/h13 on /home/h13 type nfs 
(rw,retrans=10,rsize=8192,wsize=8192,timeo=15,bg,addr=10.200.10.2)
dev3:/ccStore19 on /ccwork/ccStore19 type nfs 
(rw,retrans=10,rsize=8192,wsize=8192,timeo=15,addr=10.200.10.4)

/etc/nsswitch.conf (comments removed)
----------------------------------------------------
passwd:     files nis
shadow:     files nis
group:      files nis
hosts:      files nis dns
bootparams:  files nis
ethers:     files nis
netmasks:   files nis
networks:   files nis
protocols:  files nis
rpc:        files nis
services:   files nis
netgroup:   files nis
publickey:  files nis
automount:  files
aliases:    files nis




_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
