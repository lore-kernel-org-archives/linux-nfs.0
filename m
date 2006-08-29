From: "Brent Franks" <brentasterisk@gmail.com>
Subject: NFS Server, Buffer Cache Utilization
Date: Tue, 29 Aug 2006 11:54:50 -0400
Message-ID: <32fc08be0608290854j191bbe6fn74e0fb6a721d70f9@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============1459654155=="
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GI5vU-0002Ix-9v
	for nfs@lists.sourceforge.net; Tue, 29 Aug 2006 08:54:56 -0700
Received: from nf-out-0910.google.com ([64.233.182.189])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1GI5vT-0003Sv-Cd
	for nfs@lists.sourceforge.net; Tue, 29 Aug 2006 08:54:57 -0700
Received: by nf-out-0910.google.com with SMTP id l36so250372nfa
	for <nfs@lists.sourceforge.net>; Tue, 29 Aug 2006 08:54:50 -0700 (PDT)
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

--===============1459654155==
Content-Type: multipart/alternative;
	boundary="----=_Part_11159_1488442.1156866890268"

------=_Part_11159_1488442.1156866890268
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

Hello,

We are running NFS v3 that is stock with CentOS release 4.3 (Final).  We are
also currently running the following kernel: 2.6.9-42.0.2.ELsmp #1 SMP on a
Dell Poweredge 2850.  The box has 4Gigs of ram and is currently exposing nfs
shares to 12 web servers (the nfs clients).  We are using local 10k Scsi
discs and have found that the server is IO Waiting the majority of the time,
which has inturn pushed our load average up.

Because the box has 4gigs of ram, we began digging around and found that the
box is only currently using about 1Gig of Ram (See Below)

Is this a limitation of NFS server or is there a configuation change we can
make to allow the box to use more RAM for the cache buffer?  I've searched
the lists a lot, but everything I found relates to 2.2 and 2.4 kernels.  Any
help would be greatly appreciated.

Thanks,

- Brent


[root@fs:/proc/sys/vm] cat /proc/meminfo
MemTotal:      4151296 kB
MemFree:       3034188 kB
Buffers:        474708 kB
Cached:         196092 kB
SwapCached:          0 kB
Active:         265440 kB
Inactive:       445844 kB
HighTotal:     3276544 kB
HighFree:      3019328 kB
LowTotal:       874752 kB
LowFree:         14860 kB
SwapTotal:     4192956 kB
SwapFree:      4192956 kB
Dirty:           15644 kB
Writeback:           0 kB
Mapped:          50752 kB
Slab:           356976 kB
CommitLimit:   6268604 kB
Committed_AS:   195416 kB
PageTables:       1888 kB
VmallocTotal:   106488 kB
VmallocUsed:     32744 kB
VmallocChunk:    71984 kB
HugePages_Total:     0
HugePages_Free:      0
Hugepagesize:     2048 kB

------=_Part_11159_1488442.1156866890268
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

Hello,<br><br>We are running NFS v3 that is stock with CentOS release 4.3 (Final).&nbsp; We are also currently running the following kernel: 2.6.9-42.0.2.ELsmp #1 SMP on a Dell Poweredge 2850.&nbsp; The box has 4Gigs of ram and is currently exposing nfs shares to 12 web servers (the nfs clients).&nbsp; We are using local 10k Scsi discs and have found that the server is IO Waiting the majority of the time, which has inturn pushed our load average up.
<br><br>Because the box has 4gigs of ram, we began digging around and found that the box is only currently using about 1Gig of Ram (See Below)<br><br>Is this a limitation of NFS server or is there a configuation change we can make to allow the box to use more RAM for the cache buffer?&nbsp; I've searched the lists a lot, but everything I found relates to 
2.2 and 2.4 kernels.&nbsp; Any help would be greatly appreciated.<br><br>Thanks,<br><br>- Brent<br><br><br>[root@fs:/proc/sys/vm] cat /proc/meminfo<br>
MemTotal:&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 4151296 kB<br>
MemFree:&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 3034188 kB<br>
Buffers:&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 474708 kB<br>
Cached:&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 196092 kB<br>
SwapCached:&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 0 kB<br>
Active:&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 265440 kB<br>
Inactive:&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 445844 kB<br>
HighTotal:&nbsp;&nbsp;&nbsp;&nbsp; 3276544 kB<br>
HighFree:&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 3019328 kB<br>
LowTotal:&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 874752 kB<br>
LowFree:&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 14860 kB<br>
SwapTotal:&nbsp;&nbsp;&nbsp;&nbsp; 4192956 kB<br>
SwapFree:&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 4192956 kB<br>
Dirty:&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 15644 kB<br>
Writeback:&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 0 kB<br>
Mapped:&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 50752 kB<br>
Slab:&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 356976 kB<br>
CommitLimit:&nbsp;&nbsp; 6268604 kB<br>
Committed_AS:&nbsp;&nbsp; 195416 kB<br>
PageTables:&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 1888 kB<br>
VmallocTotal:&nbsp;&nbsp; 106488 kB<br>
VmallocUsed:&nbsp;&nbsp;&nbsp;&nbsp; 32744 kB<br>
VmallocChunk:&nbsp;&nbsp;&nbsp; 71984 kB<br>
HugePages_Total:&nbsp;&nbsp;&nbsp;&nbsp; 0<br>
HugePages_Free:&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 0<br>
Hugepagesize:&nbsp;&nbsp;&nbsp;&nbsp; 2048 kB<br>

------=_Part_11159_1488442.1156866890268--


--===============1459654155==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
--===============1459654155==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--===============1459654155==--
