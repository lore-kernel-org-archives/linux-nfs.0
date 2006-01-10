From: "Pelle Svensson" <pelle2004@hotmail.com>
Subject: NFS client getting server not responding on kernel 2.6.15 with nfs-client-patch
Date: Tue, 10 Jan 2006 17:20:53 +0100
Message-ID: <BAY7-F206E8494F3B5CB3B898ABCB9250@phx.gbl>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1; format=flowed
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1EwMFp-0005Kw-B6
	for nfs@lists.sourceforge.net; Tue, 10 Jan 2006 08:21:49 -0800
Received: from bay7-f20.bay7.hotmail.com ([64.4.11.45] helo=hotmail.com)
	by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1EwMFn-00047f-Cv
	for nfs@lists.sourceforge.net; Tue, 10 Jan 2006 08:21:49 -0800
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

I'm running a 2.6.15 client on a small ARM embedded platform with the root 
system as NFS client
(root=/dev/nfs). The server is Fedora core 3.

I'm getting about 2 to 6 errors as below on the first larger operation on 
the ARM system after
booting the system. Smaller this like #echo "dof to file" >/tmp/dog is okay

nfs: server 192.168.x.x not responding, still trying.
nfs: server 192.168.x.x not responding, still trying.
nfs: server 192.168.x.x not responding, still trying.

This happens when I read a lot from the server and at the same time try's to 
write that back as an
image file. Looking at the output from Ethereal shows that all 'V2 Read ...' 
request gets an answer
from the server but when the client issu the first section of 'V2 Write ...' 
there are no answers.
After a short while the client retransmitt same request in a loop.

The command I use is 'mkfs.jffs2' which reads a image of the root system and 
writes that
into a image file. Reads about 46M and supose to writes about 20M.

Any ideas what to do next?

Server: Fedora core 2.6.11-1.14_FC3smp
Client: ARM cpu 2.6.15 + 
http://client.linux-nfs.org/Linux-2.6.x/2.6.15/linux-2.6.15-NFS_ALL.dif
/etc/ecpotrs: target(rw,async,no_root_squash)  #have also tired with 'sync'
/proc/fs/nfs/exports: target(rw,no_root_squash,async,wdelay)

Log:


Part of the beginning

   1970 0.000103    192.168.x.xx          192.168.y.yyy         NFS      V2 
READDIR Reply (Call In 1969)
   1971 0.002627    192.168.y.yyy         192.168.x.xx          NFS      V2 
LOOKUP Call (Reply In 1972), DH:0xb403a572/ca-bundle.crt
   1972 0.000087    192.168.x.xx          192.168.y.yyy         NFS      V2 
LOOKUP Reply (Call In 1971), FH:0x39b6ba7c
   1973 0.003250    192.168.y.yyy         192.168.x.xx          NFS      V2 
LOOKUP Call (Reply In 1974), DH:0xa4038f72/var
   1974 0.000084    192.168.x.xx          192.168.y.yyy         NFS      V2 
LOOKUP Reply (Call In 1973), FH:0xa4038f72
   1975 0.003949    192.168.y.yyy         192.168.x.xx          NFS      V2 
GETATTR Call (Reply In 1976), FH:0xa4038f72
   1976 0.000084    192.168.x.xx          192.168.y.yyy         NFS      V2 
GETATTR Reply (Call In 1975)
   1977 0.001940    192.168.y.yyy         192.168.x.xx          NFS      V2 
READDIR Call (Reply In 1978), FH:0xa4038f72
   1978 0.000101    192.168.x.xx          192.168.y.yyy         NFS      V2 
READDIR Reply (Call In 1977)
   1979 0.002557    192.168.y.yyy         192.168.x.xx          NFS      V2 
LOOKUP Call (Reply In 1980), DH:0xa4038f72/log
   1980 0.000091    192.168.x.xx          192.168.y.yyy         NFS      V2 
LOOKUP Reply (Call In 1979), FH:0xac038f72
   1981 0.003868    192.168.y.yyy         192.168.x.xx          NFS      V2 
GETATTR Call (Reply In 1982), FH:0xac038f72
   1982 0.000132    192.168.x.xx          192.168.y.yyy         NFS      V2 
