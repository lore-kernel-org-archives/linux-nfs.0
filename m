Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:42168 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756077Ab0KPTP0 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 16 Nov 2010 14:15:26 -0500
Date: Tue, 16 Nov 2010 14:15:25 -0500
To: arnaud.desmier@free.fr
Cc: linux-nfs@vger.kernel.org
Subject: Re: Problems using sec=krb5 with also sec=sys in any share
Message-ID: <20101116191524.GE3971@fieldses.org>
References: <1215084548.814871288266525238.JavaMail.root@spooler8-g27.priv.proxad.net>
 <1768058289.815041288266574453.JavaMail.root@spooler8-g27.priv.proxad.net>
Content-Type: text/plain; charset=utf-8
In-Reply-To: <1768058289.815041288266574453.JavaMail.root@spooler8-g27.priv.proxad.net>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Thu, Oct 28, 2010 at 01:49:34PM +0200, arnaud.desmier@free.fr wrote:
> No idea about this problem? no one encountered the same problem?
> 
> Maybe there is an other mailing list for this kind of problem?

On a quick skim nothing jumps out at me.  If I were you my next step
would be to run wireshark and see if you can figure out what happens on
the wire in the case where there's a hang.  What are the client and
server kernel versions?

> 
> Thanks,
> 
> Arnaud
> 
> ----- Mail Original -----
> De: "arnaud desmier" <arnaud.desmier@free.fr>
> À: linux-nfs@vger.kernel.org
> Envoyé: Mardi 26 Octobre 2010 14h08:10 GMT +01:00 Amsterdam / Berlin / Berne / Rome / Stockholm / Vienne
> Objet: Problems using sec=krb5 with also sec=sys in any share
> 
> Hi all,
> 
> I'm trying to share some folders like /home and /var/mail with differents security flavors between some machines in a virtual network using VirtualBox. My virtual network is compunded of :
>  - my NFS server, also called nashome, IP address : 192.168.10.5. It's a Debian Squeeze Virtual Machine, using nfs-utils 1.2.2
>  - my email server, also called servicesext (external services), IP address : 10.1.2.10. It's a Debian Squeeze Virtual Machine, using nfs-utils 1.2.2
>  - my kerberos (MIT) server, also called serviceint (internal services), IP address : 192.168.10.4. It's a Debian Squeeze Virtual Machine
>  - my user computer, also called posteA, IP address : 192.168.10.50. It's an Ubuntu 10.10
> 
> NFS shared folders constraints are following :
>  - /home must be accessed using kerberos identification, I have to mount it on servicesext and posteA
>  - /var/mail is filled by exim4 so I can't use kerberos authentication, only sys flavor, I have to mount it on servicesext only
> 
> /export/home and /export/mail are bind mount : 
> mount --bind /var/mail/ /export/mail/
> mount --bind /home /export/home/
> 
> All Squeeze machines have been updated at the same time and tests have reproduced using nfs-utils 1.2.2 with and without debian patches, and also with nfs-utils 1.2.3. Each time the same result.
> 
> 1. Each time, when a share folder is set with sec=krb5 as security flavor, client is blocked and mount command never ends. For example (/etc/exports) : 
> /export        -fsid=0,insecure,no_subtree_check 10.1.2.10(sec=sys:krb5) 192.168.10.50(sec=krb5)
> /export/home   -sec=krb5,rw,nohide,insecure,no_subtree_check 192.168.10.50 10.1.2.10
> /export/mail   -sec=sys,rw,nohide,insecure,no_subtree_check 10.1.2.10

I can't see off hand why that shouldn't work....

>  - Using my servicesext (10.1.2.10) machine, I can mount nashome:/mail :
>    # umount /mnt/nfs4; mount -t nfs4 nashome:/mail /mnt/nfs4 -vvvv
>  - but when I try to mount nashome:/home, mount command never ends (see logs below)
>    # umount /mnt/nfs4; mount -t nfs4 -o sec=krb5 nashome:/home /mnt/nfs4 -vvvv
> 
> 
> 2. Instead of using sec=krb5, I will use old expression gss/krb5 : the following does not work
> /export        -fsid=0,insecure,no_subtree_check 10.1.2.10(sec=sys:krb5) 192.168.10.50(sec=krb5) gss/krb5
> /export/home   -sec=krb5,rw,nohide,insecure,no_subtree_check 192.168.10.50 10.1.2.10 gss/krb5
> /export/mail   -sec=sys,rw,nohide,insecure,no_subtree_check 10.1.2.10
> 
> 
> 3. And an amazing thing, if I remove all authentications except gss/krb5 I can mount nashome:/home (see logs below). Mounting on posteA works only if I remove it's IP address 192.168.10.50 from second line.

