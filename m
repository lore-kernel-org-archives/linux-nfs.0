From: Alexander Samad <alex-SGFoFqf0RKf0CCvOHzKKcA@public.gmane.org>
Subject: Help please
Date: Tue, 15 Jun 2010 12:01:25 +1000
Message-ID: <AANLkTinQkRf_ZkN5qw1rsK5MY7pB1NjFd5CiLaPa-ZOU@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-iw0-f174.google.com ([209.85.214.174]:38345 "EHLO
	mail-iw0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755653Ab0FOCB0 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 14 Jun 2010 22:01:26 -0400
Received: by iwn9 with SMTP id 9so3987341iwn.19
        for <linux-nfs@vger.kernel.org>; Mon, 14 Jun 2010 19:01:25 -0700 (PDT)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi

sorry if this is a duplicate, I have been having some problem
subscribing to the ml.



I am having some problem with nfs-kernel on a debian amd64 (sid)  i am
using version (1:1.2.2-1).

when I do a tcpdump on my nfs machine and do a mount -o vers=4,udp
nfs:/exports/video /exports/video/ it fails


mount -o vers=3,udp  nfs:/exports/video /exports/video/
mount.nfs: mount to NFS server 'nfs:/exports/video' failed: timed out, giving up


and with tcpdump, I see the request from from the client and I see the
reply ok from the nfs machine, but it seem like the nfs packet doesn't
make it to the wire, machines on the same network doesn't see the
packet.

on the nfs server I have a bridge interface br0 => eth0 eth1 eth2 eth3 vde0

on vde0 I have attached virtualbox 3.2.4, and when I look on the vde
switch with tcpdump I don't see the reply packet.

I have done some limited testing for udp and it seems to be working,
traced dns packets

I can mount tcp, but if I user vers4 i get wierd gid uid numbers

ls -l
 drwxrwsr-x  2 4294967294 4294967294 4.1k Oct 25  2009 Funnies



 rpcinfo -p
  program vers proto   port
   100000    2   tcp    111  portmapper
   100024    1   udp  32765  status
   100024    1   tcp  32765  status
   100021    1   udp  32768  nlockmgr
   100021    3   udp  32768  nlockmgr
   100021    4   udp  32768  nlockmgr
   100021    1   tcp  32768  nlockmgr
   100021    3   tcp  32768  nlockmgr
   100021    4   tcp  32768  nlockmgr
   100003    2   tcp   2049  nfs
   100003    3   tcp   2049  nfs
   100003    4   tcp   2049  nfs
   100227    2   tcp   2049
   100227    3   tcp   2049
   100003    2   udp   2049  nfs
   100003    3   udp   2049  nfs
   100003    4   udp   2049  nfs
   100227    2   udp   2049
   100227    3   udp   2049
   100005    1   udp  32767  mountd
   100005    1   tcp  32767  mountd
   100005    2   udp  32767  mountd
   100005    2   tcp  32767  mountd
   100005    3   udp  32767  mountd
   100005    3   tcp  32767  mountd

on nfs restart

Jun 13 22:05:20 max kernel: [21723.836493] svc: failed to register
lockdv1 RPC service (errno 97).
Jun 13 22:05:20 max kernel: [21723.837490] NFSD: Using
/var/lib/nfs/v4recovery as the NFSv4 state recovery directory
Jun 13 22:05:20 max kernel: [21723.837507] NFSD: starting 90-second grace period


tcpdump on nfs machine of mount -o vers=4,udp  nfs:/exports/video
/exports/video/

tcpdump -pni br0 host 192.168.10.221 and not port 22
tcpdump: verbose output suppressed, use -v or -vv for full protocol decode
listening on br0, link-type EN10MB (Ethernet), capture size 65535 bytes
22:09:12.565697 IP 192.168.10.221.30209 > 192.168.11.10.53: 52743+ A?
nfs.hme1.samad.com.au. (39)
22:09:12.565891 IP 192.168.11.10.53 > 192.168.10.221.30209: 52743*
2/2/3 CNAME max.lan1.hme1.samad.com.au., A 192.168.11.10 (182)
22:09:12.567227 IP 192.168.10.221.35835 > 192.168.11.10.53: 59898+ A?
nfs.hme1.samad.com.au. (39)
22:09:12.567369 IP 192.168.11.10.53 > 192.168.10.221.35835: 59898*
2/2/3 CNAME max.lan1.hme1.samad.com.au., A 192.168.11.10 (182)
22:09:12.568676 IP 192.168.10.221.243695162 > 192.168.11.10.2049: 40 null
22:09:12.568726 IP 192.168.11.10.2049 > 192.168.10.221.243695162:
reply ok 24 null <<<<<<<<<<<<< this is missing on the client ....
22:09:13.668091 IP 192.168.10.221.243695162 > 192.168.11.10.2049: 40 null
22:09:13.668158 IP 192.168.11.10.2049 > 192.168.10.221.243695162:
reply ok 24 null
22:09:15.867266 IP 192.168.10.221.243695162 > 192.168.11.10.2049: 40 null
22:09:15.867345 IP 192.168.11.10.2049 > 192.168.10.221.243695162:
reply ok 24 null
22:09:17.680551 IP 192.168.10.221.58336 > 192.168.11.10.25826: UDP, length 917


Help :)
