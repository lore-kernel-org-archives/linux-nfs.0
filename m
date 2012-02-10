Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mailout-de.gmx.net ([213.165.64.23]:33272 "HELO
	mailout-de.gmx.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1755085Ab2BJOp2 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 10 Feb 2012 09:45:28 -0500
Date: Fri, 10 Feb 2012 15:45:26 +0100
From: <whats_up@gmx.net>
To: linux-nfs@vger.kernel.org
Subject: mount hangs in NFS4+Kerberos setup
Message-ID: <20120210154526.7b504146@little-poseidon>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


Hi, 

I want to setup a file server with NFS4+Kerberos and Debian squeeze for
clients running Ubuntu 11.10.

What is already working:
1) Mount NFS4 on client without krb5 option works. Users are able to
access files and uids/gids are correct. 2) KDC works. Access from
client, get tickets, user authentication/change password through pam is
ok.

Now I want to mount with sec=krb5 but this time the command hangs and
does not return to shell. See also logs below.

Any hints to fix the issue or to get more helpful debug information are
welcome.

regards
  knut




=== server status ===

Debian Linux squeeze

# uname -a
Linux tm 2.6.32-5-686 #1 SMP Mon Jan 16 16:04:25 UTC 2012 i686 GNU/Linux

# cat /etc/exports 
/srv        *(rw,sync,no_subtree_check,fsid=0,crossmnt)
/srv/opt    *(sec=sys:krb5,rw,sync,no_subtree_check)

# ps -ef|grep -e rpc -e portmap -e nfs
daemon    1019     1  0 10:26 ?        00:00:00 /sbin/portmap
root      1043     2  0 10:26 ?        00:00:00 [rpciod/0]
root      1044     2  0 10:26 ?        00:00:00 [rpciod/1]
root      1055     2  0 10:26 ?        00:00:00 [nfsiod]
root      1079     1  0 10:26 ?        00:00:00 /usr/sbin/rpc.idmapd -vvv
root      1083     1  0 10:26 ?        00:00:00 /usr/sbin/rpc.gssd -vvv
root      1309     2  0 10:26 ?        00:00:00 [nfsd4]
root      1310     2  0 10:26 ?        00:00:00 [nfsd]
...
root      1336     1  0 10:26 ?        00:00:00 /usr/sbin/rpc.svcgssd -vvv
root      1338     1  0 10:26 ?        00:00:00 /usr/sbin/rpc.mountd --manage-gids

# rpcdebug -m nfsd -s all


=== client status ===

Ubuntu Linux 10.11

# uname -a
Linux orest 3.0.0-15-generic #26-Ubuntu SMP Fri Jan 20 15:59:53 UTC 2012 i686 i686 i386 GNU/Linux

# ps -ef |grep rpc
root       702     1  0 13:16 ?        00:00:00 rpcbind -w
root       712     2  0 13:16 ?        00:00:00 [rpciod]
root       805     1  0 13:16 ?        00:00:00 rpc.gssd -vvv
root       890     1  0 13:16 ?        00:00:00 rpc.idmapd -vvv


=== client log ===

# mount -t nfs4 <server-fqdn>:/opt /opt
# umount /opt

# mount -t nfs4 -osec=krb5 <server-fqdn>:/opt /opt
Feb 10 14:45:17 orest rpc.gssd[883]: dir_notify_handler: sig 37 si 0xbfe7584c data 0xbfe758cc
Feb 10 14:45:17 orest rpc.idmapd[728]: New client: 0
Feb 10 14:45:17 orest rpc.gssd[883]: dir_notify_handler: sig 37 si 0xbfe7102c data 0xbfe710ac
Feb 10 14:45:17 orest rpc.idmapd[728]: Opened /var/lib/nfs/rpc_pipefs/nfs/clnt0/idmap
Feb 10 14:45:17 orest rpc.gssd[883]: dir_notify_handler: sig 37 si 0xbfe7102c data 0xbfe710ac
Feb 10 14:45:17 orest rpc.idmapd[728]: New client: 1
Feb 10 14:45:17 orest rpc.gssd[883]: handling gssd upcall (/var/lib/nfs/rpc_pipefs/nfs/clnt0)
Feb 10 14:45:17 orest rpc.gssd[883]: handle_gssd_upcall: 'mech=krb5 uid=0 enctypes=18,17,16,23,3,1,2 '
Feb 10 14:45:17 orest rpc.gssd[883]: handling krb5 upcall (/var/lib/nfs/rpc_pipefs/nfs/clnt0)
Feb 10 14:45:17 orest rpc.gssd[883]: process_krb5_upcall: service is '<null>'
Feb 10 14:45:17 orest rpc.gssd[883]: Full hostname for '<server-fqdn>' is '<server-fqdn>'
Feb 10 14:45:17 orest rpc.gssd[883]: Full hostname for '<client-fqdn>' is '<client-fqdn>'
Feb 10 14:45:17 orest rpc.gssd[883]: No key table entry found for <CLIENT-HOSTNAME>$@<MYREALM> while getting keytab entry for '<CLIENT-HOSTNAME>$@<MYREALM>'
Feb 10 14:45:17 orest rpc.gssd[883]: Success getting keytab entry for 'root/<client-fqdn>@<MYREALM>'
Feb 10 14:45:17 orest rpc.gssd[883]: Successfully obtained machine credentials for principal 'root/<client-fqdn>@<MYREALM>' stored in ccache 'FILE:/tmp/krb5cc_machine_<MYREALM>'
Feb 10 14:45:17 orest rpc.gssd[883]: INFO: Credentials in CC 'FILE:/tmp/krb5cc_machine_<MYREALM>' are good until 1328967917
Feb 10 14:45:17 orest rpc.gssd[883]: using FILE:/tmp/krb5cc_machine_<MYREALM> as credentials cache for machine creds
Feb 10 14:45:17 orest rpc.gssd[883]: using environment variable to select krb5 ccache FILE:/tmp/krb5cc_machine_<MYREALM>
Feb 10 14:45:17 orest rpc.gssd[883]: creating context using fsuid 0 (save_uid 0)
Feb 10 14:45:17 orest rpc.gssd[883]: creating tcp client for server <server-fqdn>
Feb 10 14:45:17 orest rpc.gssd[883]: DEBUG: port already set to 2049
Feb 10 14:45:17 orest rpc.gssd[883]: creating context with server nfs@<server-fqdn>
Feb 10 14:45:17 orest rpc.gssd[883]: DEBUG: serialize_krb5_ctx: lucid version!
Feb 10 14:45:17 orest rpc.gssd[883]: prepare_krb5_rfc1964_buffer: serializing keys with enctype 4 and length 8
Feb 10 14:45:17 orest rpc.gssd[883]: doing downcall