GETATTR Reply (Call In 1981)
   1983 0.001721    192.168.y.yyy         192.168.x.xx          NFS      V2 
READDIR Call (Reply In 1984), FH:0xac038f72
   1984 0.000097    192.168.x.xx          192.168.y.yyy         NFS      V2 
READDIR Reply (Call In 1983)
   1985 0.002641    192.168.y.yyy         192.168.x.xx          NFS      V2 
LOOKUP Call (Reply In 1986), DH:0xac038f72/hotplug-events
   1986 0.000086    192.168.x.xx          192.168.y.yyy         NFS      V2 
LOOKUP Reply (Call In 1985), FH:0x3a44b07c
   1987 0.003268    192.168.y.yyy         192.168.x.xx          NFS      V2 
LOOKUP Call (Reply In 1988), DH:0xac038f72/hotplug-events-d
   1988 0.000083    192.168.x.xx          192.168.y.yyy         NFS      V2 
LOOKUP Reply (Call In 1987), FH:0x3a44b07c
   1989 0.003480    192.168.y.yyy         192.168.x.xx          NFS      V2 
LOOKUP Call (Reply In 1990), DH:0xac038f72/messages
   1990 0.000083    192.168.x.xx          192.168.y.yyy         NFS      V2 
LOOKUP Reply (Call In 1989), FH:0x5244b07c
   1991 0.004388    192.168.y.yyy         192.168.x.xx          NFS      V2 
GETATTR Call (Reply In 1992), FH:0x3a44b07c
   1992 0.000083    192.168.x.xx          192.168.y.yyy         NFS      V2 
GETATTR Reply (Call In 1991)
   1993 0.003990    192.168.y.yyy         192.168.x.xx          NFS      V2 
GETATTR Call (Reply In 1994), FH:0x2244b07c
   1994 0.000089    192.168.x.xx          192.168.y.yyy         NFS      V2 
GETATTR Reply (Call In 1993)
   1995 0.002263    192.168.y.yyy         192.168.x.xx          NFS      V2 
READ Call (Reply In 1996), FH:0x2244b07c Offset:0 Count:21 TotalCount:21
   1996 0.000095    192.168.x.xx          192.168.y.yyy         NFS      V2 
READ Reply (Call In 1995)
   1997 0.012551    192.168.y.yyy         192.168.x.xx          NFS      V2 
GETATTR Call (Reply In 1998), FH:0xec44b07c
   1998 0.000094    192.168.x.xx          192.168.y.yyy         NFS      V2 
GETATTR Reply (Call In 1997)
   1999 0.002293    192.168.y.yyy         192.168.x.xx          NFS      V2 
READ Call (Reply In 2000), FH:0xec44b07c Offset:0 Count:4096 TotalCount:4096
   2000 0.000106    192.168.x.xx          192.168.y.yyy         NFS      V2 
READ Reply (Call In 1999)[Unreassembled Packet]
   2001 0.000009    192.168.x.xx          192.168.y.yyy         IP       
Fragmented IP protocol (proto=UDP 0x11, off=1480)
   2002 0.000008    192.168.x.xx          192.168.y.yyy         IP       
Fragmented IP protocol (proto=UDP 0x11, off=2960)
   2003 0.002706    192.168.y.yyy         192.168.x.xx          NFS      V2 
READ Call (Reply In 2004), FH:0xec44b07c Offset:4096 Count:4096 
TotalCount:4096
   2004 0.000138    192.168.x.xx          192.168.y.yyy         NFS      V2 
READ Reply (Call In 2003)[Unreassembled Packet]
   2005 0.000008    192.168.x.xx          192.168.y.yyy         IP       
Fragmented IP protocol (proto=UDP 0x11, off=1480)
   2006 0.000008    192.168.x.xx          192.168.y.yyy         IP       
Fragmented IP protocol (proto=UDP 0x11, off=2960)
   2007 0.002584    192.168.y.yyy         192.168.x.xx          NFS      V2 
READ Call (Reply In 2008), FH:0xec44b07c Offset:8192 Count:4096 
TotalCount:4096
   2008 0.000110    192.168.x.xx          192.168.y.yyy         NFS      V2 
