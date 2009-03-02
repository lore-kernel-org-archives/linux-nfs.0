From: Chris Rodgers <christopher.rodgers-6Ezq7DgQwRAXSZKaUYBEcQ@public.gmane.org>
Subject: [NFS] Using kerberos NFSv4 with Fedora 10
Date: Mon, 02 Mar 2009 08:10:20 +0000
Message-ID: <49AB946C.5000806@cardiov.ox.ac.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfs@lists.sourceforge.net
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from neil.brown.name ([220.233.11.133]:50127 "EHLO neil.brown.name"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753503AbZCBJBg (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 2 Mar 2009 04:01:36 -0500
Received: from brown by neil.brown.name with local (Exim 4.69)
	(envelope-from <nfs-bounces@lists.sourceforge.net>)
	id 1Le41k-0000a7-2v
	for linux-nfs@vger.kernel.org; Mon, 02 Mar 2009 20:01:32 +1100
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi,

I am trying to get two Fedora 10 machines to talk to each other using 
NFSv4 and sec=krb5p, but I do not seem to be having much luck. I would 
appreciate any suggestions for trouble shooting.

Thanks in advance!

Chris

P.S. Here's what I've done so far:

1) I installed following a guide at 
http://www.citi.umich.edu/projects/nfsv4/2.4-nfsv4/release1/install.html 
and with as much other Googling as I could muster.

2) I now have these modules on the server (mango):

[root@mango ~]# rpm -qa | egrep '(rpc|nfs|krb)'
krb5-workstation-1.6.3-16.fc10.x86_64
rpcbind-0.1.7-1.fc10.x86_64
krb5-workstation-clients-1.6.3-16.fc10.x86_64
nfs-utils-lib-1.1.4-1.fc10.x86_64
pam_krb5-2.3.2-1.fc10.x86_64
krb5-auth-dialog-0.7-7.fc9.x86_64
krb5-server-1.6.3-16.fc10.x86_64
libtirpc-0.1.10-2.fc10.x86_64
nfs-utils-1.1.4-8.fc10.x86_64
krb5-workstation-servers-1.6.3-16.fc10.x86_64
krb5-libs-1.6.3-16.fc10.x86_64

and these processes running:

[root@mango ~]# ps aux | egrep '(rpc|nfs)'
rpc       1707  0.0  0.0  19768   932 ?        Ss   Feb28   0:00 rpcbind
rpcuser   1720  0.0  0.0  10300   824 ?        Ss   Feb28   0:00 rpc.statd
root      1750  0.0  0.0      0     0 ?        S<   Feb28   0:00 [rpciod/0]
root      1751  0.0  0.0      0     0 ?        S<   Feb28   0:00 [rpciod/1]
root      5611  0.0  0.0      0     0 ?        S<   Mar01   0:00 [nfsiod]
root      8865  0.0  0.0  22940   624 ?        Ss   Mar01   0:00 rpc.idmapd
root     10332  0.0  0.2  36656  4144 ?        Ss   07:47   0:00 rpc.svcgssd
root     10338  0.0  0.0  89052   272 ?        Ss   07:47   0:00 rpc.rquotad
root     10342  0.0  0.0      0     0 ?        S<   07:47   0:00 [nfsd4]
root     10343  0.0  0.0      0     0 ?        S<   07:47   0:00 [nfsd]
root     10344  0.0  0.0      0     0 ?        S<   07:47   0:00 [nfsd]
root     10345  0.0  0.0      0     0 ?        S<   07:47   0:00 [nfsd]
root     10346  0.0  0.0      0     0 ?        S<   07:47   0:00 [nfsd]
root     10347  0.0  0.0      0     0 ?        S<   07:47   0:00 [nfsd]
root     10349  0.0  0.0      0     0 ?        S<   07:47   0:00 [nfsd]
root     10350  0.0  0.0      0     0 ?        S<   07:47   0:00 [nfsd]
root     10353  0.0  0.0  14524   336 ?        Ss   07:47   0:00 
rpc.mountd --no-nfs-version 1 --no-nfs-version 2
root     10451  0.0  0.0  85004   836 pts/4    S+   08:03   0:00 egrep 
(rpc|nfs)

