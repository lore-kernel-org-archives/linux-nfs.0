Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:36544 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1727676AbeITAwq (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 19 Sep 2018 20:52:46 -0400
Date: Wed, 19 Sep 2018 15:13:26 -0400
From: "'J. Bruce Fields'" <bfields@fieldses.org>
To: =?utf-8?B?SsOka2VsLA==?= Guido <G.Jaekel@dnb.de>
Cc: 'Jeff Layton' <jlayton@kernel.org>,
        "'linux-nfs@vger.kernel.org'" <linux-nfs@vger.kernel.org>
Subject: Re: Bump: NFS3 subsystem hung, Kernel alive
Message-ID: <20180919191326.GA14422@fieldses.org>
References: <069801bdc6004814ba33d69eb888c575@dnb.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
In-Reply-To: <069801bdc6004814ba33d69eb888c575@dnb.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

That just looks hard to debug, unfortunately.  Have you tried asking
Netapp, or do you have a support contract for your Linux clients?  Was
there an older kernel that worked OK?

--b.

On Wed, Sep 19, 2018 at 06:58:06AM +0000, Jäkel, Guido wrote:
> Dear NFS Maintainers,
> 
> I really please for your help!
> 
> In the meanwhile, I changed to Kernel 4.14.61 , but the issue remains. Yesterday, one of our two Bladeservers used for Production "freeze" two times with a gap of about 1h. I think that the freeze was caused by an event in a customer usecase and because it probably failed it was tried again. 
> 
> In the situation of freeze, the NFS subsystem stops working, but all other things continue to run "fine" -- up to the point a process need to access a file (which is not in the cache?). This is especially bad because all of the service checks based on simple "network communication" are still green. You might even build up a ssh session or enter an login at console: This works fine up to the point where the userland need to access a file (something like /etc/{passwd,groups,shadow} or some rc files used by the shell)
> 
> The "last indirect sign of live" is a clear I/O peak recorded by a monitoring system (Zabbix): There last recorded measuring point is about 80MBps "In"-Traffic on the NIC used for communication (eth1) and a corresponding "Out"-Peak on the NIC used for NFS -- with other words something like a upload where a stream coming in via "network" is stored to a file.
> 
> With greetings
> 
> Guido
> 
> >-----Original Message-----
> >From: Jäkel, Guido
> >Sent: Friday, June 22, 2018 12:27 PM
> >To: 'J. Bruce Fields' <bfields@fieldses.org>; 'Jeff Layton' <jlayton@kernel.org>
> >Cc: 'linux-nfs@vger.kernel.org' <linux-nfs@vger.kernel.org>
> >Subject: NFS3 subsystem hung, Kernel alive
> >
> >Dear NFS Maintainers,
> >
> >I'm using diskless bladeservers with PXE-Boot, NFS3 for the RootFS and others. This bladeservers are stuffed with LXC to run
> >containers with out applications.
> >
> >I'm watching a complete freeze of the NFS3 client. It has happened for some while about one a week. Using "binary splitting" of
> >the workload, it take a lot of time to trace down a trigger. But since yesterday, I was able to isolate it. By running an users
> >ordinary, unspecial batch job (a "traditional" command line bash sorting some GB-large file with sort, /tmp is on NFS, too).
> >Because the NFS-client freeze, the system can't load any uncached userland binary for inspection. No logs may be written for the
> >same reason. But the system and kernel is full-alive, it may be pinged for instance.
> >
> >We're using a whole bunch of bladeservers and rackservers, but there are just three different hardware models at the moment. The
> >Issue occurs on an older IBM X3550 rackserver. This have two 1GBit onboad NICs ("Ethernet controller: Broadcom Limited NetXtreme
> >II BCM5709 Gigabit Ethernet (rev 20)"). One of them is used for the NFS-Filesystem-IO, the other for the application traffic.
> >While performing the merge phase of the sort, the "filesystem NIC" is "overbooked at limit", because the external NetApp NFS
> >filer allows about 400Mbyte write bandwith even as the worst case lower limit)
> >
> >I was not able to reproduce the hung, if I start the corresponding container and the job on our main Cisco UCS blades. This
> >blade hardware has 10GBit link to the chassis and a 40GBit upstream links to the core switch. From that, here the File-ID-
> >Bandwith is just limited by the filer. And the NIC hardware (Cisco Systems Inc VIC Ethernet NIC) and Linux driver are different,
> >too. But all other like kernel image or used software is exactly the same, because this is all shared via NFS.
> >
> >I just was able to take a photo from the console output of the Sys-Magic-Tool (w). There are NFS RPC tasks waiting for some bit.
> >And one resulting from the hung_task_timer.
> >
> >
> >Current Kernel:
> >
> >	root@xrunner0 ~ # uname -a
> >	Linux xrunner0 4.14.43-gentoo #3 SMP Thu May 24 12:58:31 CEST 2018 x86_64 Intel(R) Xeon(R) CPU E5530 @ 2.40GHz
> >GenuineIntel GNU/Linux
> >
> >
> >RootFS-mount for the hosting blade:
> >
> >	root@xrunner0 ~ # mount | grep "on / "
> >	10.69.XXX.XXX:/02/q/diskless/roots/xrunner0 on / type
> >nfsv(rw,relatime,vers=3,rsize=65536,wsize=65536,namlen=255,hard,nolock,proto=tcp,timeo=600,retrans=2,sec=sys,mountaddr=10.69.XXX
> >.XXX,mountvers=3,
> >mountproto=tcp,local_lock=all,addr=10.69.XXX.XXX)
> >
> >
> >
> >RootFS-mount for the container:
> >
> >	root@evalaene0 ~ # mount | grep "on / "
> >	netapp2:/09/q/diskless/roots/evalaene0 on / type nfs
> >(rw,relatime,vers=3,rsize=65536,wsize=65536,namlen=255,hard,proto=tcp,timeo=600,retrans=2,sec=sys,local_lock=none,addr=10.69.XXX
> >.XXX)
> >
> >
> >The testcase:
> >
> >Input file about 6GB of short lines, it's not much filtering out; sort will write about 6GB input files as /tmp/sort*, too. The
> >freeze happens while merging down the sort* files.
> >
> >	jaekel@evalaene0 ~ $ cat MarcZwiGND-1.2.csv | grep "\^\^[0-9]" | sed 's/\s/_/g' | sed 's/~#/~ #/g' | sed 's/\~\s#$//g' |
> >awk '{ for (i=2;i<=NF;i++) {print $1" "$i}}'| sed 's/\~$//g' | sed 's/\(.*\)\~\s\#\(.*\)\^\^\([0-9X\-]*\)$/"\1"; ;"\2"; ;"\3"/'
> >| grep "\".*; ;\".*\"; ;\"[0-9]" | sort -k3 | sed 's/; ;/ /' > MarcZwiGND-1.out.csv
> >
> >Unfortunately, attaching strace seem to hide the issue.
> >
> >
> >Please ask for any more info you need.
> >
> >
> >Greetings
> >
> >Guido
> >
> >--
> >***Lesen. Hören. Wissen. Deutsche Nationalbibliothek***
> >
> >Dr. Guido Jäkel
> >Deutsche Nationalbibliothek
> >Informationsinfrastruktur / Rechenzentrum / Infrastruktur Unix
> >Adickesallee 1
> >60322 Frankfurt am Main
> >Tel: +49 69 1525 -1750
> >mailto:g.jaekel@dnb.de
> >http://www.dnb.de
> 