READ Reply (Call In 2007)[Unreassembled Packet]
   2009 0.000009    192.168.x.xx          192.168.y.yyy         IP       
Fragmented IP protocol (proto=UDP 0x11, off=1480)
   2010 0.000012    192.168.x.xx          192.168.y.yyy         IP       
Fragmented IP protocol (proto=UDP 0x11, off=2960)
   2011 0.028374    192.168.y.yyy         192.168.x.xx          NFS      V2 
READ Call (Reply In 2012), FH:0xec44b07c Offset:12288 Count:4096 
TotalCount:4096
   2012 0.000105    192.168.x.xx          192.168.y.yyy         NFS      V2 
READ Reply (Call In 2011)[Unreassembled Packet]
   2013 0.000010    192.168.x.xx          192.168.y.yyy         IP       
Fragmented IP protocol (proto=UDP 0x11, off=1480)
   2014 0.000007    192.168.x.xx          192.168.y.yyy         IP       
Fragmented IP protocol (proto=UDP 0x11, off=2960)
   2015 0.002496    192.168.y.yyy         192.168.x.xx          NFS      V2 
READ Call (Reply In 2016), FH:0xec44b07c Offset:16384 Count:4096 
TotalCount:4096
   2016 0.000100    192.168.x.xx          192.168.y.yyy         NFS      V2 
READ Reply (Call In 2015)[Unreassembled Packet]
   2017 0.000009    192.168.x.xx          192.168.y.yyy         IP       
Fragmented IP protocol (proto=UDP 0x11, off=1480)
   2018 0.000008    192.168.x.xx          192.168.y.yyy         IP       
Fragmented IP protocol (proto=UDP 0x11, off=2960)
   2019 0.002452    192.168.y.yyy         192.168.x.xx          NFS      V2 
READ Call (Reply In 2020), FH:0xec44b07c Offset:20480 Count:4096 
TotalCount:4096
   2020 0.000107    192.168.x.xx          192.168.y.yyy         NFS      V2 
READ Reply (Call In 2019)[Unreassembled Packet]
   2021 0.000009    192.168.x.xx          192.168.y.yyy         IP       
Fragmented IP protocol (proto=UDP 0x11, off=1480)


Where thing start to go wrong!

   7951 0.002594    192.168.y.yyy         192.168.x.xx          NFS      V2 
READ Call (Reply In 7952), FH:0xec44b07c Offset:6025216 Count:4096 
TotalCount:4096
   7952 0.000096    192.168.x.xx          192.168.y.yyy         NFS      V2 
READ Reply (Call In 7951)[Unreassembled Packet]
   7953 0.000009    192.168.x.xx          192.168.y.yyy         IP       
Fragmented IP protocol (proto=UDP 0x11, off=1480)
   7954 0.000008    192.168.x.xx          192.168.y.yyy         IP       
Fragmented IP protocol (proto=UDP 0x11, off=2960)
   7955 0.002596    192.168.y.yyy         192.168.x.xx          NFS      V2 
READ Call (Reply In 7956), FH:0xec44b07c Offset:6029312 Count:4096 
TotalCount:4096
   7956 0.000118    192.168.x.xx          192.168.y.yyy         NFS      V2 
READ Reply (Call In 7955)[Unreassembled Packet]
   7957 0.000013    192.168.x.xx          192.168.y.yyy         IP       
Fragmented IP protocol (proto=UDP 0x11, off=1480)
   7958 0.000008    192.168.x.xx          192.168.y.yyy         IP       
Fragmented IP protocol (proto=UDP 0x11, off=2960)
   7959 0.002636    192.168.y.yyy         192.168.x.xx          NFS      V2 
READ Call (Reply In 7960), FH:0xec44b07c Offset:6033408 Count:4096 
TotalCount:4096
   7960 0.000097    192.168.x.xx          192.168.y.yyy         NFS      V2 
READ Reply (Call In 7959)[Unreassembled Packet]
   7961 0.000008    192.168.x.xx          192.168.y.yyy         IP       
Fragmented IP protocol (proto=UDP 0x11, off=1480)
   7962 0.000009    192.168.x.xx          192.168.y.yyy         IP       
