From: chimin yen <ychimin2000@yahoo.com>
Subject: Red Hat 7.3 nfs portmap problem
Date: Tue, 15 Oct 2002 08:55:49 -0700 (PDT)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20021015155549.18814.qmail@web40613.mail.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: ychimin2000@yahoo.com
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from web40613.mail.yahoo.com ([66.218.78.150])
	by usw-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 181U31-0003C2-00
	for <nfs@lists.sourceforge.net>; Tue, 15 Oct 2002 08:55:55 -0700
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

Setup NFS on Red Hat 7.2 wasn't a problem, on RH 7.3,
just cannot make it work. I've tried both
nfs-utils-0.3.3
and nfs-utils-1.0.1. 

When mount a volume from 192.168.1.2 to local
192.168.1.1,
(as a root) I got the following error:

# mount 192.168.1.2:/home /mnt/user
mount: RPC: Port mapper failure - RPC: Unable to
receive

When mount a volume from 192.168.1.1 to local
192.168.1.2,
(also as a root) the operation hangs.

Other information :

# cat /etc/exports
/home 192.168.1.1(rw)
# mount 192.168.1.2:/home /mnt/user
mount: RPC: Port mapper failure - RPC: Unable to
receive


# /etc/init.d/nfs restart
Stopping NFS mountd:                                  
    [  OK  ]
Stopping NFS daemon:                                  
    [  OK  ]
Stopping NFS services:                                
    [  OK  ]
Stopping NFS quotas:                                  
    [  OK  ]
Starting NFS services:                                
    [  OK  ]
Starting NFS quotas:                                  
    [  OK  ]
Starting NFS mountd:                                  
    [  OK  ]
Starting NFS daemon:                                  
    [  OK  ]

# ps -aux | grep nfs
root      7878  0.0  0.0     0    0 ?        SW  
23:18   0:00 [nfsd]
root      7879  0.0  0.0     0    0 ?        SW  
23:18   0:00 [nfsd]
root      7880  0.0  0.0     0    0 ?        SW  
23:18   0:00 [nfsd]
root      7881  0.0  0.0     0    0 ?        SW  
23:18   0:00 [nfsd]
root      7882  0.0  0.0     0    0 ?        SW  
23:18   0:00 [nfsd]
root      7883  0.0  0.0     0    0 ?        SW  
23:18   0:00 [nfsd]
root      7884  0.0  0.0     0    0 ?        SW  
23:18   0:00 [nfsd]
root      7885  0.0  0.0     0    0 ?        SW  
23:18   0:00 [nfsd]
root      7891  0.0  0.2  2240  636 pts/2    R   
23:18   0:00 grep nfs

# ps -aux | grep rpc
rpc        736  0.0  0.2  1512  552 ?        S   
12:39   0:00 portmap
rpcuser    762  0.0  0.2  1556  568 ?        S   
12:39   0:00 rpc.statd
root      7868  0.0  0.1  1468  420 ?        S   
23:18   0:00 rpc.rquotad
root      7873  0.0  0.2  1548  616 ?        S   
23:18   0:00 rpc.mountd
root      7887  0.0  0.0     0    0 ?        SW  
23:18   0:00 [rpciod]


Please help...

__________________________________________________
Do you Yahoo!?
Faith Hill - Exclusive Performances, Videos & More
http://faith.yahoo.com


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
