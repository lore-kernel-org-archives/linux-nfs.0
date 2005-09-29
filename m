From: Reuti <reuti@staff.uni-marburg.de>
Subject: Re: rpc.mountd at 99% cpu
Date: Thu, 29 Sep 2005 21:35:33 +0200
Message-ID: <20050929213533.koygqlpb3hy8ogsg@home.staff.uni-marburg.de>
References: <433C3C87.4040401@anl.gov>
Mime-Version: 1.0
Content-Type: text/plain;
	charset=ISO-8859-1;
	format="flowed"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1EL4C7-0003Av-Cb
	for nfs@lists.sourceforge.net; Thu, 29 Sep 2005 12:35:51 -0700
Received: from vhrz24.hrz.uni-marburg.de ([137.248.1.34])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1EL4C5-0006w3-BM
	for nfs@lists.sourceforge.net; Thu, 29 Sep 2005 12:35:51 -0700
Received: from localhost (vhrz78.HRZ.Uni-Marburg.DE [137.248.1.54])
	by vhrz24.hrz.uni-marburg.de (8.13.4/8.13.4/Debian-3) with ESMTP id j8TJZXba005816
	for <nfs@lists.sourceforge.net>; Thu, 29 Sep 2005 21:35:33 +0200
To: nfs@lists.sourceforge.net
In-Reply-To: <433C3C87.4040401@anl.gov>
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

Brian,

is there a file system mounted in /proc/nfs/nfsd - then nfsd is working 
in a new
mode? You can try *not* to mount it in the start/stop-script of the NFS 
server.
This way you will force nsfd to operate in a legacy mode. If you followed my
posts last week, this solved a problem with stale file handles for me.

Cheers - Reuti


Zitat von Brian Elliott Finley <finley@anl.gov>:

> I've got an nfs server (quad cpu amd64, 36G mem, failover fiberchannel)
> running ubuntu, and I'm getting the following behavior that I haven't
> been able to track down yet:
>
>    * rpc.mountd spikes to 99% cpu usage when a client machine mounts,
>      causing a temporary disruption in service to all client systems
>
> Google, NFS Howtos, NFS Perf Tuning docs, IRC (can't find an NFS
> specific IRC channel), local sysadmins all turn up nothing so far.  Here
> are potentially relavant data:
>
>    * exportfs -v -o rw,secure,sync,no_root_squash
>      10.10.0.0/255.255.0.0:/export/home
>    * nfs server has all clients info in /etc/hosts
>    * /etc/hosts is first in nsswitch.conf
>    * kernel is ubuntu's: linux-image-2.6.10-5-amd64-k8-smp
>    * nfs performance is fine once a filesystem is mounted
>    * unless, someone else is mounting a filesystem, in which case
>      already mounted filesystems
>    * only 8 clients
>    * home directories mounted by autofs on clients as
>      server:/export/home/bob /home/bob
>    * 32 nfsd threads
>    * % netstat -in
>      Kernel Interface table
>      Iface   MTU Met   RX-OK RX-ERR RX-DRP RX-OVR   TX-OK TX-ERR TX-DRP
>      TX-OVR Flg
>      eth0   1500 0  247854230      0      0      0324570001      0
>      0      0 BMRU
>      eth1   1500 0  1022171197      0      0      0258643880
>      0      0      0 BMR U
>      lo    16436 0    419024      0      0      0  419024      0
>      0      0 LRU
>    * % cat /proc/net/rpc/nfsd | grep ^th
>      th 32 8229 13759.142 6537.314 1919.479 4.212 129.977 52.636 11.780
>      10.231 0.000 101.321
>    * caching bind9 installed on server, and it points to itself for
>      first nameserver entry
>
> Any one know what's up here?  Or how I can tell what's making rpc.mountd
> take so much time?
>
> --
> Brian Elliott Finley
> Linux Strategist, CIS
> Desk: 630.252.4742
> Cell: 630.631.6621
>
>
>
> -------------------------------------------------------
> This SF.Net email is sponsored by:
> Power Architecture Resource Center: Free content, downloads, discussions,
> and more. http://solutions.newsforge.com/ibmarch.tmpl
> _______________________________________________
> NFS maillist  -  NFS@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/nfs
>





-------------------------------------------------------
This SF.Net email is sponsored by:
Power Architecture Resource Center: Free content, downloads, discussions,
and more. http://solutions.newsforge.com/ibmarch.tmpl
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