Fragmented IP protocol (proto=UDP 0x11, off=2960)
   7963 0.002490    192.168.y.yyy         192.168.x.xx          NFS      V2 
READ Call (Reply In 7964), FH:0xec44b07c Offset:6037504 Count:4096 
TotalCount:4096
   7964 0.000096    192.168.x.xx          192.168.y.yyy         NFS      V2 
READ Reply (Call In 7963)[Unreassembled Packet]
   7965 0.000009    192.168.x.xx          192.168.y.yyy         IP       
Fragmented IP protocol (proto=UDP 0x11, off=1480)
   7966 0.000008    192.168.x.xx          192.168.y.yyy         IP       
Fragmented IP protocol (proto=UDP 0x11, off=2960)
   7967 0.002479    192.168.y.yyy         192.168.x.xx          NFS      V2 
READ Call (Reply In 7968), FH:0xec44b07c Offset:6041600 Count:4096 
TotalCount:4096
   7968 0.000105    192.168.x.xx          192.168.y.yyy         NFS      V2 
READ Reply (Call In 7967)[Unreassembled Packet]
   7969 0.000009    192.168.x.xx          192.168.y.yyy         IP       
Fragmented IP protocol (proto=UDP 0x11, off=1480)
   7970 0.000008    192.168.x.xx          192.168.y.yyy         IP       
Fragmented IP protocol (proto=UDP 0x11, off=2960)
   7971 0.257546    192.168.y.yyy         192.168.x.xx          NFS      V2 
WRITE Call, FH:0x6a4be852 BeginOffset:0 Offset:0 
TotalCount:4096[Unreassembled Packet]
   7972 0.000133    192.168.y.yyy         192.168.x.xx          IP       
Fragmented IP protocol (proto=UDP 0x11, off=1480)
   7973 0.000100    192.168.y.yyy         192.168.x.xx          IP       
Fragmented IP protocol (proto=UDP 0x11, off=2960)
   7974 0.002110    192.168.y.yyy         192.168.x.xx          NFS      V2 
WRITE Call, FH:0x6a4be852 BeginOffset:4096 Offset:4096 
TotalCount:4096[Unreassembled Packet]
   7975 0.000123    192.168.y.yyy         192.168.x.xx          IP       
Fragmented IP protocol (proto=UDP 0x11, off=1480)
   7976 0.000105    192.168.y.yyy         192.168.x.xx          IP       
Fragmented IP protocol (proto=UDP 0x11, off=2960)
   7977 0.002186    192.168.y.yyy         192.168.x.xx          NFS      V2 
WRITE Call, FH:0x6a4be852 BeginOffset:8192 Offset:8192 
TotalCount:4096[Unreassembled Packet]
   7978 0.000123    192.168.y.yyy         192.168.x.xx          IP       
Fragmented IP protocol (proto=UDP 0x11, off=1480)
   7979 0.000104    192.168.y.yyy         192.168.x.xx          IP       
Fragmented IP protocol (proto=UDP 0x11, off=2960)
   7980 0.001902    192.168.y.yyy         192.168.x.xx          NFS      V2 
WRITE Call, FH:0x6a4be852 BeginOffset:12288 Offset:12288 
TotalCount:4096[Unreassembled Packet]
   7981 0.000122    192.168.y.yyy         192.168.x.xx          IP       
Fragmented IP protocol (proto=UDP 0x11, off=1480)
   7982 0.000105    192.168.y.yyy         192.168.x.xx          IP       
Fragmented IP protocol (proto=UDP 0x11, off=2960)
   7983 0.002163    192.168.y.yyy         192.168.x.xx          NFS      V2 
WRITE Call, FH:0x6a4be852 BeginOffset:16384 Offset:16384 
TotalCount:4096[Unreassembled Packet]
   7984 0.000122    192.168.y.yyy         192.168.x.xx          IP       
Fragmented IP protocol (proto=UDP 0x11, off=1480)
   7985 0.000105    192.168.y.yyy         192.168.x.xx          IP       
Fragmented IP protocol (proto=UDP 0x11, off=2960)
   7986 0.116140    192.168.y.yyy         192.168.x.xx          NFS      
