From: <nfsmailinglist@heessels.com>
Subject: RE: 'random' diskless clients hangs
Date: Sat, 6 Sep 2003 08:44:00 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <NEBBIHNAFKJAFOHBHGCOIEJLEFAA.nfsmailinglist@heessels.com>
References: <0073ECCF4F99D611810B0002A58F26560EB318B8@exnyc03.lehman.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Cc: <Richard.Dennis@lehman.com>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 19vWoQ-0005ys-00
	for <nfs@lists.sourceforge.net>; Fri, 05 Sep 2003 23:44:46 -0700
Received: from smtp2.mail.be.easynet.net ([212.100.160.76])
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.22)
	id 19vWoN-0003Kj-S0
	for nfs@lists.sourceforge.net; Fri, 05 Sep 2003 23:44:44 -0700
To: <nfs@lists.sourceforge.net>
In-Reply-To: <0073ECCF4F99D611810B0002A58F26560EB318B8@exnyc03.lehman.com>
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

This was in the log after I did
# echo 32767 > /proc/sys/sunrpc/rpc_debug
# echo 32767 > /proc/sys/sunrpc/nfs_debug
# echo 32767 > /proc/sys/sunrpc/nfsd_debug
# echo 32767 > /proc/sys/sunrpc/nlm_debug

