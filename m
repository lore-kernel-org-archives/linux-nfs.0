From: wlutter@geology.wisc.edu (Bill Lutter)
Subject: I need advice on a firewall/nfs linux issue
Date: Thu, 28 Aug 2003 14:26:28 -0500 (CDT)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20030828192628.6325920D02@ice.geology.wisc.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: wlutter@geology.wisc.edu (Bill Lutter)
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 19sSNS-0005PO-00
	for <nfs@lists.sourceforge.net>; Thu, 28 Aug 2003 12:24:14 -0700
Received: from ice.geology.wisc.edu ([144.92.206.14])
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.22)
	id 19sSNS-0003Vp-0k
	for nfs@lists.sourceforge.net; Thu, 28 Aug 2003 12:24:14 -0700
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

I'd like advice on a NFS/firewall problem. Any suggestions
would be useful (we've tried version# of NFS using UDP
and the usual adjustments of parameters in the NFS
client (fstab, vfstab) and server (dfstab, exports) files
without success.

SUMMARY:  linux to linux or linux to unix server-client pairs
work fine when they are all together behind a firewall. (SONICWALL).

Unfortunately, we have 5 computers in two different buildings.
We use a SONICWALL firewall device to protect each group
of computers (one for each building). Each group of machines
runs a mix of linux (Redhat8.0) and unix (Solaris).

In a nutshell, with the firewall, unix servers works ok
and  linux servers foul up.   The problem manifests
itself in several ways:
a) ls command works up to a certain path length
and then hangs.
b) ls specific_file works (ls dmx.S001) but
ls wildcard hangs (ls dmx.S*).
c) cp command hangs.

Take away the firewall and everything is ok.

Contents below:
I. Details:
II. Machine Details:
III. Some client/server pairs work (two SONICWALL devices in between):
IV.  Some client/server pairs don't work out
V. rpcinfo output

Any ideas?
bill lutter
wlutter@geology.wisc.edu


I. Details:
To make the problem description more specific:
Machines in building #1 behind one firewall device:
unix: omega
linux: gamma
Machines in building #2 behind a firewall device:
unix: tau
linux: mu

II. Machine Details:
Linux setups:
Running Redhat 8.0; NFS version#2 (at least it says this on the man page)
1) mu: uname -a
Linux mu 2.4.20-19.8 #1 Tue Jul 15 15:25:37 EDT 2003 i686 i686 i386
GNU/Linux
2) gamma: uname -a
Linux gamma 2.4.18-14 #1 Wed Sep 4 13:35:50 EDT 2002 i686 i686 i386
GNU/Linux

Unix setups: (I'm not sure which nfs version is default).
1) omega: uname -a
SunOS esp 5.7 Generic_106541-23 sun4u sparc SUNW,Ultra-60
2) tau: uname -a
SunOS tau 5.7 Generic_106541-23 sun4u sparc SUNW,Ultra-5_10

Firewall setups:
SONICWALL: We allow everything between the two buildings
(two groups of machines) and limit other access.

III. Some client/server pairs work (two SONICWALL devices in between):
1) unix server/linux client works fine.
2) unix_server/unix_client OK


IV.  Some client/server pairs don't work out
1) linux_server/linux_client
a) linux server is called mu, linux client called gamma

b) exports line on mu:
/Ldata6                  gamma(rw,insecure,sync)

c) fstab line on gamma:
mu:/Ldata6              /Ldata6                 nfs     rw,bg,intr,soft 0 0

d) It doesn't work.
Example One can do a cd and a ls of a specific file, but wildcard bombs!
[fetus@gamma /etc]$ cd /Ldata6/NMEG/n2003/179/nLongDrt/ca7_23/1
[fetus@gamma 1]$ pwd
/Ldata6/NMEG/n2003/179/nLongDrt/ca7_23/1
[fetus@gamma 1]$ ls dmx.S001
dmx.S001
[fetus@gamma 1]$ ls *
ls: No match.

e) cp problem (small file ok, large file hangs (zero-length file)
[fetus@gamma 1]$ cp set
[fetus@gamma 1]$ ls -l set dmx.S001
-rw-rw-r--    1 fetus    staff         279 Aug 20 10:35 set
-rw-rw-r--    1 fetus    staff     1453676 Aug 20 10:36 dmx.S001
[fetus@gamma 1]$ cp set  /Ldata1/WJL     - works ok
[fetus@gamma 1]$ cp dmx.S001 /Ldata1/WJL
cp: reading `dmx.S001': Input/output error
[fetus@gamma 1]$`

2. linux_server/unix client
a) linux server is mu, unix client is omega
b) exports line on mu:
/Ldata6                  omega(rw,insecure,sync)
c) vfstab line on omega:
mu:/Ldata6            -                          /Ldata6         nfs     -
yes     bg
d)  ls crashes and burns depending on length of path:
omega fetus $ cd /Ldata6/NMEG
omega fetus $ ls
n2003/
omega fetus $ cd n2003
omega fetus $ ls
NFS server mu not responding still trying