Yeah, exports that vary security flavor requirements based on ip address
were never supported with the old syntax.

--b.

> /export        -fsid=0,insecure,no_subtree_check gss/krb5
> /export/home   -rw,nohide,insecure,no_subtree_check 192.168.10.50 gss/krb5
> #/export/mail   -sec=sys,rw,nohide,insecure,no_subtree_check 10.1.2.10
> 
> 
> Following are logs files for mount and syslog on servicesext, nashome syslog, and servicesint Kerberos KDC logs for step 1 when mounting nashome:/home
> 
>  - mount logs : 
> mount: fstab path: "/etc/fstab"
> mount: mtab path:  "/etc/mtab"
> mount: lock path:  "/etc/mtab~"
> mount: temp path:  "/etc/mtab.tmp"
> mount: UID:        0
> mount: eUID:       0
> mount: spec:  "nashome:/home"
> mount: node:  "/mnt/nfs4"
> mount: types: "nfs4"
> mount: opts:  "sec=krb5"
> mount: external mount: argv[0] = "/sbin/mount.nfs4"
> mount: external mount: argv[1] = "nashome:/home"
> mount: external mount: argv[2] = "/mnt/nfs4"
> mount: external mount: argv[3] = "-v"
> mount: external mount: argv[4] = "-o"
> mount: external mount: argv[5] = "rw,sec=krb5"
> mount.nfs4: timeout set for Tue Oct 26 12:06:40 2010
> mount.nfs4: trying text-based options 'sec=krb5,addr=192.168.10.5,clientaddr=10.1.2.10'
> 
> 
>  - Servicesext syslog :
> Oct 26 12:04:40 servicesext rpc.idmapd[587]: New client: 0
> Oct 26 12:04:40 servicesext rpc.idmapd[587]: Opened /var/lib/nfs/rpc_pipefs/nfs/clnt0/idmap
> Oct 26 12:04:40 servicesext rpc.idmapd[587]: New client: 1
> Oct 26 12:04:40 servicesext rpc.gssd[591]: handling gssd upcall (/var/lib/nfs/rpc_pipefs/nfs/clnt0)
> Oct 26 12:04:40 servicesext rpc.gssd[591]: handle_gssd_upcall: 'mech=krb5 uid=0 '
> Oct 26 12:04:40 servicesext rpc.gssd[591]: handling krb5 upcall (/var/lib/nfs/rpc_pipefs/nfs/clnt0)
> Oct 26 12:04:40 servicesext rpc.gssd[591]: process_krb5_upcall: service is '<null>'
> Oct 26 12:04:40 servicesext rpc.gssd[591]: Full hostname for 'nashome.desmier.org' is 'nashome.desmier.org'
> Oct 26 12:04:40 servicesext rpc.gssd[591]: Full hostname for 'servicesext.desmier.org' is 'servicesext.desmier.org'
> Oct 26 12:04:40 servicesext rpc.gssd[591]: Key table entry not found while getting keytab entry for 'root/servicesext.desmier.org@DESMIER.ORG'
> Oct 26 12:04:40 servicesext rpc.gssd[591]: Success getting keytab entry for 'nfs/servicesext.desmier.org@DESMIER.ORG'
> Oct 26 12:04:40 servicesext rpc.gssd[591]: Successfully obtained machine credentials for principal 'nfs/servicesext.desmier.org@DESMIER.ORG' stored in ccache 'FILE:/tmp/krb5cc_machine_DESMIER.ORG'
> Oct 26 12:04:40 servicesext rpc.gssd[591]: INFO: Credentials in CC 'FILE:/tmp/krb5cc_machine_DESMIER.ORG' are good until 1288123449
> Oct 26 12:04:40 servicesext rpc.gssd[591]: using FILE:/tmp/krb5cc_machine_DESMIER.ORG as credentials cache for machine creds
> Oct 26 12:04:40 servicesext rpc.gssd[591]: using environment variable to select krb5 ccache FILE:/tmp/krb5cc_machine_DESMIER.ORG
> Oct 26 12:04:40 servicesext rpc.gssd[591]: creating context using fsuid 0 (save_uid 0)
> Oct 26 12:04:40 servicesext rpc.gssd[591]: creating tcp client for server nashome.desmier.org
> Oct 26 12:04:40 servicesext rpc.gssd[591]: DEBUG: port already set to 2049
> Oct 26 12:04:40 servicesext rpc.gssd[591]: creating context with server nfs@nashome.desmier.org
> Oct 26 12:04:40 servicesext rpc.gssd[591]: in authgss_create_default()
> Oct 26 12:04:40 servicesext rpc.gssd[591]: in authgss_create()
> Oct 26 12:04:40 servicesext rpc.gssd[591]: authgss_create: name is 0xa047908
> Oct 26 12:04:40 servicesext rpc.gssd[591]: authgss_create: gd->name is 0xa047e38
> Oct 26 12:04:40 servicesext rpc.gssd[591]: in authgss_refresh()
> Oct 26 12:04:40 servicesext rpc.gssd[591]: struct rpc_gss_sec:
> Oct 26 12:04:40 servicesext rpc.gssd[591]:      mechanism_OID: { 1 2 134 72 134 247 18 1 2 2 }
> Oct 26 12:04:40 servicesext rpc.gssd[591]:      qop: 0
> Oct 26 12:04:40 servicesext rpc.gssd[591]:      service: 1
> Oct 26 12:04:40 servicesext rpc.gssd[591]:      cred: 0xa047c10
> Oct 26 12:04:40 servicesext rpc.gssd[591]:      req_flags: 00000002
> Oct 26 12:04:40 servicesext rpc.gssd[591]: in authgss_marshal()
> Oct 26 12:04:40 servicesext rpc.gssd[591]: xdr_rpc_gss_buf: encode success ((nil):0)
> Oct 26 12:04:40 servicesext rpc.gssd[591]: xdr_rpc_gss_cred: encode success (v 1, proc 1, seq 0, svc 1, ctx (nil):0)
> Oct 26 12:04:40 servicesext rpc.gssd[591]: xdr_rpc_gss_buf: encode success (0xa04b410:586)
> Oct 26 12:04:40 servicesext rpc.gssd[591]: xdr_rpc_gss_init_args: encode success (token 0xa04b410:586)
> Oct 26 12:04:40 servicesext rpc.gssd[591]: in authgss_validate()
> Oct 26 12:04:40 servicesext rpc.gssd[591]: xdr_rpc_gss_buf: decode success (0xa047440:4)
> Oct 26 12:04:40 servicesext rpc.gssd[591]: xdr_rpc_gss_buf: decode success (0xa04b660:114)
> Oct 26 12:04:40 servicesext rpc.gssd[591]: xdr_rpc_gss_init_res decode success (ctx 0xa047440:4, maj 0, min 0, win 128, token 0xa04b660:114)
> Oct 26 12:04:40 servicesext rpc.gssd[591]: authgss_create_default: freeing name 0xa047908
> Oct 26 12:04:40 servicesext rpc.gssd[591]: in authgss_get_private_data()
> Oct 26 12:04:40 servicesext rpc.gssd[591]: DEBUG: serialize_krb5_ctx: lucid version!
> Oct 26 12:04:40 servicesext rpc.gssd[591]: prepare_krb5_rfc1964_buffer: serializing keys with enctype 4 and length 8
> Oct 26 12:04:40 servicesext rpc.gssd[591]: doing downcall
> Oct 26 12:04:40 servicesext rpc.gssd[591]: in authgss_free_private_data()
> Oct 26 12:04:40 servicesext rpc.gssd[591]: in authgss_destroy()
> Oct 26 12:04:40 servicesext rpc.gssd[591]: in authgss_destroy_context()
> Oct 26 12:04:40 servicesext rpc.gssd[591]: authgss_destroy: freeing name 0xa047e38
> Oct 26 12:07:40 servicesext kernel: [  231.993067] nfs: server nashome not responding, still trying
> 
>  - When I kill mount with Ctrl+C : 
> Oct 26 12:22:13 servicesext rpc.idmapd[587]: Stale client: 1
> Oct 26 12:22:13 servicesext rpc.idmapd[587]: #011-> closed /var/lib/nfs/rpc_pipefs/nfs/clnt1/idmap
> Oct 26 12:22:13 servicesext rpc.idmapd[587]: Stale client: 0
> Oct 26 12:22:13 servicesext rpc.idmapd[587]: #011-> closed /var/lib/nfs/rpc_pipefs/nfs/clnt0/idmap
> Oct 26 12:22:13 servicesext rpc.gssd[591]: destroying client /var/lib/nfs/rpc_pipefs/nfs/clnt1
> Oct 26 12:22:13 servicesext rpc.gssd[591]: destroying client /var/lib/nfs/rpc_pipefs/nfs/clnt0
> 
> 
>  - Nashome syslog : 
> Oct 26 12:04:09 nashome rpc.svcgssd[2775]: leaving poll
> Oct 26 12:04:09 nashome rpc.svcgssd[2775]: handling null request
> Oct 26 12:04:09 nashome rpc.svcgssd[2775]: sname = nfs/servicesext.desmier.org@DESMIER.ORG
> Oct 26 12:04:09 nashome rpc.svcgssd[2775]: DEBUG: serialize_krb5_ctx: lucid version!
> Oct 26 12:04:09 nashome rpc.svcgssd[2775]: prepare_krb5_rfc1964_buffer: serializing keys with enctype 4 and length 8
> Oct 26 12:04:09 nashome rpc.svcgssd[2775]: doing downcall
> Oct 26 12:04:09 nashome rpc.svcgssd[2775]: mech: krb5, hndl len: 4, ctx len 85, timeout: 1288123449 (36000 from now), clnt: nfs@servicesext.desmier.org, uid: -1, gid: -1, num aux grps: 0:
> Oct 26 12:04:09 nashome rpc.svcgssd[2775]: sending null reply
> Oct 26 12:04:09 nashome rpc.svcgssd[2775]: writing message: \x \x6082024606092a864886f71201020201006e82023530820231a003020105a10302010ea20703050020000000a38201596182015530820151a003020105a10d1b0b4445534d4945522e4f5247a2253023a003020103a11c301a1b036e66731b136e6173686f6d652e6465736d6965722e6f7267a38201123082010ea003020112a103020107a28201000481fdd265dab6ac3f0baf6338d64153d32b4873c93c166b66eff6cb7b48e85f13a24d21fc7d0fb94e76cc14df4d4d2291588b7759fb497d2c23c622f9dd1da834a97c0a2027e075444a846f63747d375b6db9ad5aae106e639703653bec4e7a8e06f6dcbd1d3c03305fb3b01d84024697e2cfa34277d15ec1b96c164d344ca00444335ccefdcdf275ab6cb6767adf1d2706b9f0ce32d6bde3e9729e807dd4471531b1f96a31dda0be6938782724b7e72983c7ae796abeac1ddec8fab06e486bbab2c5c5fe789b93fa3eabc994142920ba4b725c2266bd615c08f4d603748fb568ff7f921105a379425fcff276db52560e53198faf29ba55345951d89b322318a481be3081bba003020101a281b30481b0be97d17110d6ca7d64716a301d5b741256068040fa844a607613cb8fc1235774c3a4fbe5669fdc8edcf92af25a6651cdd8cb11!
 b4f
