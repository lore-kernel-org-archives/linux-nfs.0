From: arnaud.desmier@free.fr
Subject: Re: Problems using sec=krb5 with also sec=sys in any share
Date: Thu, 28 Oct 2010 13:49:34 +0200 (CEST)
Message-ID: <1768058289.815041288266574453.JavaMail.root@spooler8-g27.priv.proxad.net>
References: <1215084548.814871288266525238.JavaMail.root@spooler8-g27.priv.proxad.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp2-g21.free.fr ([212.27.42.2]:37774 "EHLO smtp2-g21.free.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752730Ab0J1Ltm convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 28 Oct 2010 07:49:42 -0400
Received: from spooler8-g27.priv.proxad.net (unknown [172.20.243.233])
	by smtp2-g21.free.fr (Postfix) with ESMTP id C147F4B00CE
	for <linux-nfs@vger.kernel.org>; Thu, 28 Oct 2010 13:49:35 +0200 (CEST)
In-Reply-To: <1215084548.814871288266525238.JavaMail.root-x5ewXQG5twBsFmKuirFwRhh1pbbyJDp15NbjCUgZEJk@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

No idea about this problem? no one encountered the same problem?

Maybe there is an other mailing list for this kind of problem?

Thanks,

Arnaud

----- Mail Original -----
De: "arnaud desmier" <arnaud.desmier@free.fr>
=C3=80: linux-nfs@vger.kernel.org
Envoy=C3=A9: Mardi 26 Octobre 2010 14h08:10 GMT +01:00 Amsterdam / Berl=
in / Berne / Rome / Stockholm / Vienne
Objet: Problems using sec=3Dkrb5 with also sec=3Dsys in any share

Hi all,

I'm trying to share some folders like /home and /var/mail with differen=
ts security flavors between some machines in a virtual network using Vi=
rtualBox. My virtual network is compunded of :
 - my NFS server, also called nashome, IP address : 192.168.10.5. It's =
a Debian Squeeze Virtual Machine, using nfs-utils 1.2.2
 - my email server, also called servicesext (external services), IP add=
ress : 10.1.2.10. It's a Debian Squeeze Virtual Machine, using nfs-util=
s 1.2.2
 - my kerberos (MIT) server, also called serviceint (internal services)=
, IP address : 192.168.10.4. It's a Debian Squeeze Virtual Machine
 - my user computer, also called posteA, IP address : 192.168.10.50. It=
's an Ubuntu 10.10

NFS shared folders constraints are following :
 - /home must be accessed using kerberos identification, I have to moun=
t it on servicesext and posteA
 - /var/mail is filled by exim4 so I can't use kerberos authentication,=
 only sys flavor, I have to mount it on servicesext only

/export/home and /export/mail are bind mount :=20
mount --bind /var/mail/ /export/mail/
mount --bind /home /export/home/

All Squeeze machines have been updated at the same time and tests have =
reproduced using nfs-utils 1.2.2 with and without debian patches, and a=
lso with nfs-utils 1.2.3. Each time the same result.

1. Each time, when a share folder is set with sec=3Dkrb5 as security fl=
avor, client is blocked and mount command never ends. For example (/etc=
/exports) :=20
/export        -fsid=3D0,insecure,no_subtree_check 10.1.2.10(sec=3Dsys:=
krb5) 192.168.10.50(sec=3Dkrb5)
/export/home   -sec=3Dkrb5,rw,nohide,insecure,no_subtree_check 192.168.=
10.50 10.1.2.10
/export/mail   -sec=3Dsys,rw,nohide,insecure,no_subtree_check 10.1.2.10

 - Using my servicesext (10.1.2.10) machine, I can mount nashome:/mail =
:
   # umount /mnt/nfs4; mount -t nfs4 nashome:/mail /mnt/nfs4 -vvvv
 - but when I try to mount nashome:/home, mount command never ends (see=
 logs below)
   # umount /mnt/nfs4; mount -t nfs4 -o sec=3Dkrb5 nashome:/home /mnt/n=
fs4 -vvvv


2. Instead of using sec=3Dkrb5, I will use old expression gss/krb5 : th=
e following does not work
/export        -fsid=3D0,insecure,no_subtree_check 10.1.2.10(sec=3Dsys:=
krb5) 192.168.10.50(sec=3Dkrb5) gss/krb5
/export/home   -sec=3Dkrb5,rw,nohide,insecure,no_subtree_check 192.168.=
10.50 10.1.2.10 gss/krb5
/export/mail   -sec=3Dsys,rw,nohide,insecure,no_subtree_check 10.1.2.10


3. And an amazing thing, if I remove all authentications except gss/krb=
5 I can mount nashome:/home (see logs below). Mounting on posteA works =
only if I remove it's IP address 192.168.10.50 from second line.
/export        -fsid=3D0,insecure,no_subtree_check gss/krb5
/export/home   -rw,nohide,insecure,no_subtree_check 192.168.10.50 gss/k=
rb5
#/export/mail   -sec=3Dsys,rw,nohide,insecure,no_subtree_check 10.1.2.1=
0


=46ollowing are logs files for mount and syslog on servicesext, nashome=
 syslog, and servicesint Kerberos KDC logs for step 1 when mounting nas=
home:/home

 - mount logs :=20
mount: fstab path: "/etc/fstab"
mount: mtab path:  "/etc/mtab"
mount: lock path:  "/etc/mtab~"
mount: temp path:  "/etc/mtab.tmp"
mount: UID:        0
mount: eUID:       0
mount: spec:  "nashome:/home"
mount: node:  "/mnt/nfs4"
mount: types: "nfs4"
mount: opts:  "sec=3Dkrb5"
mount: external mount: argv[0] =3D "/sbin/mount.nfs4"
mount: external mount: argv[1] =3D "nashome:/home"
mount: external mount: argv[2] =3D "/mnt/nfs4"
mount: external mount: argv[3] =3D "-v"
mount: external mount: argv[4] =3D "-o"
mount: external mount: argv[5] =3D "rw,sec=3Dkrb5"
mount.nfs4: timeout set for Tue Oct 26 12:06:40 2010
mount.nfs4: trying text-based options 'sec=3Dkrb5,addr=3D192.168.10.5,c=
lientaddr=3D10.1.2.10'


 - Servicesext syslog :
Oct 26 12:04:40 servicesext rpc.idmapd[587]: New client: 0
Oct 26 12:04:40 servicesext rpc.idmapd[587]: Opened /var/lib/nfs/rpc_pi=
pefs/nfs/clnt0/idmap
Oct 26 12:04:40 servicesext rpc.idmapd[587]: New client: 1
Oct 26 12:04:40 servicesext rpc.gssd[591]: handling gssd upcall (/var/l=
ib/nfs/rpc_pipefs/nfs/clnt0)
Oct 26 12:04:40 servicesext rpc.gssd[591]: handle_gssd_upcall: 'mech=3D=
krb5 uid=3D0 '
Oct 26 12:04:40 servicesext rpc.gssd[591]: handling krb5 upcall (/var/l=
ib/nfs/rpc_pipefs/nfs/clnt0)
Oct 26 12:04:40 servicesext rpc.gssd[591]: process_krb5_upcall: service=
 is '<null>'
Oct 26 12:04:40 servicesext rpc.gssd[591]: Full hostname for 'nashome.d=
esmier.org' is 'nashome.desmier.org'
Oct 26 12:04:40 servicesext rpc.gssd[591]: Full hostname for 'servicese=
xt.desmier.org' is 'servicesext.desmier.org'
Oct 26 12:04:40 servicesext rpc.gssd[591]: Key table entry not found wh=
ile getting keytab entry for 'root/servicesext.desmier.org-HBhUyB7S6INF7rqys1CUDA@public.gmane.org'
Oct 26 12:04:40 servicesext rpc.gssd[591]: Success getting keytab entry=
 for 'nfs/servicesext.desmier.org-HBhUyB7S6INF7rqys1CUDA@public.gmane.org'
Oct 26 12:04:40 servicesext rpc.gssd[591]: Successfully obtained machin=
e credentials for principal 'nfs/servicesext.desmier.org-HBhUyB7S6INF7rqys1CUDA@public.gmane.org' s=
tored in ccache 'FILE:/tmp/krb5cc_machine_DESMIER.ORG'
Oct 26 12:04:40 servicesext rpc.gssd[591]: INFO: Credentials in CC 'FIL=
E:/tmp/krb5cc_machine_DESMIER.ORG' are good until 1288123449
Oct 26 12:04:40 servicesext rpc.gssd[591]: using FILE:/tmp/krb5cc_machi=
ne_DESMIER.ORG as credentials cache for machine creds
Oct 26 12:04:40 servicesext rpc.gssd[591]: using environment variable t=
o select krb5 ccache FILE:/tmp/krb5cc_machine_DESMIER.ORG
Oct 26 12:04:40 servicesext rpc.gssd[591]: creating context using fsuid=
 0 (save_uid 0)
Oct 26 12:04:40 servicesext rpc.gssd[591]: creating tcp client for serv=
er nashome.desmier.org
Oct 26 12:04:40 servicesext rpc.gssd[591]: DEBUG: port already set to 2=
049
Oct 26 12:04:40 servicesext rpc.gssd[591]: creating context with server=
 nfs-51RxAZSjM3jWMF6bZ8oobUB+6BGkLq7r@public.gmane.org
Oct 26 12:04:40 servicesext rpc.gssd[591]: in authgss_create_default()
Oct 26 12:04:40 servicesext rpc.gssd[591]: in authgss_create()
Oct 26 12:04:40 servicesext rpc.gssd[591]: authgss_create: name is 0xa0=
47908
Oct 26 12:04:40 servicesext rpc.gssd[591]: authgss_create: gd->name is =
0xa047e38
Oct 26 12:04:40 servicesext rpc.gssd[591]: in authgss_refresh()
Oct 26 12:04:40 servicesext rpc.gssd[591]: struct rpc_gss_sec:
Oct 26 12:04:40 servicesext rpc.gssd[591]:      mechanism_OID: { 1 2 13=
4 72 134 247 18 1 2 2 }
Oct 26 12:04:40 servicesext rpc.gssd[591]:      qop: 0
Oct 26 12:04:40 servicesext rpc.gssd[591]:      service: 1
Oct 26 12:04:40 servicesext rpc.gssd[591]:      cred: 0xa047c10
Oct 26 12:04:40 servicesext rpc.gssd[591]:      req_flags: 00000002
Oct 26 12:04:40 servicesext rpc.gssd[591]: in authgss_marshal()
Oct 26 12:04:40 servicesext rpc.gssd[591]: xdr_rpc_gss_buf: encode succ=
ess ((nil):0)
Oct 26 12:04:40 servicesext rpc.gssd[591]: xdr_rpc_gss_cred: encode suc=
cess (v 1, proc 1, seq 0, svc 1, ctx (nil):0)
Oct 26 12:04:40 servicesext rpc.gssd[591]: xdr_rpc_gss_buf: encode succ=
ess (0xa04b410:586)
Oct 26 12:04:40 servicesext rpc.gssd[591]: xdr_rpc_gss_init_args: encod=
e success (token 0xa04b410:586)
Oct 26 12:04:40 servicesext rpc.gssd[591]: in authgss_validate()
Oct 26 12:04:40 servicesext rpc.gssd[591]: xdr_rpc_gss_buf: decode succ=
ess (0xa047440:4)
Oct 26 12:04:40 servicesext rpc.gssd[591]: xdr_rpc_gss_buf: decode succ=
ess (0xa04b660:114)
Oct 26 12:04:40 servicesext rpc.gssd[591]: xdr_rpc_gss_init_res decode =
success (ctx 0xa047440:4, maj 0, min 0, win 128, token 0xa04b660:114)
Oct 26 12:04:40 servicesext rpc.gssd[591]: authgss_create_default: free=
ing name 0xa047908
Oct 26 12:04:40 servicesext rpc.gssd[591]: in authgss_get_private_data(=
)
Oct 26 12:04:40 servicesext rpc.gssd[591]: DEBUG: serialize_krb5_ctx: l=
ucid version!
Oct 26 12:04:40 servicesext rpc.gssd[591]: prepare_krb5_rfc1964_buffer:=
 serializing keys with enctype 4 and length 8
Oct 26 12:04:40 servicesext rpc.gssd[591]: doing downcall
Oct 26 12:04:40 servicesext rpc.gssd[591]: in authgss_free_private_data=
()
Oct 26 12:04:40 servicesext rpc.gssd[591]: in authgss_destroy()
Oct 26 12:04:40 servicesext rpc.gssd[591]: in authgss_destroy_context()
Oct 26 12:04:40 servicesext rpc.gssd[591]: authgss_destroy: freeing nam=
e 0xa047e38
Oct 26 12:07:40 servicesext kernel: [  231.993067] nfs: server nashome =
not responding, still trying

 - When I kill mount with Ctrl+C :=20
Oct 26 12:22:13 servicesext rpc.idmapd[587]: Stale client: 1
Oct 26 12:22:13 servicesext rpc.idmapd[587]: #011-> closed /var/lib/nfs=
/rpc_pipefs/nfs/clnt1/idmap
Oct 26 12:22:13 servicesext rpc.idmapd[587]: Stale client: 0
Oct 26 12:22:13 servicesext rpc.idmapd[587]: #011-> closed /var/lib/nfs=
/rpc_pipefs/nfs/clnt0/idmap
Oct 26 12:22:13 servicesext rpc.gssd[591]: destroying client /var/lib/n=
fs/rpc_pipefs/nfs/clnt1
Oct 26 12:22:13 servicesext rpc.gssd[591]: destroying client /var/lib/n=
fs/rpc_pipefs/nfs/clnt0


 - Nashome syslog :=20
Oct 26 12:04:09 nashome rpc.svcgssd[2775]: leaving poll
Oct 26 12:04:09 nashome rpc.svcgssd[2775]: handling null request
Oct 26 12:04:09 nashome rpc.svcgssd[2775]: sname =3D nfs/servicesext.de=
smier.org-HBhUyB7S6INF7rqys1CUDA@public.gmane.org
Oct 26 12:04:09 nashome rpc.svcgssd[2775]: DEBUG: serialize_krb5_ctx: l=
ucid version!
Oct 26 12:04:09 nashome rpc.svcgssd[2775]: prepare_krb5_rfc1964_buffer:=
 serializing keys with enctype 4 and length 8
Oct 26 12:04:09 nashome rpc.svcgssd[2775]: doing downcall
Oct 26 12:04:09 nashome rpc.svcgssd[2775]: mech: krb5, hndl len: 4, ctx=
 len 85, timeout: 1288123449 (36000 from now), clnt: nfs-fruN6kYK4IH0mRrQNGSQYw@public.gmane.org=
smier.org, uid: -1, gid: -1, num aux grps: 0:
Oct 26 12:04:09 nashome rpc.svcgssd[2775]: sending null reply
Oct 26 12:04:09 nashome rpc.svcgssd[2775]: writing message: \x \x608202=
4606092a864886f71201020201006e82023530820231a003020105a10302010ea207030=
50020000000a38201596182015530820151a003020105a10d1b0b4445534d4945522e4f=
5247a2253023a003020103a11c301a1b036e66731b136e6173686f6d652e6465736d696=
5722e6f7267a38201123082010ea003020112a103020107a28201000481fdd265dab6ac=
3f0baf6338d64153d32b4873c93c166b66eff6cb7b48e85f13a24d21fc7d0fb94e76cc1=
4df4d4d2291588b7759fb497d2c23c622f9dd1da834a97c0a2027e075444a846f63747d=
375b6db9ad5aae106e639703653bec4e7a8e06f6dcbd1d3c03305fb3b01d84024697e2c=
fa34277d15ec1b96c164d344ca00444335ccefdcdf275ab6cb6767adf1d2706b9f0ce32=
d6bde3e9729e807dd4471531b1f96a31dda0be6938782724b7e72983c7ae796abeac1dd=
ec8fab06e486bbab2c5c5fe789b93fa3eabc994142920ba4b725c2266bd615c08f4d603=
748fb568ff7f921105a379425fcff276db52560e53198faf29ba55345951d89b322318a=
481be3081bba003020101a281b30481b0be97d17110d6ca7d64716a301d5b7412560680=
40fa844a607613cb8fc1235774c3a4fbe5669fdc8edcf92af25a6651cdd8cb11b4f
 ccf06affbe76e4d9905d8cfa1c6202990b3471895f37ff1ba5d5caf9d7980c2b0a7fff=
e67e0f9c2b7929d10488034727b013e725abae91fce125d1fae14f0959e714442e459f0=
868db3af26b395386f854fcb450d5889321250a75a0f142dcfb721e244aa2233e269d65=
e9f1f20a1350f691765210c2eb7ddfcab78 1288087509 0 0 \x02000000 \x6070060=
92a864886f71201020202006f61305fa003020105a10302010fa2533051a003020101a2=
4a0448cdd3980ca17e39234e4b5f8d0ed3295cf4716a92830ae3d61fa5716d69d41cf6d=
5d6e676e0a35ef1d02bd1014fb6191846add36ae5b15b2e820f23f4ccaceb4ec63431bb=
0df9dcbe=20
Oct 26 12:04:09 nashome rpc.svcgssd[2775]: finished handling null reque=
st
Oct 26 12:04:09 nashome rpc.svcgssd[2775]: entering poll


 - servicesint Kerberos KDC logs :
Oct 26 12:04:09 servicesint krb5kdc[1000](info): AS_REQ (7 etypes {18 1=
7 16 23 1 3 2}) 10.1.2.10: NEEDED_PREAUTH: nfs/servicesext.desmier.org@=
DESMIER.ORG for krbtgt/DESMIER.ORG-HBhUyB7S6INF7rqys1CUDA@public.gmane.org, Additional pre-authenti=
cation required
Oct 26 12:04:09 servicesint krb5kdc[1000](info): AS_REQ (7 etypes {18 1=
7 16 23 1 3 2}) 10.1.2.10: ISSUE: authtime 1288087449, etypes {rep=3D18=
 tkt=3D18 ses=3D18}, nfs/servicesext.desmier.org-HBhUyB7S6INF7rqys1CUDA@public.gmane.org for krbtgt=
/DESMIER.ORG-HBhUyB7S6INF7rqys1CUDA@public.gmane.org
Oct 26 12:04:09 servicesint krb5kdc[1000](info): TGS_REQ (7 etypes {18 =
17 16 23 1 3 2}) 10.1.2.10: ISSUE: authtime 1288087449, etypes {rep=3D1=
8 tkt=3D18 ses=3D18}, nfs/servicesext.desmier.org-HBhUyB7S6INF7rqys1CUDA@public.gmane.org for nfs/n=
ashome.desmier.org-HBhUyB7S6INF7rqys1CUDA@public.gmane.org
Oct 26 12:04:09 servicesint krb5kdc[1000](info): TGS_REQ (3 etypes {1 3=
 2}) 10.1.2.10: ISSUE: authtime 1288087449, etypes {rep=3D18 tkt=3D18 s=
es=3D1}, nfs/servicesext.desmier.org-HBhUyB7S6INF7rqys1CUDA@public.gmane.org for nfs/nashome.desmie=
r.org-HBhUyB7S6INF7rqys1CUDA@public.gmane.org


=46ollowing are logs files for mount and syslog on servicesext, nashome=
 syslog, and servicesint Kerberos KDC logs for step 3 when mounting nas=
home:/home

 - Servicesext mount logs :
mount: fstab path: "/etc/fstab"
mount: mtab path:  "/etc/mtab"
mount: lock path:  "/etc/mtab~"
mount: temp path:  "/etc/mtab.tmp"
mount: UID:        0
mount: eUID:       0
mount: spec:  "nashome:/home"
mount: node:  "/mnt/nfs4"
mount: types: "nfs4"
mount: opts:  "sec=3Dkrb5"
mount: external mount: argv[0] =3D "/sbin/mount.nfs4"
mount: external mount: argv[1] =3D "nashome:/home"
mount: external mount: argv[2] =3D "/mnt/nfs4"
mount: external mount: argv[3] =3D "-v"
mount: external mount: argv[4] =3D "-o"
mount: external mount: argv[5] =3D "rw,sec=3Dkrb5"
mount.nfs4: timeout set for Tue Oct 26 12:25:02 2010
mount.nfs4: trying text-based options 'sec=3Dkrb5,addr=3D192.168.10.5,c=
lientaddr=3D10.1.2.10'
nashome:/home on /mnt/nfs4 type nfs4 (rw,sec=3Dkrb5)

 - Servicesext syslog :
ct 26 12:23:02 servicesext rpc.idmapd[587]: New client: 2
Oct 26 12:23:02 servicesext rpc.idmapd[587]: Opened /var/lib/nfs/rpc_pi=
pefs/nfs/clnt2/idmap
Oct 26 12:23:02 servicesext rpc.gssd[591]: handling gssd upcall (/var/l=
ib/nfs/rpc_pipefs/nfs/clnt2)
Oct 26 12:23:02 servicesext rpc.gssd[591]: handle_gssd_upcall: 'mech=3D=
krb5 uid=3D0 '
Oct 26 12:23:02 servicesext rpc.gssd[591]: handling krb5 upcall (/var/l=
ib/nfs/rpc_pipefs/nfs/clnt2)
Oct 26 12:23:02 servicesext rpc.gssd[591]: process_krb5_upcall: service=
 is '<null>'
Oct 26 12:23:02 servicesext rpc.idmapd[587]: New client: 3
Oct 26 12:23:02 servicesext rpc.gssd[591]: Full hostname for 'nashome.d=
esmier.org' is 'nashome.desmier.org'
Oct 26 12:23:02 servicesext rpc.gssd[591]: Full hostname for 'servicese=
xt.desmier.org' is 'servicesext.desmier.org'
Oct 26 12:23:02 servicesext rpc.gssd[591]: Key table entry not found wh=
ile getting keytab entry for 'root/servicesext.desmier.org-HBhUyB7S6INF7rqys1CUDA@public.gmane.org'
Oct 26 12:23:02 servicesext rpc.gssd[591]: Success getting keytab entry=
 for 'nfs/servicesext.desmier.org-HBhUyB7S6INF7rqys1CUDA@public.gmane.org'
Oct 26 12:23:02 servicesext rpc.gssd[591]: INFO: Credentials in CC 'FIL=
E:/tmp/krb5cc_machine_DESMIER.ORG' are good until 1288123449
Oct 26 12:23:02 servicesext rpc.gssd[591]: INFO: Credentials in CC 'FIL=
E:/tmp/krb5cc_machine_DESMIER.ORG' are good until 1288123449
Oct 26 12:23:02 servicesext rpc.gssd[591]: using FILE:/tmp/krb5cc_machi=
ne_DESMIER.ORG as credentials cache for machine creds
Oct 26 12:23:02 servicesext rpc.gssd[591]: using environment variable t=
o select krb5 ccache FILE:/tmp/krb5cc_machine_DESMIER.ORG
Oct 26 12:23:02 servicesext rpc.gssd[591]: creating context using fsuid=
 0 (save_uid 0)
Oct 26 12:23:02 servicesext rpc.gssd[591]: creating tcp client for serv=
er nashome.desmier.org
Oct 26 12:23:02 servicesext rpc.gssd[591]: DEBUG: port already set to 2=
049
Oct 26 12:23:02 servicesext rpc.gssd[591]: creating context with server=
 nfs-51RxAZSjM3jWMF6bZ8oobUB+6BGkLq7r@public.gmane.org
Oct 26 12:23:02 servicesext rpc.gssd[591]: in authgss_create_default()
Oct 26 12:23:02 servicesext rpc.gssd[591]: in authgss_create()
Oct 26 12:23:02 servicesext rpc.gssd[591]: authgss_create: name is 0xa0=
4b370
Oct 26 12:23:02 servicesext rpc.gssd[591]: authgss_create: gd->name is =
0xa047b90
Oct 26 12:23:02 servicesext rpc.gssd[591]: in authgss_refresh()
Oct 26 12:23:02 servicesext rpc.gssd[591]: struct rpc_gss_sec:
Oct 26 12:23:02 servicesext rpc.gssd[591]:      mechanism_OID: { 1 2 13=
4 72 134 247 18 1 2 2 }
Oct 26 12:23:02 servicesext rpc.gssd[591]:      qop: 0
Oct 26 12:23:02 servicesext rpc.gssd[591]:      service: 1
Oct 26 12:23:02 servicesext rpc.gssd[591]:      cred: 0xa04b390
Oct 26 12:23:02 servicesext rpc.gssd[591]:      req_flags: 00000002
Oct 26 12:23:02 servicesext rpc.gssd[591]: in authgss_marshal()
Oct 26 12:23:02 servicesext rpc.gssd[591]: xdr_rpc_gss_buf: encode succ=
ess ((nil):0)
Oct 26 12:23:02 servicesext rpc.gssd[591]: xdr_rpc_gss_cred: encode suc=
cess (v 1, proc 1, seq 0, svc 1, ctx (nil):0)
Oct 26 12:23:02 servicesext rpc.gssd[591]: xdr_rpc_gss_buf: encode succ=
ess (0xa04a1f0:586)
Oct 26 12:23:02 servicesext rpc.gssd[591]: xdr_rpc_gss_init_args: encod=
e success (token 0xa04a1f0:586)
Oct 26 12:23:02 servicesext rpc.gssd[591]: in authgss_validate()
Oct 26 12:23:02 servicesext rpc.gssd[591]: xdr_rpc_gss_buf: decode succ=
ess (0xa04c428:4)
Oct 26 12:23:02 servicesext rpc.gssd[591]: xdr_rpc_gss_buf: decode succ=
ess (0xa04b068:114)
Oct 26 12:23:02 servicesext rpc.gssd[591]: xdr_rpc_gss_init_res decode =
success (ctx 0xa04c428:4, maj 0, min 0, win 128, token 0xa04b068:114)
Oct 26 12:23:02 servicesext rpc.gssd[591]: authgss_create_default: free=
ing name 0xa04b370
Oct 26 12:23:02 servicesext rpc.gssd[591]: in authgss_get_private_data(=
)
Oct 26 12:23:02 servicesext rpc.gssd[591]: DEBUG: serialize_krb5_ctx: l=
ucid version!
Oct 26 12:23:02 servicesext rpc.gssd[591]: prepare_krb5_rfc1964_buffer:=
 serializing keys with enctype 4 and length 8
Oct 26 12:23:02 servicesext rpc.gssd[591]: doing downcall
Oct 26 12:23:02 servicesext rpc.gssd[591]: in authgss_free_private_data=
()
Oct 26 12:23:02 servicesext rpc.gssd[591]: in authgss_destroy()
Oct 26 12:23:02 servicesext rpc.gssd[591]: in authgss_destroy_context()
Oct 26 12:23:02 servicesext rpc.gssd[591]: authgss_destroy: freeing nam=
e 0xa047b90
Oct 26 12:23:02 servicesext rpc.idmapd[587]: nfs4_name_to_uid: calling =
nsswitch->name_to_uid
Oct 26 12:23:02 servicesext rpc.idmapd[587]: nss_getpwnam: name 'root@d=
esmier.org' domain 'desmier.org': resulting localname 'root'
Oct 26 12:23:02 servicesext rpc.idmapd[587]: nfs4_name_to_uid: nsswitch=
->name_to_uid returned 0
Oct 26 12:23:02 servicesext rpc.idmapd[587]: nfs4_name_to_uid: final re=
turn value is 0
Oct 26 12:23:02 servicesext rpc.idmapd[587]: Client 2: (user) name "roo=
t@desmier.org" -> id "0"
Oct 26 12:23:02 servicesext rpc.idmapd[587]: nfs4_name_to_gid: calling =
nsswitch->name_to_gid
Oct 26 12:23:02 servicesext rpc.idmapd[587]: nfs4_name_to_gid: nsswitch=
->name_to_gid returned 0
Oct 26 12:23:02 servicesext rpc.idmapd[587]: nfs4_name_to_gid: final re=
turn value is 0
Oct 26 12:23:02 servicesext rpc.idmapd[587]: Client 2: (group) name "ro=
ot-1jBem2fKKG1AfugRpC6u6w@public.gmane.org" -> id "0"
Oct 26 12:23:02 servicesext rpc.idmapd[587]: New client: 4
Oct 26 12:23:02 servicesext rpc.gssd[591]: destroying client /var/lib/n=
fs/rpc_pipefs/nfs/clnt3
Oct 26 12:23:02 servicesext rpc.idmapd[587]: Stale client: 3
Oct 26 12:23:02 servicesext rpc.idmapd[587]: #011-> closed /var/lib/nfs=
/rpc_pipefs/nfs/clnt3/idmap



 - Nashome syslog :=20
Oct 26 12:23:00 nashome rpc.svcgssd[2876]: leaving poll
Oct 26 12:23:00 nashome rpc.svcgssd[2876]: handling null request
Oct 26 12:23:00 nashome rpc.svcgssd[2876]: sname =3D nfs/servicesext.de=
smier.org-HBhUyB7S6INF7rqys1CUDA@public.gmane.org
Oct 26 12:23:00 nashome rpc.svcgssd[2876]: libnfsidmap: using domain: d=
esmier.org
Oct 26 12:23:00 nashome rpc.svcgssd[2876]: libnfsidmap: processing 'Met=
hod' list
Oct 26 12:23:00 nashome rpc.svcgssd[2876]: libnfsidmap: loaded plugin /=
usr/lib/libnfsidmap/nsswitch.so for method nsswitch
Oct 26 12:23:00 nashome rpc.svcgssd[2876]: DEBUG: serialize_krb5_ctx: l=
ucid version!
Oct 26 12:23:00 nashome rpc.svcgssd[2876]: prepare_krb5_rfc1964_buffer:=
 serializing keys with enctype 4 and length 8
Oct 26 12:23:00 nashome rpc.svcgssd[2876]: doing downcall
Oct 26 12:23:00 nashome rpc.svcgssd[2876]: mech: krb5, hndl len: 4, ctx=
 len 85, timeout: 1288123449 (34869 from now), clnt: nfs-fruN6kYK4IH0mRrQNGSQYw@public.gmane.org=
smier.org, uid: -1, gid: -1, num aux grps: 0:
Oct 26 12:23:00 nashome rpc.svcgssd[2876]: sending null reply
Oct 26 12:23:00 nashome rpc.svcgssd[2876]: writing message: \x \x608202=
4606092a864886f71201020201006e82023530820231a003020105a10302010ea207030=
50020000000a38201596182015530820151a003020105a10d1b0b4445534d4945522e4f=
5247a2253023a003020103a11c301a1b036e66731b136e6173686f6d652e6465736d696=
5722e6f7267a38201123082010ea003020112a103020107a28201000481fdd265dab6ac=
3f0baf6338d64153d32b4873c93c166b66eff6cb7b48e85f13a24d21fc7d0fb94e76cc1=
4df4d4d2291588b7759fb497d2c23c622f9dd1da834a97c0a2027e075444a846f63747d=
375b6db9ad5aae106e639703653bec4e7a8e06f6dcbd1d3c03305fb3b01d84024697e2c=
fa34277d15ec1b96c164d344ca00444335ccefdcdf275ab6cb6767adf1d2706b9f0ce32=
d6bde3e9729e807dd4471531b1f96a31dda0be6938782724b7e72983c7ae796abeac1dd=
ec8fab06e486bbab2c5c5fe789b93fa3eabc994142920ba4b725c2266bd615c08f4d603=
748fb568ff7f921105a379425fcff276db52560e53198faf29ba55345951d89b322318a=
481be3081bba003020101a281b30481b0e668f43c88a2cfa3307744065a47b7700539eb=
9e9d10599ec1a2256f299d4aea4a8ebcf2d48d42bcd3a5625e3b5d567d14b22b5cb
 f8a39c1e222ac02681248525b0053ea2ea29f1fb43d9d1c7cac3c6597569b402b0c902=
450fba2395b29dd99d036fe8c4d124fbcc955e465af1f9c65ba111e6c5116e2806e12b0=
6a8ba507ec84c18a2f8a3622da83a100f91021338cfd2e4f7534f91884af1995d76363d=
2527e020b88527015ac8a8667324895778d 1288088640 0 0 \x01000000 \x6070060=
92a864886f71201020202006f61305fa003020105a10302010fa2533051a003020101a2=
4a04481c649c866a6c25d3dd3cd5624ccdf9dd26b53134870418ef7137c6da82a5d4da9=
0573edec195a852395593fd4fda7179cb0e40d3481544807d982e25aadc80b3e42e2573=
4dcefeb8=20
Oct 26 12:23:00 nashome rpc.svcgssd[2876]: finished handling null reque=
st
Oct 26 12:23:00 nashome rpc.svcgssd[2876]: entering poll
Oct 26 12:23:00 nashome rpc.idmapd[2821]: nfsdcb: authbuf=3Dgss/krb5 au=
thtype=3Duser
Oct 26 12:23:00 nashome rpc.idmapd[2821]:  Server: (user) id "0" -> nam=
e "root-1jBem2fKKG1AfugRpC6u6w@public.gmane.org"
Oct 26 12:23:00 nashome rpc.idmapd[2821]: nfsdcb: authbuf=3Dgss/krb5 au=
thtype=3Dgroup
Oct 26 12:23:00 nashome rpc.idmapd[2821]:  Server: (group) id "0" -> na=
me "root-1jBem2fKKG1AfugRpC6u6w@public.gmane.org"

 - servicesint Kerberos KDC logs :
nothing new, credentials are in cache.


Did someone already encountered that kind of problem? I've tried a lot =
tutorials in internet but each time when I use a security flavor like s=
ys with an other share with gss/krb5, mount command never ends when mou=
nting gss/krb5 share. Following /etc/exports doesn't work unless I remo=
ve the first line. Once the first line removed, I can mount using krb5[=
i][p] security flavor.
/export  *(rw,fsid=3D0,insecure,no_subtree_check)
/export  gss/krb5(rw,fsid=3D0,insecure,no_subtree_check)
/export  gss/krb5i(rw,fsid=3D0,insecure,no_subtree_check)
/export  gss/krb5p(rw,fsid=3D0,insecure,no_subtree_check)


Thanks for any help, advices, best practices, tips...

Arnaud
--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