[RPC retransmission of #7971]V2 WRITE Call, FH:0x6a4be852 BeginOffset:0 
Offset:0 TotalCount:4096[Unreassembled Packet]
   7987 0.000115    192.168.y.yyy         192.168.x.xx          IP       
Fragmented IP protocol (proto=UDP 0x11, off=1480)
   7988 0.000105    192.168.y.yyy         192.168.x.xx          IP       
Fragmented IP protocol (proto=UDP 0x11, off=2960)
   7989 0.239749    192.168.y.yyy         192.168.x.xx          NFS      
[RPC retransmission of #7974]V2 WRITE Call, FH:0x6a4be852 BeginOffset:4096 
Offset:4096 TotalCount:4096[Unreassembled Packet]
   7990 0.000122    192.168.y.yyy         192.168.x.xx          IP       
Fragmented IP protocol (proto=UDP 0x11, off=1480)
   7991 0.000105    192.168.y.yyy         192.168.x.xx          IP       
Fragmented IP protocol (proto=UDP 0x11, off=2960)
   7992 0.239658    192.168.y.yyy         192.168.x.xx          NFS      
[RPC retransmission of #7977]V2 WRITE Call, FH:0x6a4be852 BeginOffset:8192 
Offset:8192 TotalCount:4096[Unreassembled Packet]
   7993 0.000122    192.168.y.yyy         192.168.x.xx          IP       
Fragmented IP protocol (proto=UDP 0x11, off=1480)
   7994 0.000104    192.168.y.yyy         192.168.x.xx          IP       
Fragmented IP protocol (proto=UDP 0x11, off=2960)
   7995 0.239640    192.168.y.yyy         192.168.x.xx          NFS      
[RPC retransmission of #7980]V2 WRITE Call, FH:0x6a4be852 BeginOffset:12288 
Offset:12288 TotalCount:4096[Unreassembled Packet]
   7996 0.000126    192.168.y.yyy         192.168.x.xx          IP       
Fragmented IP protocol (proto=UDP 0x11, off=1480)
   7997 0.000100    192.168.y.yyy         192.168.x.xx          IP       
Fragmented IP protocol (proto=UDP 0x11, off=2960)
   7998 0.239639    192.168.y.yyy         192.168.x.xx          NFS      
[RPC retransmission of #7983]V2 WRITE Call, FH:0x6a4be852 BeginOffset:16384 
Offset:16384 TotalCount:4096[Unreassembled Packet]
   7999 0.000120    192.168.y.yyy         192.168.x.xx          IP       
Fragmented IP protocol (proto=UDP 0x11, off=1480)
   8000 0.000105    192.168.y.yyy         192.168.x.xx          IP       
Fragmented IP protocol (proto=UDP 0x11, off=2960)
   8001 0.239452    192.168.y.yyy         192.168.x.xx          NFS      
[RPC retransmission of #7971]V2 WRITE Call, FH:0x6a4be852 BeginOffset:0 
Offset:0 TotalCount:4096[Unreassembled Packet]
   8002 0.000121    192.168.y.yyy         192.168.x.xx          IP       
Fragmented IP protocol (proto=UDP 0x11, off=1480)
   8003 0.000108    192.168.y.yyy         192.168.x.xx          IP       
Fragmented IP protocol (proto=UDP 0x11, off=2960)
   8004 0.479678    192.168.y.yyy         192.168.x.xx          NFS      
[RPC retransmission of #7974]V2 WRITE Call, FH:0x6a4be852 BeginOffset:4096 
Offset:4096 TotalCount:4096[Unreassembled Packet]
   8005 0.000122    192.168.y.yyy         192.168.x.xx          IP       
Fragmented IP protocol (proto=UDP 0x11, off=1480)
   8006 0.000104    192.168.y.yyy         192.168.x.xx          IP       
Fragmented IP protocol (proto=UDP 0x11, off=2960)
   8007 0.479507    192.168.y.yyy         192.168.x.xx          NFS      
[RPC retransmission of #7977]V2 WRITE Call, FH:0x6a4be852 BeginOffset:8192 
Offset:8192 TotalCount:4096[Unreassembled Packet]
   8008 0.000127    192.168.y.yyy         192.168.x.xx          IP       
Fragmented IP protocol (proto=UDP 0x11, off=1480)
   8009 0.000101    192.168.y.yyy         192.168.x.xx          IP       
Fragmented IP protocol (proto=UDP 0x11, off=2960)
   8010 0.479484    192.168.y.yyy         192.168.x.xx          NFS      
[RPC retransmission of #7980]V2 WRITE Call, FH:0x6a4be852 BeginOffset:12288 
Offset:12288 TotalCount:4096[Unreassembled Packet]
   8011 0.000119    192.168.y.yyy         192.168.x.xx          IP       
Fragmented IP protocol (proto=UDP 0x11, off=1480)
   8012 0.000105    192.168.y.yyy         192.168.x.xx          IP       
Fragmented IP protocol (proto=UDP 0x11, off=2960)
   8013 0.479525    192.168.y.yyy         192.168.x.xx          NFS      
[RPC retransmission of #7983]V2 WRITE Call, FH:0x6a4be852 BeginOffset:16384 
Offset:16384 TotalCount:4096[Unreassembled Packet]
   8014 0.000121    192.168.y.yyy         192.168.x.xx          IP       
Fragmented IP protocol (proto=UDP 0x11, off=1480)
   8015 0.000103    192.168.y.yyy         192.168.x.xx          IP       
Fragmented IP protocol (proto=UDP 0x11, off=2960)
   8016 0.479394    192.168.y.yyy         192.168.x.xx          NFS      
[RPC retransmission of #7971]V2 WRITE Call, FH:0x6a4be852 BeginOffset:0 
Offset:0 TotalCount:4096[Unreassembled Packet]
   8017 0.000119    192.168.y.yyy         192.168.x.xx          IP       
Fragmented IP protocol (proto=UDP 0x11, off=1480)
   8018 0.000105    192.168.y.yyy         192.168.x.xx          IP       
Fragmented IP protocol (proto=UDP 0x11, off=2960)
   8019 0.959337    192.168.y.yyy         192.168.x.xx          NFS      
[RPC retransmission of #7974]V2 WRITE Call, FH:0x6a4be852 BeginOffset:4096 
Offset:4096 TotalCount:4096[Unreassembled Packet]
   8020 0.000122    192.168.y.yyy         192.168.x.xx          IP       
Fragmented IP protocol (proto=UDP 0x11, off=1480)
   8021 0.000104    192.168.y.yyy         192.168.x.xx          IP       
Fragmented IP protocol (proto=UDP 0x11, off=2960)
   8022 0.959255    192.168.y.yyy         192.168.x.xx          NFS      
[RPC retransmission of #7977]V2 WRITE Call, FH:0x6a4be852 BeginOffset:8192 
Offset:8192 TotalCount:4096[Unreassembled Packet]
   8023 0.000121    192.168.y.yyy         192.168.x.xx          IP       
Fragmented IP protocol (proto=UDP 0x11, off=1480)
   8024 0.000105    192.168.y.yyy         192.168.x.xx          IP       
Fragmented IP protocol (proto=UDP 0x11, off=2960)
   8025 8.794894    192.168.y.yyy         192.168.x.xx          NFS      
[RPC retransmission of #7980]V2 WRITE Call, FH:0x6a4be852 BeginOffset:12288 
Offset:12288 TotalCount:4096[Unreassembled Packet]
   8026 0.000121    192.168.y.yyy         192.168.x.xx          IP       
Fragmented IP protocol (proto=UDP 0x11, off=1480)
   8027 0.000105    192.168.y.yyy         192.168.x.xx          IP       
Fragmented IP protocol (proto=UDP 0x11, off=2960)

_________________________________________________________________
Chat: Ha en fest på Habbo Hotel 
http://habbohotel.msn.se/habbo/sv/channelizer Checka in här!



-------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc. Do you grep through log files
for problems?  Stop!  Download the new AJAX search engine that makes
searching your log files as easy as surfing the  web.  DOWNLOAD SPLUNK!
http://ads.osdn.com/?ad_id=7637&alloc_id=16865&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