Sep  6 08:37:07 aqua kernel: svc: socket f6b80080 put into queue
Sep  6 08:37:07 aqua kernel: svc: socket f6a33700(inet f6b80080),
write_space busy=1
Sep  6 08:37:07 aqua kernel: svc: socket f6b80080 busy, not enqueued
Sep  6 08:37:07 aqua kernel: svc: socket f6a33700(inet f6b80080), count=140,
busy=1
Sep  6 08:37:07 aqua kernel: svc: socket f6b80080 busy, not enqueued
Sep  6 08:37:07 aqua kernel: svc: got len=112
Sep  6 08:37:07 aqua kernel: svc: svc_authenticate (1)
Sep  6 08:37:07 aqua kernel: svc: socket f6b80080 busy, not enqueued
Sep  6 08:37:07 aqua kernel: svc: calling dispatcher
Sep  6 08:37:07 aqua kernel: nfsd_dispatch: vers 3 proc 4
Sep  6 08:37:07 aqua kernel: nfsd: ACCESS(3)   12: 00000001 03000800
00eb0097 00000000 00000000 00000000 0x2
Sep  6 08:37:07 aqua kernel: nfsd: fh_verify(12: 00000001 03000800 00eb0097
00000000 00000000 00000000)
Sep  6 08:37:07 aqua kernel: nfsd: ressize_check p f6564078 base f6564000
len 2304
Sep  6 08:37:07 aqua kernel: svc: service f660ea00, releasing skb f6c71880
Sep  6 08:37:07 aqua kernel: svc: socket f6a33700 sendto([f6564000 120... ],
1, 120) = 120
Sep  6 08:37:07 aqua kernel: svc: socket f6b80080 busy, not enqueued
Sep  6 08:37:07 aqua kernel: svc: server f660ea00 waiting for data (to =
30000)
Sep  6 08:37:07 aqua kernel: svc: socket f6a33700(inet f6b80080),
write_space busy=1
Sep  6 08:37:07 aqua kernel: svc: socket f6b80080 busy, not enqueued
Sep  6 08:37:07 aqua kernel: svc: socket f6b80080 dequeued, inuse=7
Sep  6 08:37:07 aqua kernel: svc: server f660ea00, socket f6a33700, inuse=8
Sep  6 08:37:07 aqua kernel: svc: socket f6b80080 put into queue
Sep  6 08:37:07 aqua kernel: svc: got len=4236
Sep  6 08:37:07 aqua kernel: svc: svc_authenticate (1)
Sep  6 08:37:07 aqua kernel: svc: socket f6b80080 busy, not enqueued
Sep  6 08:37:07 aqua kernel: svc: calling dispatcher
Sep  6 08:37:07 aqua kernel: svc: socket f6a33700(inet f6b80080), count=140,
busy=1
Sep  6 08:37:07 aqua kernel: svc: socket f6b80080 busy, not enqueued
Sep  6 08:37:07 aqua kernel: nfsd_dispatch: vers 3 proc 7
Sep  6 08:37:07 aqua kernel: nfsd: WRITE(3)    24: 02000001 03000800
00eb0097 01630077 44ef9777 01630070 4096 bytes at 0
Sep  6 08:37:07 aqua kernel: nfsd: fh_verify(24: 02000001 03000800 00eb0097
01630077 44ef9777 01630070)
Sep  6 08:37:07 aqua kernel: fh_verify: Inode 23265399, Bad count: 1 2 or
version  1156552573 1156552567
Sep  6 08:37:07 aqua kernel: nfsd: ressize_check p f6564024 base f6564000
len 2304
Sep  6 08:37:07 aqua kernel: svc: service f660ea00, releasing skb f6bdc480
Sep  6 08:37:07 aqua kernel: svc: socket f6a33700 sendto([f6564000 36... ],
1, 36) = 36
Sep  6 08:37:07 aqua kernel: svc: socket f6b80080 busy, not enqueued
Sep  6 08:37:07 aqua kernel: svc: server f660ea00 waiting for data (to =
30000)
Sep  6 08:37:07 aqua kernel: svc: socket f6b80080 dequeued, inuse=7
Sep  6 08:37:07 aqua kernel: svc: server f660ea00, socket f6a33700, inuse=8
Sep  6 08:37:07 aqua kernel: svc: socket f6b80080 put into queue
Sep  6 08:37:07 aqua kernel: svc: got len=132
Sep  6 08:37:07 aqua kernel: svc: socket f6a33700(inet f6b80080),
write_space busy=1
Sep  6 08:37:07 aqua kernel: svc: socket f6b80080 busy, not enqueued
Sep  6 08:37:07 aqua kernel: svc: socket f6a33700(inet f6b80080), count=128,
busy=1
Sep  6 08:37:07 aqua kernel: svc: socket f6b80080 busy, not enqueued
Sep  6 08:37:07 aqua kernel: svc: svc_authenticate (1)
Sep  6 08:37:07 aqua kernel: svc: socket f6b80080 busy, not enqueued
Sep  6 08:37:07 aqua kernel: svc: calling dispatcher
Sep  6 08:37:07 aqua kernel: nfsd_dispatch: vers 3 proc 21
Sep  6 08:37:07 aqua kernel: nfsd: COMMIT(3)   24: 02000001 03000800
00eb0097 01630077 44ef9777 01630070 0@4096
Sep  6 08:37:07 aqua kernel: nfsd: fh_verify(24: 02000001 03000800 00eb0097
01630077 44ef9777 01630070)
Sep  6 08:37:07 aqua kernel: fh_verify: Inode 23265399, Bad count: 1 2 or
version  1156552573 1156552567
Sep  6 08:37:07 aqua kernel: nfsd: ressize_check p f6564024 base f6564000
len 2304
Sep  6 08:37:07 aqua kernel: svc: service f660ea00, releasing skb efc65e80
Sep  6 08:37:07 aqua kernel: svc: socket f6a33700 sendto([f6564000 36... ],
1, 36) = 36
Sep  6 08:37:07 aqua kernel: svc: socket f6b80080 busy, not enqueued
Sep  6 08:37:07 aqua kernel: svc: server f660ea00 waiting for data (to =
30000)
Sep  6 08:37:07 aqua kernel: svc: socket f6b80080 dequeued, inuse=7
Sep  6 08:37:07 aqua kernel: svc: server f660ea00, socket f6a33700, inuse=8
Sep  6 08:37:07 aqua kernel: svc: socket f6b80080 put into queue
Sep  6 08:37:07 aqua kernel: svc: got len=132
Sep  6 08:37:07 aqua kernel: svc: svc_authenticate (1)
Sep  6 08:37:07 aqua kernel: svc: calling dispatcher
Sep  6 08:37:07 aqua kernel: nfsd_dispatch: vers 3 proc 6
Sep  6 08:37:07 aqua kernel: nfsd: READ(3) 24: 02000001 03000800 00eb0097
01630078 44ef977e 01630070 4096 bytes at 262144
Sep  6 08:37:07 aqua kernel: svc: socket f6a33700(inet f6b80080),
write_space busy=1
Sep  6 08:37:07 aqua kernel: svc: socket f6b80080 busy, not enqueued
Sep  6 08:37:07 aqua kernel: svc: socket f6a33700(inet f6b80080), count=140,
busy=1
Sep  6 08:37:07 aqua kernel: svc: socket f6b80080 busy, not enqueued
Sep  6 08:37:07 aqua kernel: svc: socket f6b80080 busy, not enqueued
Sep  6 08:37:07 aqua kernel: nfsd: fh_verify(24: 02000001 03000800 00eb0097
01630078 44ef977e 01630070)
Sep  6 08:37:07 aqua kernel: nfsd: raparms 1 2 0 0 0
Sep  6 08:37:07 aqua kernel: nfsd: ressize_check p f6565080 base f6564000
len 2304
Sep  6 08:37:07 aqua kernel: svc: service f660ea00, releasing skb f6c71580
Sep  6 08:37:07 aqua kernel: svc: socket f6a33700 sendto([f6564000
4224... ], 1, 4224) = 4224
Sep  6 08:37:07 aqua kernel: svc: socket f6b80080 busy, not enqueued
Sep  6 08:37:07 aqua kernel: svc: server f660ea00 waiting for data (to =
30000)
Sep  6 08:37:07 aqua kernel: svc: socket f6b80080 dequeued, inuse=7
Sep  6 08:37:07 aqua kernel: svc: server f660ea00, socket f6a33700, inuse=8
Sep  6 08:37:07 aqua kernel: svc: socket f6b80080 put into queue
Sep  6 08:37:07 aqua kernel: svc: socket f6a33700(inet f6b80080),
write_space busy=1
Sep  6 08:37:07 aqua kernel: svc: socket f6b80080 busy, not enqueued
Sep  6 08:37:07 aqua kernel: svc: socket f6a33700(inet f6b80080),
write_space busy=1
Sep  6 08:37:08 aqua kernel: svc: socket f6b80080 busy, not enqueued
Sep  6 08:37:08 aqua kernel: svc: socket f6a33700(inet f6b80080),
write_space busy=1
Sep  6 08:37:08 aqua kernel: svc: socket f6b80080 busy, not enqueued
Sep  6 08:37:08 aqua kernel: svc: socket f6a33700(inet f6b80080), count=128,
busy=1
Sep  6 08:37:08 aqua kernel: svc: socket f6b80080 busy, not enqueued
Sep  6 08:37:08 aqua kernel: svc: got len=120
Sep  6 08:37:08 aqua kernel: svc: svc_authenticate (1)
Sep  6 08:37:08 aqua kernel: svc: socket f6b80080 busy, not enqueued
Sep  6 08:37:08 aqua kernel: svc: calling dispatcher
Sep  6 08:37:08 aqua kernel: nfsd_dispatch: vers 3 proc 4
Sep  6 08:37:08 aqua kernel: nfsd: ACCESS(3)   20: 01000001 03000800
00eb0097 029a009c b1a5b3f8 00000000 0x2
Sep  6 08:37:08 aqua kernel: nfsd: fh_verify(20: 01000001 03000800 00eb0097
029a009c b1a5b3f8 00000000)
Sep  6 08:37:08 aqua kernel: nfsd: ressize_check p f6564078 base f6564000
len 2304
Sep  6 08:37:08 aqua kernel: svc: service f660ea00, releasing skb f6bdc580
Sep  6 08:37:08 aqua kernel: svc: socket f6a33700 sendto([f6564000 120... ],
1, 120) = 120
Sep  6 08:37:08 aqua kernel: svc: socket f6b80080 busy, not enqueued
Sep  6 08:37:08 aqua kernel: svc: server f660ea00 waiting for data (to =
30000)
Sep  6 08:37:08 aqua kernel: svc: socket f6b80080 dequeued, inuse=7
Sep  6 08:37:08 aqua kernel: svc: server f660ea00, socket f6a33700, inuse=8
Sep  6 08:37:08 aqua kernel: svc: socket f6b80080 put into queue
Sep  6 08:37:08 aqua kernel: svc: got len=120
Sep  6 08:37:08 aqua kernel: svc: svc_authenticate (1)
Sep  6 08:37:08 aqua kernel: svc: socket f6b80080 busy, not enqueued
Sep  6 08:37:08 aqua kernel: svc: calling dispatcher
Sep  6 08:37:08 aqua kernel: nfsd_dispatch: vers 3 proc 4
Sep  6 08:37:08 aqua kernel: svc: socket f6a33700(inet f6b80080),
write_space busy=1
Sep  6 08:37:08 aqua kernel: svc: socket f6b80080 busy, not enqueued
Sep  6 08:37:08 aqua kernel: nfsd: ACCESS(3)   20: 01000001 03000800
00eb0097 03f5408e b1a5bd30 00000000 0x2
Sep  6 08:37:08 aqua kernel: nfsd: fh_verify(20: 01000001 03000800 00eb0097
03f5408e b1a5bd30 00000000)
Sep  6 08:37:08 aqua kernel: nfsd: ressize_check p f6564078 base f6564000
len 2304
Sep  6 08:37:08 aqua kernel: svc: service f660ea00, releasing skb f6d5b480
Sep  6 08:37:08 aqua kernel: svc: socket f6a33700 sendto([f6564000 120... ],
1, 120) = 120
Sep  6 08:37:08 aqua kernel: svc: socket f6b80080 busy, not enqueued
Sep  6 08:37:08 aqua kernel: svc: server f660ea00 waiting for data (to =
30000)
Sep  6 08:37:08 aqua kernel: svc: socket f6b80080 dequeued, inuse=7
Sep  6 08:37:08 aqua kernel: svc: server f660ea00, socket f6a33700, inuse=8
Sep  6 08:37:08 aqua kernel: svc: socket f6b80080 put into queue
Sep  6 08:37:08 aqua kernel: svc: got len=132
Sep  6 08:37:08 aqua kernel: svc: svc_authenticate (1)
Sep  6 08:37:08 aqua kernel: svc: calling dispatcher
Sep  6 08:37:08 aqua kernel: nfsd_dispatch: vers 3 proc 6
Sep  6 08:37:08 aqua kernel: svc: socket f6a33700(inet f6b80080),
write_space busy=1
Sep  6 08:37:08 aqua kernel: svc: socket f6b80080 busy, not enqueued
Sep  6 08:37:08 aqua kernel: nfsd: READ(3) 24: 02000001 03000800 00eb0097
01630078 44ef977e 01630070 4096 bytes at 274432
Sep  6 08:37:08 aqua kernel: svc: socket f6b80080 busy, not enqueued
Sep  6 08:37:08 aqua kernel: nfsd: fh_verify(24: 02000001 03000800 00eb0097
01630078 44ef977e 01630070)
Sep  6 08:37:08 aqua kernel: nfsd: raparms 1 2 0 0 0
Sep  6 08:37:08 aqua kernel: nfsd: ressize_check p f6565080 base f6564000
len 2304
Sep  6 08:37:08 aqua kernel: svc: service f660ea00, releasing skb f5010080
Sep  6 08:37:08 aqua kernel: svc: socket f6a33700 sendto([f6564000
4224... ], 1, 4224) = 4224
Sep  6 08:37:08 aqua kernel: svc: socket f6b80080 busy, not enqueued
Sep  6 08:37:08 aqua kernel: svc: server f660ea00 waiting for data (to =
30000)
Sep  6 08:37:08 aqua kernel: svc: socket f6b80080 dequeued, inuse=7
Sep  6 08:37:08 aqua kernel: svc: server f660ea00, socket f6a33700, inuse=8
Sep  6 08:37:08 aqua kernel: svc: socket f6b80080 put into queue
Sep  6 08:37:08 aqua kernel: svc: got len=132
Sep  6 08:37:08 aqua kernel: svc: socket f6a33700(inet f6b80080),
write_space busy=1
Sep  6 08:37:08 aqua kernel: svc: socket f6b80080 busy, not enqueued
Sep  6 08:37:08 aqua kernel: svc: socket f6a33700(inet f6b80080),
write_space busy=1
Sep  6 08:37:08 aqua kernel: svc: socket f6b80080 busy, not enqueued
Sep  6 08:37:08 aqua kernel: svc: socket f6a33700(inet f6b80080),
write_space busy=1
Sep  6 08:37:08 aqua kernel: svc: socket f6b80080 busy, not enqueued
Sep  6 08:37:08 aqua kernel: svc: svc_authenticate (1)
Sep  6 08:37:08 aqua kernel: svc: calling dispatcher
Sep  6 08:37:08 aqua kernel: nfsd_dispatch: vers 3 proc 6
Sep  6 08:37:08 aqua kernel: nfsd: READ(3) 24: 02000001 03000800 00eb0097
01630078 44ef977e 01630070 4096 bytes at 278528
Sep  6 08:37:08 aqua kernel: svc: socket f6b80080 busy, not enqueued
Sep  6 08:37:08 aqua kernel: nfsd: fh_verify(24: 02000001 03000800 00eb0097
01630078 44ef977e 01630070)
Sep  6 08:37:08 aqua kernel: nfsd: raparms 1 2 0 0 0
Sep  6 08:37:08 aqua kernel: nfsd: ressize_check p f6565080 base f6564000
len 2304
Sep  6 08:37:08 aqua kernel: svc: service f660ea00, releasing skb f6ca5b80
Sep  6 08:37:08 aqua kernel: svc: socket f6a33700 sendto([f6564000
4224... ], 1, 4224) = 4224
Sep  6 08:37:08 aqua kernel: svc: socket f6b80080 busy, not enqueued
Sep  6 08:37:08 aqua kernel: svc: server f660ea00 waiting for data (to =
30000)
Sep  6 08:37:08 aqua kernel: svc: socket f6b80080 dequeued, inuse=7
Sep  6 08:37:08 aqua kernel: svc: server f660ea00, socket f6a33700, inuse=8
Sep  6 08:37:08 aqua kernel: svc: socket f6b80080 put into queue
Sep  6 08:37:08 aqua kernel: svc: got len=120
Sep  6 08:37:08 aqua kernel: svc: svc_authenticate (1)
Sep  6 08:37:08 aqua kernel: svc: socket f6b80080 busy, not enqueued
Sep  6 08:37:08 aqua kernel: svc: calling dispatcher
Sep  6 08:37:08 aqua kernel: svc: socket f6a33700(inet f6b80080),
write_space busy=1
Sep  6 08:37:08 aqua kernel: svc: socket f6b80080 busy, not enqueued
Sep  6 08:37:08 aqua kernel: svc: socket f6a33700(inet f6b80080),
write_space busy=1
Sep  6 08:37:08 aqua kernel: svc: socket f6b80080 busy, not enqueued
Sep  6 08:37:08 aqua kernel: svc: socket f6a33700(inet f6b80080),
write_space busy=1
Sep  6 08:37:08 aqua kernel: svc: socket f6b80080 busy, not enqueued
Sep  6 08:37:08 aqua kernel: nfsd_dispatch: vers 3 proc 4
Sep  6 08:37:08 aqua kernel: nfsd: ACCESS(3)   20: 01000001 03000800
00eb0097 03ecc089 b1a5bad9 00000000 0x2
Sep  6 08:37:08 aqua kernel: nfsd: fh_verify(20: 01000001 03000800 00eb0097
03ecc089 b1a5bad9 00000000)
Sep  6 08:37:08 aqua kernel: nfsd: ressize_check p f6564078 base f6564000
len 2304
Sep  6 08:37:08 aqua kernel: svc: service f660ea00, releasing skb f6d5bc80
Sep  6 08:37:08 aqua kernel: svc: socket f6a33700 sendto([f6564000 120... ],
1, 120) = 120
Sep  6 08:37:08 aqua kernel: svc: socket f6b80080 busy, not enqueued
Sep  6 08:37:08 aqua kernel: svc: server f660ea00 waiting for data (to =
30000)
Sep  6 08:37:08 aqua kernel: svc: socket f6b80080 dequeued, inuse=7
Sep  6 08:37:08 aqua kernel: svc: socket f6a33700(inet f6b80080),
write_space busy=1
Sep  6 08:37:08 aqua kernel: svc: socket f6b80080 busy, not enqueued
Sep  6 08:37:08 aqua kernel: svc: server f660ea00, socket f6a33700, inuse=8
Sep  6 08:37:08 aqua kernel: svc: socket f6b80080 put into queue
Sep  6 08:37:08 aqua kernel: svc: got len=132
Sep  6 08:37:08 aqua kernel: svc: svc_authenticate (1)
Sep  6 08:37:08 aqua kernel: svc: calling dispatcher
Sep  6 08:37:08 aqua kernel: nfsd_dispatch: vers 3 proc 6
Sep  6 08:37:08 aqua kernel: nfsd: READ(3) 24: 02000001 03000800 00eb0097
01630078 44ef977e 01630070 4096 bytes at 286720
Sep  6 08:37:08 aqua kernel: svc: socket f6b80080 busy, not enqueued
Sep  6 08:37:08 aqua kernel: nfsd: fh_verify(24: 02000001 03000800 00eb0097
01630078 44ef977e 01630070)
Sep  6 08:37:08 aqua kernel: nfsd: raparms 1 2 0 0 0
Sep  6 08:37:08 aqua kernel: nfsd: ressize_check p f6565080 base f6564000
len 2304
Sep  6 08:37:08 aqua kernel: svc: service f660ea00, releasing skb f6bfd080
Sep  6 08:37:08 aqua kernel: svc: socket f6a33700 sendto([f6564000
4224... ], 1, 4224) = 4224
Sep  6 08:37:08 aqua kernel: svc: socket f6b80080 busy, not enqueued
Sep  6 08:37:08 aqua kernel: svc: server f660ea00 waiting for data (to =
30000)
Sep  6 08:37:08 aqua kernel: svc: socket f6b80080 dequeued, inuse=7
Sep  6 08:37:08 aqua kernel: svc: server f660ea00, socket f6a33700, inuse=8
Sep  6 08:37:08 aqua kernel: svc: socket f6b80080 put into queue
Sep  6 08:37:08 aqua kernel: svc: got len=120
Sep  6 08:37:08 aqua kernel: svc: svc_authenticate (1)
Sep  6 08:37:08 aqua kernel: svc: socket f6b80080 busy, not enqueued
Sep  6 08:37:08 aqua kernel: svc: calling dispatcher
Sep  6 08:37:08 aqua kernel: nfsd_dispatch: vers 3 proc 4
Sep  6 08:37:08 aqua kernel: svc: socket f6a33700(inet f6b80080),
write_space busy=1
Sep  6 08:37:08 aqua kernel: svc: socket f6b80080 busy, not enqueued
Sep  6 08:37:08 aqua kernel: svc: socket f6a33700(inet f6b80080),
write_space busy=1
Sep  6 08:37:08 aqua kernel: svc: socket f6b80080 busy, not enqueued
Sep  6 08:37:08 aqua kernel: svc: socket f6a33700(inet f6b80080),
write_space busy=1
Sep  6 08:37:08 aqua kernel: svc: socket f6b80080 busy, not enqueued
Sep  6 08:37:08 aqua kernel: nfsd: ACCESS(3)   20: 01000001 03000800
00eb0097 029a009c b1a5b3f8 00000000 0x2
Sep  6 08:37:08 aqua kernel: nfsd: fh_verify(20: 01000001 03000800 00eb0097
029a009c b1a5b3f8 00000000)
Sep  6 08:37:08 aqua kernel: nfsd: ressize_check p f6564078 base f6564000
len 2304
Sep  6 08:37:08 aqua kernel: svc: service f660ea00, releasing skb f6d5b580
Sep  6 08:37:08 aqua kernel: svc: socket f6a33700 sendto([f6564000 120... ],
1, 120) = 120
Sep  6 08:37:08 aqua kernel: svc: socket f6b80080 busy, not enqueued
Sep  6 08:37:08 aqua kernel: svc: server f660ea00 waiting for data (to =
30000)
Sep  6 08:37:08 aqua kernel: svc: socket f6b80080 dequeued, inuse=7
Sep  6 08:37:08 aqua kernel: svc: server f660ea00, socket f6a33700, inuse=8
Sep  6 08:37:08 aqua kernel: svc: got len=-11
Sep  6 08:37:08 aqua kernel: svc: socket f6a33700(inet f6b80080),
write_space busy=0
Sep  6 08:37:08 aqua kernel: svc: server f660ea00 waiting for data (to =
30000)
Sep  6 08:37:08 aqua kernel: nfsd: raparms 1 2 0 0 0
Sep  6 08:37:08 aqua kernel: nfsd: ressize_check p f65a1080 base f65a0000
len 2304
Sep  6 08:37:08 aqua kernel: svc: service f660ac00, releasing skb f57cc180
Sep  6 08:37:08 aqua kernel: svc: socket f6a33700 sendto([f65a0000
4224... ], 1, 4224) = 4224
Sep  6 08:37:08 aqua kernel: svc: server f660ac00 waiting for data (to =
30000)
Sep  6 08:37:08 aqua kernel: nfsd: write complete err=512
Sep  6 08:37:08 aqua kernel: svc: socket f6a33700(inet f6b80080),
write_space busy=0
Sep  6 08:37:08 aqua last message repeated 2 times
Sep  6 08:37:08 aqua kernel: nfsd: ressize_check p f6568088 base f6568000
len 2304
Sep  6 08:37:08 aqua kernel: svc: service f660e400, releasing skb f6d7b880
Sep  6 08:37:08 aqua kernel: svc: socket f6a33700 sendto([f6568000 136... ],
1, 136) = 136
Sep  6 08:37:08 aqua kernel: svc: server f660e400 waiting for data (to =
30000)
Sep  6 08:37:08 aqua kernel: nfsd: write complete err=1728
Sep  6 08:37:08 aqua kernel: nfsd: ressize_check p f6574088 base f6574000
len 2304
Sep  6 08:37:08 aqua kernel: svc: service f660d800, releasing skb f6eb2980
Sep  6 08:37:08 aqua kernel: svc: socket f6a33700 sendto([f6574000 136... ],
1, 136) = 136
Sep  6 08:37:08 aqua kernel: svc: server f660d800 waiting for data (to =
30000)
Sep  6 08:37:08 aqua kernel: nfsd: raparms 1 2 0 0 0
Sep  6 08:37:08 aqua kernel: nfsd: ressize_check p f657d080 base f657c000
len 2304
Sep  6 08:37:08 aqua kernel: svc: service f660d200, releasing skb f6eb2b80
Sep  6 08:37:08 aqua kernel: svc: socket f6a33700(inet f6b80080),
write_space busy=0
Sep  6 08:37:08 aqua kernel: svc: socket f6a33700(inet f6b80080),
write_space busy=0
Sep  6 08:37:08 aqua kernel: svc: socket f6a33700 sendto([f657c000
4224... ], 1, 4224) = 4224
Sep  6 08:37:08 aqua kernel: svc: server f660d200 waiting for data (to =
30000)
Sep  6 08:37:08 aqua kernel: svc: socket f6a33700(inet f6b80080),
write_space busy=0
Sep  6 08:37:08 aqua last message repeated 2 times
Sep  6 08:37:08 aqua kernel: nfsd: ressize_check p f65a8080 base f65a8000
len 2304
Sep  6 08:37:08 aqua kernel: svc: service f660a600, releasing skb efa34680
Sep  6 08:37:08 aqua kernel: svc: socket f6a33700 sendto([f65a8000 128... ],
1, 128) = 128
Sep  6 08:37:08 aqua kernel: svc: server f660a600 waiting for data (to =
30000)
Sep  6 08:37:08 aqua kernel: nfsd: ressize_check p f6570080 base f6570000
len 2304
Sep  6 08:37:08 aqua kernel: svc: service f660de00, releasing skb f6d5b080
Sep  6 08:37:08 aqua kernel: svc: socket f6a33700(inet f6b80080),
write_space busy=0
Sep  6 08:37:08 aqua kernel: svc: socket f6a33700 sendto([f6570000 128... ],
1, 128) = 128
Sep  6 08:37:08 aqua kernel: svc: server f660de00 waiting for data (to =
30000)
Sep  6 08:37:08 aqua kernel: svc: socket f6a33700(inet f6b80080),
write_space busy=0
Sep  6 08:37:08 aqua kernel: nfsd: ressize_check p f65b0104 base f65b0000
len 2304
Sep  6 08:37:08 aqua kernel: svc: service f78a2e00, releasing skb efa34180
Sep  6 08:37:08 aqua kernel: svc: socket f6a33700 sendto([f65b0000 260... ],
1, 260) = 260
Sep  6 08:37:08 aqua kernel: svc: server f78a2e00 waiting for data (to =
30000)
Sep  6 08:37:08 aqua kernel: svc: socket f6a33700(inet f6b80080),
write_space busy=0




-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
