From: Debian User <debian-user@zerocrossings.com>
Subject: cannot mount via nfs
Date: Wed, 30 Apr 2003 09:08:04 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <23096.2361944423$1051708424@news.gmane.org>
Reply-To: debian-user@zerocrossings.com
Mime-Version: 1.0
Content-Type: text/plain; charset=iso8859-1
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from ool-182d9afe.dyn.optonline.net
	([24.45.154.254] helo=development ident=mail)
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19ArLq-0003vh-00
	for <nfs@lists.sourceforge.net>; Wed, 30 Apr 2003 06:10:22 -0700
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

I have had nfs mounting working in the past ... do not understand 
why this is not working now. Can anyone help?

NFS server:

# rpcinfo -p
   program vers proto   port
    100000    2   tcp    111  portmapper
    100000    2   udp    111  portmapper
    100024    1   udp   2098  status
    100024    1   tcp   2079  status
    100005    1   udp   2099  mountd
    100005    1   tcp   2080  mountd
    100005    2   udp   2099  mountd
    100005    2   tcp   2080  mountd

# ps ax | grep nfs
21876 ?        SW     0:00 /usr/sbin/rpc.mountd --no-nfs-version 3
 1550 pts/0    S      0:00 grep nfs

# ps ax | grep rpc
21862 ?        S      0:00 /sbin/rpc.statd
21876 ?        S      0:00 /usr/sbin/rpc.mountd --no-nfs-version 3
 1552 pts/0    S      0:00 grep rpc

# lsmod
Module                  Size  Used by    Not tainted
nfs                    69628   0  (unused)
nfsd                   65024   0  (autoclean)
lockd                  46816   0  (autoclean) [nfs nfsd]
sunrpc                 58484   0  (autoclean) [nfs nfsd lockd]
md                     43584   0  (autoclean) (unused)
af_packet              11528   2
natsemi                14664   2
rtc                     5528   0  (autoclean)
ext2                   30592   8  (autoclean)
ide-disk                6624   9  (autoclean)
ide-probe-mod           8064   0  (autoclean)
ide-mod               130860   9  (autoclean) [ide-disk ide-probe-mod]
ext3                   56736   0  (autoclean)
jbd                    35048   0  (autoclean) [ext3]
unix                   13316  12  (autoclean)

# uname -r
2.4.18-586tsc














-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