These are my exports:

[root@mango ~]# cat /etc/exports
/nfs4exports 
*(rw,insecure,no_subtree_check,nohide,fsid=0,sec=krb5p)
/nfs4exports/a          *(rw,insecure,no_subtree_check,nohide,sec=krb5p)
/nfs4exports            gss/krb5(rw,insecure)


On the client (lime), I have these:

[root@lime ~]# rpm -qa | egrep '(rpc|nfs|krb)'
krb5-workstation-1.6.3-16.fc10.x86_64
libtirpc-0.1.10-2.fc10.x86_64
krb5-libs-1.6.3-16.fc10.i386
nfs-utils-lib-1.1.4-1.fc10.x86_64
krb5-workstation-clients-1.6.3-16.fc10.x86_64
nfs-utils-1.1.4-8.fc10.x86_64
rpcbind-0.1.7-1.fc10.x86_64
krb5-workstation-servers-1.6.3-16.fc10.x86_64
krb5-libs-1.6.3-16.fc10.x86_64
pam_krb5-2.3.2-1.fc10.x86_64
krb5-auth-dialog-0.7-7.fc9.x86_64
krb5-server-1.6.3-16.fc10.x86_64

[root@lime ~]# ps aux | egrep '(rpc|nfs)'
root      1741  0.0  0.0      0     0 ?        S<   Feb27   0:00 [rpciod/0]
root      1742  0.0  0.0      0     0 ?        S<   Feb27   0:00 [rpciod/1]
root      5209  0.0  0.0  22940   600 ?        SNs  Mar01   0:00 rpc.idmapd
rpc       8391  0.0  0.0  18876   924 ?        SNs  Feb27   0:00 rpcbind -w
rpcuser   8724  0.0  0.0  10300   820 ?        SNs  Feb27   0:00 rpc.statd
root     26532  0.0  0.0      0     0 ?        S<   Mar01   0:00 [nfsiod]

I have temporarily used "setenforce 0" to disable SELinux on both 
machines and disabled their firewalls.

I enabled the debug sysctls listed here:

http://wiki.linux-nfs.org/wiki/index.php/General_troubleshooting_recommendations

NOW - if I try to mount filesystems with sec=sys in the exports file, it 
works fine.

ALSO - kinit / klist work fine on both hosts.

BUT, this command (on the server) hangs for about 30s and then fails:
[root@mango ~]# mount -t nfs4 mango:/ /mnt/mango -o sec=krb5p

In the dmesg logs, I see this:

--> nfs4_create_server()
--> nfs4_init_server()
--> nfs4_set_client()
--> nfs_get_client(mango,v4)
svc: initialising pool 0 for NFSv4 callback
svc: svc_register(NFSv4 callback, tcp, 0, 1)
RPC:       unregistering (1073741824, 1, 0, 0) with local rpcbind
RPC:       set up transport to address addr=127.0.0.1 port=111 proto=udp
RPC:       created transport ffff8800754d5800 with 16 slots
RPC:       creating rpcbind client for localhost (xprt ffff8800754d5800)
RPC:       creating UNIX authenticator for client ffff88006f405c00
RPC:     0 looking up UNIX cred
RPC:       looking up UNIX cred
RPC:       allocating UNIX cred for uid 0 gid 0
RPC:       new task initialized, procpid 10475
RPC:       allocated task ffff88007b593e00
RPC:   265 __rpc_execute flags=0x280
RPC:   265 call_start rpcbind2 proc UNSET (sync)
RPC:   265 call_reserve (status 0)
RPC:   265 reserved req ffff88006bcd8000 xid 9bb8d49b
RPC:   265 call_reserveresult (status 0)
RPC:   265 call_allocate (status 0)
RPC:   265 allocated buffer of size 416 at ffff8800754d0800
RPC:   265 call_bind (status 0)
RPC:   265 call_connect xprt ffff8800754d5800 is not connected
RPC:   265 xprt_connect xprt ffff8800754d5800 is not connected
RPC:   265 xprt_cwnd_limited cong = 0 cwnd = 256
RPC:   265 sleep_on(queue "xprt_pending" time 4432659044)
RPC:   265 added to queue ffff8800754d5af0 "xprt_pending"
RPC:   265 setting alarm for 5000 ms
RPC:       xs_connect scheduled xprt ffff8800754d5800
RPC:   265 sync task going to sleep
RPC:       disconnected transport ffff8800754d5800
RPC:   265 __rpc_wake_up_task (now 4432659044)
RPC:   265 disabling timer
RPC:   265 removed from queue ffff8800754d5af0 "xprt_pending"
RPC:       __rpc_wake_up_task done
RPC:       xs_bind4 0.0.0.0:803: ok (0)
RPC:       worker connecting xprt ffff8800754d5800 to address: 
addr=127.0.0.1 port=111 proto=udp
RPC:   265 sync task resuming
RPC:   265 xprt_connect_status: connection broken
RPC:   265 call_connect_status (status -107)
RPC:   265 call_timeout (minor)
RPC:   265 call_bind (status 0)
RPC:   265 call_connect xprt ffff8800754d5800 is connected
RPC:   265 call_transmit (status 0)
RPC:   265 xprt_prepare_transmit
RPC:   265 rpc_xdr_encode (status 0)
RPC:   265 marshaling UNIX cred ffff88007b89b780
RPC:   265 using AUTH_UNIX cred ffff88007b89b780 to wrap rpc data
RPC:       rpcb_encode_mapping(1073741824, 1, 0, 0)
RPC:   265 xprt_transmit(124)
RPC:       xs_udp_send_request(124) = 124
RPC:   265 xmit complete
RPC:   265 sleep_on(queue "xprt_pending" time 4432659045)
RPC:   265 added to queue ffff8800754d5af0 "xprt_pending"
RPC:   265 setting alarm for 10000 ms
RPC:   265 sync task going to sleep
RPC:       xs_udp_data_ready...
RPC:       cong 256, cwnd was 256, now 512
RPC:       wake_up_next(ffff8800754d5a38 "xprt_resend")
RPC:       wake_up_next(ffff8800754d5980 "xprt_sending")
RPC:   265 xid 9bb8d49b complete (28 bytes received)
RPC:   265 __rpc_wake_up_task (now 4432659045)
RPC:   265 disabling timer
RPC:   265 removed from queue ffff8800754d5af0 "xprt_pending"
RPC:       __rpc_wake_up_task done
RPC:   265 sync task resuming
RPC:   265 call_status (status 28)
RPC:   265 call_decode (status 28)
RPC:   265 validating UNIX cred ffff88007b89b780
RPC:   265 using AUTH_UNIX cred ffff88007b89b780 to unwrap rpc data
RPC:       rpcb_decode_set: call succeeded
RPC:   265 call_decode result 0
RPC:   265 return 0, status 0
RPC:   265 release task
RPC:       freeing buffer of size 416 at ffff8800754d0800
RPC:   265 release request ffff88006bcd8000
RPC:       wake_up_next(ffff8800754d5ba8 "xprt_backlog")
RPC:   265 releasing UNIX cred ffff88007b89b780
RPC:       rpc_release_client(ffff88006f405c00)
RPC:   265 freeing task
RPC:       shutting down rpcbind client for localhost
RPC:       rpc_release_client(ffff88006f405c00)
RPC:       destroying UNIX authenticator ffffffffa02505a0
RPC:       destroying rpcbind client for localhost
RPC:       destroying transport ffff8800754d5800
RPC:       xs_destroy xprt ffff8800754d5800
RPC:       xs_close xprt ffff8800754d5800
RPC:       disconnected transport ffff8800754d5800
RPC:       registration status 0/1
svc: creating transport tcp[0]
svc: svc_create_socket(NFSv4 callback, 6, 0.0.0.0, port=0)
svc: svc_setup_socket ffff88005a881680
setting up TCP socket for listening
svc: svc_setup_socket created ffff88007b40fe00 (inet ffff88007717c780)
Callback port = 0x90d2
svc: svc_destroy(NFSv4 callback, 2)
RPC:       looking up machine cred
--> nfs_get_client() = ffff880058f45800 [new]
RPC:       set up transport to address addr=192.168.3.87 port=2049 proto=tcp
RPC:       created transport ffff880075514000 with 16 slots
RPC:       creating nfs client for mango (xprt ffff880075514000)
RPC:       creating GSS authenticator for client ffff880052301600
RPC:     0 holding NULL cred ffffffffa0250510
RPC:       new task initialized, procpid 10475
RPC:       allocated task ffff88007b593e00
RPC:   266 __rpc_execute flags=0x280
RPC:   266 call_start nfs4 proc NULL (sync)
RPC:   266 call_reserve (status 0)
RPC:   266 reserved req ffff880032ff6000 xid 020534a5
RPC:   266 call_reserveresult (status 0)
RPC:   266 call_allocate (status 0)
RPC:   266 allocated buffer of size 96 at ffff880075510000
RPC:   266 call_bind (status 0)
RPC:   266 call_connect xprt ffff880075514000 is not connected
RPC:   266 xprt_connect xprt ffff880075514000 is not connected
RPC:   266 sleep_on(queue "xprt_pending" time 4432659045)
RPC:   266 added to queue ffff8800755142f0 "xprt_pending"
RPC:   266 setting alarm for 60000 ms
RPC:       xs_connect scheduled xprt ffff880075514000
RPC:   266 sync task going to sleep
svc: server ffff88006bcd8000 waiting for data (to = 9223372036854775807)
RPC:       xs_bind4 0.0.0.0:812: ok (0)
RPC:       worker connecting xprt ffff880075514000 to address: 
addr=192.168.3.87 port=2049 proto=tcp
RPC:       xs_tcp_state_change client ffff880075514000...
RPC:       state 1 conn 0 dead 0 zapped 1
RPC:   266 __rpc_wake_up_task (now 4432659045)
RPC:   266 disabling timer
RPC:   266 removed from queue ffff8800755142f0 "xprt_pending"
RPC:       __rpc_wake_up_task done
svc: socket ffff880077179a00 TCP (listen) state change 10
svc: transport ffff880032f55000 busy, not enqueued
RPC:       ffff880075514000 connect status 115 connected 1 sock state 1
RPC:   266 sync task resuming
RPC:   266 xprt_connect_status: connection established
RPC:   266 call_connect_status (status 0)
RPC:   266 call_transmit (status 0)
RPC:   266 xprt_prepare_transmit
RPC:   266 rpc_xdr_encode (status 0)
RPC:   266 marshaling NULL cred ffffffffa0250510
RPC:   266 using AUTH_NULL cred ffffffffa0250510 to wrap rpc data
RPC:   266 xprt_transmit(44)
svc: socket ffff880077179380 TCP (listen) state change 1
RPC:       xs_tcp_send_request(44) = 44
RPC:   266 xmit complete
RPC:   266 sleep_on(queue "xprt_pending" time 4432659045)
RPC:   266 added to queue ffff8800755142f0 "xprt_pending"
RPC:   266 setting alarm for 60000 ms
RPC:       wake_up_next(ffff880075514238 "xprt_resend")
RPC:       wake_up_next(ffff880075514180 "xprt_sending")
RPC:   266 sync task going to sleep
RPC:       unx_free_cred ffff88007b89b780
NFSD: laundromat service - starting
NFSD: laundromat_main - sleeping for 90 seconds

Thanks,

Chris.

------------------------------------------------------------------------------
Open Source Business Conference (OSBC), March 24-25, 2009, San Francisco, CA
-OSBC tackles the biggest issue in open source: Open Sourcing the Enterprise
-Strategies to boost innovation and cut costs with open source participation
-Receive a $600 discount off the registration fee with the source code: SFAD
http://p.sf.net/sfu/XcvMzF8H
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
_______________________________________________
Please note that nfs@lists.sourceforge.net is being discontinued.
Please subscribe to linux-nfs@vger.kernel.org instead.
    http://vger.kernel.org/vger-lists.html#linux-nfs