>  ccf06affbe76e4d9905d8cfa1c6202990b3471895f37ff1ba5d5caf9d7980c2b0a7fffe67e0f9c2b7929d10488034727b013e725abae91fce125d1fae14f0959e714442e459f0868db3af26b395386f854fcb450d5889321250a75a0f142dcfb721e244aa2233e269d65e9f1f20a1350f691765210c2eb7ddfcab78 1288087509 0 0 \x02000000 \x607006092a864886f71201020202006f61305fa003020105a10302010fa2533051a003020101a24a0448cdd3980ca17e39234e4b5f8d0ed3295cf4716a92830ae3d61fa5716d69d41cf6d5d6e676e0a35ef1d02bd1014fb6191846add36ae5b15b2e820f23f4ccaceb4ec63431bb0df9dcbe 
> Oct 26 12:04:09 nashome rpc.svcgssd[2775]: finished handling null request
> Oct 26 12:04:09 nashome rpc.svcgssd[2775]: entering poll
> 
> 
>  - servicesint Kerberos KDC logs :
> Oct 26 12:04:09 servicesint krb5kdc[1000](info): AS_REQ (7 etypes {18 17 16 23 1 3 2}) 10.1.2.10: NEEDED_PREAUTH: nfs/servicesext.desmier.org@DESMIER.ORG for krbtgt/DESMIER.ORG@DESMIER.ORG, Additional pre-authentication required
> Oct 26 12:04:09 servicesint krb5kdc[1000](info): AS_REQ (7 etypes {18 17 16 23 1 3 2}) 10.1.2.10: ISSUE: authtime 1288087449, etypes {rep=18 tkt=18 ses=18}, nfs/servicesext.desmier.org@DESMIER.ORG for krbtgt/DESMIER.ORG@DESMIER.ORG
> Oct 26 12:04:09 servicesint krb5kdc[1000](info): TGS_REQ (7 etypes {18 17 16 23 1 3 2}) 10.1.2.10: ISSUE: authtime 1288087449, etypes {rep=18 tkt=18 ses=18}, nfs/servicesext.desmier.org@DESMIER.ORG for nfs/nashome.desmier.org@DESMIER.ORG
> Oct 26 12:04:09 servicesint krb5kdc[1000](info): TGS_REQ (3 etypes {1 3 2}) 10.1.2.10: ISSUE: authtime 1288087449, etypes {rep=18 tkt=18 ses=1}, nfs/servicesext.desmier.org@DESMIER.ORG for nfs/nashome.desmier.org@DESMIER.ORG
> 
> 
> Following are logs files for mount and syslog on servicesext, nashome syslog, and servicesint Kerberos KDC logs for step 3 when mounting nashome:/home
> 
>  - Servicesext mount logs :
> mount: fstab path: "/etc/fstab"
> mount: mtab path:  "/etc/mtab"
> mount: lock path:  "/etc/mtab~"
> mount: temp path:  "/etc/mtab.tmp"
> mount: UID:        0
> mount: eUID:       0
> mount: spec:  "nashome:/home"
> mount: node:  "/mnt/nfs4"
> mount: types: "nfs4"
> mount: opts:  "sec=krb5"
> mount: external mount: argv[0] = "/sbin/mount.nfs4"
> mount: external mount: argv[1] = "nashome:/home"
> mount: external mount: argv[2] = "/mnt/nfs4"
> mount: external mount: argv[3] = "-v"
> mount: external mount: argv[4] = "-o"
> mount: external mount: argv[5] = "rw,sec=krb5"
> mount.nfs4: timeout set for Tue Oct 26 12:25:02 2010
> mount.nfs4: trying text-based options 'sec=krb5,addr=192.168.10.5,clientaddr=10.1.2.10'
> nashome:/home on /mnt/nfs4 type nfs4 (rw,sec=krb5)
> 
>  - Servicesext syslog :
> ct 26 12:23:02 servicesext rpc.idmapd[587]: New client: 2
> Oct 26 12:23:02 servicesext rpc.idmapd[587]: Opened /var/lib/nfs/rpc_pipefs/nfs/clnt2/idmap
> Oct 26 12:23:02 servicesext rpc.gssd[591]: handling gssd upcall (/var/lib/nfs/rpc_pipefs/nfs/clnt2)
> Oct 26 12:23:02 servicesext rpc.gssd[591]: handle_gssd_upcall: 'mech=krb5 uid=0 '
> Oct 26 12:23:02 servicesext rpc.gssd[591]: handling krb5 upcall (/var/lib/nfs/rpc_pipefs/nfs/clnt2)
> Oct 26 12:23:02 servicesext rpc.gssd[591]: process_krb5_upcall: service is '<null>'
> Oct 26 12:23:02 servicesext rpc.idmapd[587]: New client: 3
> Oct 26 12:23:02 servicesext rpc.gssd[591]: Full hostname for 'nashome.desmier.org' is 'nashome.desmier.org'
> Oct 26 12:23:02 servicesext rpc.gssd[591]: Full hostname for 'servicesext.desmier.org' is 'servicesext.desmier.org'
> Oct 26 12:23:02 servicesext rpc.gssd[591]: Key table entry not found while getting keytab entry for 'root/servicesext.desmier.org@DESMIER.ORG'
> Oct 26 12:23:02 servicesext rpc.gssd[591]: Success getting keytab entry for 'nfs/servicesext.desmier.org@DESMIER.ORG'
> Oct 26 12:23:02 servicesext rpc.gssd[591]: INFO: Credentials in CC 'FILE:/tmp/krb5cc_machine_DESMIER.ORG' are good until 1288123449
> Oct 26 12:23:02 servicesext rpc.gssd[591]: INFO: Credentials in CC 'FILE:/tmp/krb5cc_machine_DESMIER.ORG' are good until 1288123449
> Oct 26 12:23:02 servicesext rpc.gssd[591]: using FILE:/tmp/krb5cc_machine_DESMIER.ORG as credentials cache for machine creds
> Oct 26 12:23:02 servicesext rpc.gssd[591]: using environment variable to select krb5 ccache FILE:/tmp/krb5cc_machine_DESMIER.ORG
> Oct 26 12:23:02 servicesext rpc.gssd[591]: creating context using fsuid 0 (save_uid 0)
> Oct 26 12:23:02 servicesext rpc.gssd[591]: creating tcp client for server nashome.desmier.org
> Oct 26 12:23:02 servicesext rpc.gssd[591]: DEBUG: port already set to 2049
> Oct 26 12:23:02 servicesext rpc.gssd[591]: creating context with server nfs@nashome.desmier.org
> Oct 26 12:23:02 servicesext rpc.gssd[591]: in authgss_create_default()
> Oct 26 12:23:02 servicesext rpc.gssd[591]: in authgss_create()
> Oct 26 12:23:02 servicesext rpc.gssd[591]: authgss_create: name is 0xa04b370
> Oct 26 12:23:02 servicesext rpc.gssd[591]: authgss_create: gd->name is 0xa047b90
> Oct 26 12:23:02 servicesext rpc.gssd[591]: in authgss_refresh()
> Oct 26 12:23:02 servicesext rpc.gssd[591]: struct rpc_gss_sec:
> Oct 26 12:23:02 servicesext rpc.gssd[591]:      mechanism_OID: { 1 2 134 72 134 247 18 1 2 2 }
> Oct 26 12:23:02 servicesext rpc.gssd[591]:      qop: 0
> Oct 26 12:23:02 servicesext rpc.gssd[591]:      service: 1
> Oct 26 12:23:02 servicesext rpc.gssd[591]:      cred: 0xa04b390
> Oct 26 12:23:02 servicesext rpc.gssd[591]:      req_flags: 00000002
> Oct 26 12:23:02 servicesext rpc.gssd[591]: in authgss_marshal()
> Oct 26 12:23:02 servicesext rpc.gssd[591]: xdr_rpc_gss_buf: encode success ((nil):0)
> Oct 26 12:23:02 servicesext rpc.gssd[591]: xdr_rpc_gss_cred: encode success (v 1, proc 1, seq 0, svc 1, ctx (nil):0)
> Oct 26 12:23:02 servicesext rpc.gssd[591]: xdr_rpc_gss_buf: encode success (0xa04a1f0:586)
> Oct 26 12:23:02 servicesext rpc.gssd[591]: xdr_rpc_gss_init_args: encode success (token 0xa04a1f0:586)
> Oct 26 12:23:02 servicesext rpc.gssd[591]: in authgss_validate()
> Oct 26 12:23:02 servicesext rpc.gssd[591]: xdr_rpc_gss_buf: decode success (0xa04c428:4)
> Oct 26 12:23:02 servicesext rpc.gssd[591]: xdr_rpc_gss_buf: decode success (0xa04b068:114)
> Oct 26 12:23:02 servicesext rpc.gssd[591]: xdr_rpc_gss_init_res decode success (ctx 0xa04c428:4, maj 0, min 0, win 128, token 0xa04b068:114)
> Oct 26 12:23:02 servicesext rpc.gssd[591]: authgss_create_default: freeing name 0xa04b370
> Oct 26 12:23:02 servicesext rpc.gssd[591]: in authgss_get_private_data()
> Oct 26 12:23:02 servicesext rpc.gssd[591]: DEBUG: serialize_krb5_ctx: lucid version!
> Oct 26 12:23:02 servicesext rpc.gssd[591]: prepare_krb5_rfc1964_buffer: serializing keys with enctype 4 and length 8
> Oct 26 12:23:02 servicesext rpc.gssd[591]: doing downcall
> Oct 26 12:23:02 servicesext rpc.gssd[591]: in authgss_free_private_data()
> Oct 26 12:23:02 servicesext rpc.gssd[591]: in authgss_destroy()
> Oct 26 12:23:02 servicesext rpc.gssd[591]: in authgss_destroy_context()
> Oct 26 12:23:02 servicesext rpc.gssd[591]: authgss_destroy: freeing name 0xa047b90
> Oct 26 12:23:02 servicesext rpc.idmapd[587]: nfs4_name_to_uid: calling nsswitch->name_to_uid
> Oct 26 12:23:02 servicesext rpc.idmapd[587]: nss_getpwnam: name 'root@desmier.org' domain 'desmier.org': resulting localname 'root'
> Oct 26 12:23:02 servicesext rpc.idmapd[587]: nfs4_name_to_uid: nsswitch->name_to_uid returned 0
> Oct 26 12:23:02 servicesext rpc.idmapd[587]: nfs4_name_to_uid: final return value is 0
> Oct 26 12:23:02 servicesext rpc.idmapd[587]: Client 2: (user) name "root@desmier.org" -> id "0"
> Oct 26 12:23:02 servicesext rpc.idmapd[587]: nfs4_name_to_gid: calling nsswitch->name_to_gid
> Oct 26 12:23:02 servicesext rpc.idmapd[587]: nfs4_name_to_gid: nsswitch->name_to_gid returned 0
> Oct 26 12:23:02 servicesext rpc.idmapd[587]: nfs4_name_to_gid: final return value is 0
> Oct 26 12:23:02 servicesext rpc.idmapd[587]: Client 2: (group) name "root@desmier.org" -> id "0"
> Oct 26 12:23:02 servicesext rpc.idmapd[587]: New client: 4
> Oct 26 12:23:02 servicesext rpc.gssd[591]: destroying client /var/lib/nfs/rpc_pipefs/nfs/clnt3
> Oct 26 12:23:02 servicesext rpc.idmapd[587]: Stale client: 3
> Oct 26 12:23:02 servicesext rpc.idmapd[587]: #011-> closed /var/lib/nfs/rpc_pipefs/nfs/clnt3/idmap
> 
> 
> 
>  - Nashome syslog : 
> Oct 26 12:23:00 nashome rpc.svcgssd[2876]: leaving poll
> Oct 26 12:23:00 nashome rpc.svcgssd[2876]: handling null request
> Oct 26 12:23:00 nashome rpc.svcgssd[2876]: sname = nfs/servicesext.desmier.org@DESMIER.ORG
> Oct 26 12:23:00 nashome rpc.svcgssd[2876]: libnfsidmap: using domain: desmier.org
> Oct 26 12:23:00 nashome rpc.svcgssd[2876]: libnfsidmap: processing 'Method' list
> Oct 26 12:23:00 nashome rpc.svcgssd[2876]: libnfsidmap: loaded plugin /usr/lib/libnfsidmap/nsswitch.so for method nsswitch
> Oct 26 12:23:00 nashome rpc.svcgssd[2876]: DEBUG: serialize_krb5_ctx: lucid version!
> Oct 26 12:23:00 nashome rpc.svcgssd[2876]: prepare_krb5_rfc1964_buffer: serializing keys with enctype 4 and length 8
> Oct 26 12:23:00 nashome rpc.svcgssd[2876]: doing downcall
> Oct 26 12:23:00 nashome rpc.svcgssd[2876]: mech: krb5, hndl len: 4, ctx len 85, timeout: 1288123449 (34869 from now), clnt: nfs@servicesext.desmier.org, uid: -1, gid: -1, num aux grps: 0:
> Oct 26 12:23:00 nashome rpc.svcgssd[2876]: sending null reply
> Oct 26 12:23:00 nashome rpc.svcgssd[2876]: writing message: \x \x6082024606092a864886f71201020201006e82023530820231a003020105a10302010ea20703050020000000a38201596182015530820151a003020105a10d1b0b4445534d4945522e4f5247a2253023a003020103a11c301a1b036e66731b136e6173686f6d652e6465736d6965722e6f7267a38201123082010ea003020112a103020107a28201000481fdd265dab6ac3f0baf6338d64153d32b4873c93c166b66eff6cb7b48e85f13a24d21fc7d0fb94e76cc14df4d4d2291588b7759fb497d2c23c622f9dd1da834a97c0a2027e075444a846f63747d375b6db9ad5aae106e639703653bec4e7a8e06f6dcbd1d3c03305fb3b01d84024697e2cfa34277d15ec1b96c164d344ca00444335ccefdcdf275ab6cb6767adf1d2706b9f0ce32d6bde3e9729e807dd4471531b1f96a31dda0be6938782724b7e72983c7ae796abeac1ddec8fab06e486bbab2c5c5fe789b93fa3eabc994142920ba4b725c2266bd615c08f4d603748fb568ff7f921105a379425fcff276db52560e53198faf29ba55345951d89b322318a481be3081bba003020101a281b30481b0e668f43c88a2cfa3307744065a47b7700539eb9e9d10599ec1a2256f299d4aea4a8ebcf2d48d42bcd3a5625e3b5d567d14b22b!
 5cb