(waiting...)

Feb 10 14:48:17 orest kernel: [  249.312058] nfs: server <server-fqdn> not responding, still trying

(press Ctrl-C, >10 min later)

Feb 10 14:59:40 orest rpc.gssd[883]: dir_notify_handler: sig 37 si 0xbfe7584c data 0xbfe758cc
Feb 10 14:59:40 orest rpc.gssd[883]: dir_notify_handler: sig 37 si 0xbfe7584c data 0xbfe758cc
Feb 10 14:59:40 orest rpc.gssd[883]: destroying client /var/lib/nfs/rpc_pipefs/nfs/clnt1
Feb 10 14:59:40 orest rpc.idmapd[728]: Stale client: 1
Feb 10 14:59:40 orest rpc.idmapd[728]: #011-> closed /var/lib/nfs/rpc_pipefs/nfs/clnt1/idmap
Feb 10 14:59:40 orest rpc.gssd[883]: dir_notify_handler: sig 37 si 0xbfe7584c data 0xbfe758cc
Feb 10 14:59:40  rpc.gssd[883]: last message repeated 4 times
Feb 10 14:59:40 orest rpc.idmapd[728]: Stale client: 0
Feb 10 14:59:40 orest rpc.idmapd[728]: #011-> closed /var/lib/nfs/rpc_pipefs/nfs/clnt0/idmap
Feb 10 14:59:40 orest rpc.gssd[883]: destroying client /var/lib/nfs/rpc_pipefs/nfs/clnt0



=== server log ===

The following messages appeared while initiating mount command on client:

==> auth.log <==
Feb 10 14:45:17 tm krb5kdc[1429]: AS_REQ (7 etypes {18 17 16 23 1 3 2}) <client-IP>: NEEDED_PREAUTH: root/<client-fqdn>@<MYREALM> for krbtgt/<MYREALM>@<MYREALM>, Additional pre-authentication required
Feb 10 14:45:17 tm krb5kdc[1429]: AS_REQ (7 etypes {18 17 16 23 1 3 2}) <client-IP>: ISSUE: authtime 1328881517, etypes {rep=1 tkt=18 ses=18}, root/<client-fqdn>@<MYREALM> for krbtgt/<MYREALM>@<MYREALM>
Feb 10 14:45:17 tm krb5kdc[1429]: TGS_REQ (7 etypes {18 17 16 23 1 3 2}) <client-IP>: ISSUE: authtime 1328881517, etypes {rep=18 tkt=1 ses=1}, root/<client-fqdn>@<MYREALM> for nfs/<server-fqdn>@<MYREALM>

==> syslog <==
Feb 10 14:45:17 tm rpc.svcgssd[1335]: leaving poll
Feb 10 14:45:17 tm rpc.svcgssd[1335]: handling null request
Feb 10 14:45:17 tm rpc.svcgssd[1335]: sname = root/<client-fqdn>@<MYREALM>
Feb 10 14:45:17 tm rpc.svcgssd[1335]: libnfsidmap: using (default) domain: cs.uni-potsdam.de
Feb 10 14:45:17 tm rpc.svcgssd[1335]: libnfsidmap: loaded plugin /usr/lib/libnfsidmap/nsswitch.so for method nsswitch
Feb 10 14:45:17 tm rpc.svcgssd[1335]: nss_gss_princ_to_ids: Local-Realm '<MYREALM>': NOT FOUND
Feb 10 14:45:17 tm rpc.svcgssd[1335]: DEBUG: serialize_krb5_ctx: lucid version!
Feb 10 14:45:17 tm rpc.svcgssd[1335]: prepare_krb5_rfc1964_buffer: serializing keys with enctype 4 and length 8
Feb 10 14:45:17 tm rpc.svcgssd[1335]: doing downcall
Feb 10 14:45:17 tm rpc.svcgssd[1335]: mech: krb5, hndl len: 4, ctx len 85, timeout: 1328967917 (86400 from now), clnt: root@<client-fqdn>, uid: -1, gid: -1, num aux grps: 0:
Feb 10 14:45:17 tm rpc.svcgssd[1335]: sending null reply
Feb 10 14:45:17 tm rpc.svcgssd[1335]: writing message: \x \x..<lots of digits> 1328881577 0 0 \x01000000 \x607006092a864886f71201020202006f61305fa003020105a10302010fa2533051a003020101a24a0448d85b3308847004f703039fd5f315f81fcbb287c6a53821eb2ea8660169c687bbb0f1d7fbdecb9016284f3adf11b122949b98488862d956d352c6c14e6fd2beb565ba1de7afc99d1c 
Feb 10 14:45:17 tm rpc.svcgssd[1335]: finished handling null request
Feb 10 14:45:17 tm rpc.svcgssd[1335]: entering poll

(waiting...)