SHOULD BE:
cd n2003; ls
116  161  170  179  186  191  198  ReadmeNew  tar.179  tar.191  tar.198
152  164  173  181  187  196  208  tar.170    tar.181  tar.196

e) example with cp (small file ok, large file hangs)
ssh omega (client)
cp from /Ldata6 (linux server) to an omega (client) disk
cd /Ldata6/NMEG/n2003/179/nLongDrt/ca7_23/1
ls set dmx.S001
-rw-rw-r--   1 fetus    staff    1453676 Aug 20 10:36 dmx.S001
-rw-rw-r--   1 fetus    staff        279 Aug 20 10:35 set
cp set /data5   - thiw works ok
cp dmx.S001 /data5  -  this hangs (zero-length file)
(cp hangs with message: NFS server mu not responding still trying)

V. rpcinfo output
run on linux server mu:
rpcinfo -p gamma
program vers proto   port
    100000    2   tcp    111  portmapper
    100000    2   udp    111  portmapper
    100021    1   udp  32769  nlockmgr
    100021    3   udp  32769  nlockmgr
    100021    4   udp  32769  nlockmgr
    391002    2   tcp  32769  sgi_fam
    100011    1   udp    848  rquotad
    100011    2   udp    848  rquotad
    100011    1   tcp    851  rquotad
    100011    2   tcp    851  rquotad
    100003    2   udp   2049  nfs
    100003    3   udp   2049  nfs
    100005    1   udp  32770  mountd
    100005    1   tcp  32770  mountd
    100005    2   udp  32770  mountd
    100005    2   tcp  32770  mountd
    100005    3   udp  32770  mountd
    100005    3   tcp  32770  mountd
    100024    1   udp  32995  status
    100024    1   tcp  55242  status

rpcinfo -p omega
sudo rpcinfo -p omega
   program vers proto   port
    100000    4   tcp    111  portmapper
    100000    3   tcp    111  portmapper
    100000    2   tcp    111  portmapper
    100000    4   udp    111  portmapper
    100000    3   udp    111  portmapper
    100000    2   udp    111  portmapper
    100004    2   udp    791  ypserv
    100004    1   udp    791  ypserv
    100004    1   tcp    792  ypserv
    100004    2   tcp  32771  ypserv
1073741824    2   udp  32772
    100007    3   udp  32780  ypbind
    100007    2   udp  32780  ypbind
    100007    1   udp  32780  ypbind
    100007    3   tcp  32772  ypbind
    100069    1   udp  32781  ypxfrd
    100007    2   tcp  32772  ypbind
    100069    1   tcp  32773  ypxfrd
    100007    1   tcp  32772  ypbind
    100009    1   udp    806  yppasswdd
    100028    1   tcp    808  ypupdated
    100028    1   udp    809  ypupdated
    100021    1   udp   4045  nlockmgr
    100021    2   udp   4045  nlockmgr
    100021    3   udp   4045  nlockmgr
    100021    4   udp   4045  nlockmgr
    100024    1   udp  32783  status
    100230    1   tcp  32774
    100024    1   tcp  32775  status
    100133    1   udp  32783
    100133    1   tcp  32775
    100021    1   tcp   4045  nlockmgr
    100021    2   tcp   4045  nlockmgr
    100021    3   tcp   4045  nlockmgr
    100021    4   tcp   4045  nlockmgr
    100005    1   udp  32849  mountd
    100005    2   udp  32849  mountd
    100005    3   udp  32849  mountd
    100005    1   tcp  32800  mountd
    100005    2   tcp  32800  mountd
    100005    3   tcp  32800  mountd
    100003    2   udp   2049  nfs
    100003    3   udp   2049  nfs
    100227    2   udp   2049  nfs_acl
    100227    3   udp   2049  nfs_acl
    100003    2   tcp   2049  nfs
    100003    3   tcp   2049  nfs
    100227    2   tcp   2049  nfs_acl
    100227    3   tcp   2049  nfs_acl
1289637087    5   tcp  55292
1289637087    1   tcp  55292
1289637088    5   tcp  55708
1289637088    1   tcp  55708
1289637086    5   tcp  36725
1289637086    1   tcp  36725



Any ideas?
bill lutter
wlutter@geology.wisc.edu

-- 
Bill Lutter                    University of Wisconsin  
Dept. of Medical Physics       Phone: (608) 263-5983
Dept. of Geology & Geophysics  Phone: (608) 262-1921
Email:                         wlutter@geology.wisc.edu
Mailing address:               115 Weeks Hall    
                               1215 W. Dayton St.  
                               Madison, Wi  53706-1692


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