>  f8a39c1e222ac02681248525b0053ea2ea29f1fb43d9d1c7cac3c6597569b402b0c902450fba2395b29dd99d036fe8c4d124fbcc955e465af1f9c65ba111e6c5116e2806e12b06a8ba507ec84c18a2f8a3622da83a100f91021338cfd2e4f7534f91884af1995d76363d2527e020b88527015ac8a8667324895778d 1288088640 0 0 \x01000000 \x607006092a864886f71201020202006f61305fa003020105a10302010fa2533051a003020101a24a04481c649c866a6c25d3dd3cd5624ccdf9dd26b53134870418ef7137c6da82a5d4da90573edec195a852395593fd4fda7179cb0e40d3481544807d982e25aadc80b3e42e25734dcefeb8 
> Oct 26 12:23:00 nashome rpc.svcgssd[2876]: finished handling null request
> Oct 26 12:23:00 nashome rpc.svcgssd[2876]: entering poll
> Oct 26 12:23:00 nashome rpc.idmapd[2821]: nfsdcb: authbuf=gss/krb5 authtype=user
> Oct 26 12:23:00 nashome rpc.idmapd[2821]:  Server: (user) id "0" -> name "root@desmier.org"
> Oct 26 12:23:00 nashome rpc.idmapd[2821]: nfsdcb: authbuf=gss/krb5 authtype=group
> Oct 26 12:23:00 nashome rpc.idmapd[2821]:  Server: (group) id "0" -> name "root@desmier.org"
> 
>  - servicesint Kerberos KDC logs :
> nothing new, credentials are in cache.
> 
> 
> Did someone already encountered that kind of problem? I've tried a lot tutorials in internet but each time when I use a security flavor like sys with an other share with gss/krb5, mount command never ends when mounting gss/krb5 share. Following /etc/exports doesn't work unless I remove the first line. Once the first line removed, I can mount using krb5[i][p] security flavor.
> /export  *(rw,fsid=0,insecure,no_subtree_check)
> /export  gss/krb5(rw,fsid=0,insecure,no_subtree_check)
> /export  gss/krb5i(rw,fsid=0,insecure,no_subtree_check)
> /export  gss/krb5p(rw,fsid=0,insecure,no_subtree_check)
> 
> 
> Thanks for any help, advices, best practices, tips...
> 
> Arnaud
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
