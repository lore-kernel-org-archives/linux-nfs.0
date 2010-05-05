Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail2-relais-roc.national.inria.fr ([192.134.164.83]:63038 "EHLO
	mail2-relais-roc.national.inria.fr" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758557Ab0EEV1z (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 5 May 2010 17:27:55 -0400
Message-ID: <4BE1E099.9050902@inria.fr>
Date: Wed, 05 May 2010 23:18:17 +0200
From: Guillaume Rousse <Guillaume.Rousse@inria.fr>
To: linux-nfs@vger.kernel.org
Subject: Re: trouble using kerberos between linux client and server
References: <4BCFE979.2000406@inria.fr>
In-Reply-To: <4BCFE979.2000406@inria.fr>
Content-Type: multipart/mixed;
 boundary="------------010901050703090802050103"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

--------------010901050703090802050103
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 8bit

Le 22/04/2010 08:15, Guillaume Rousse a écrit :
> Hello list.
> 
> I've been using kerberized NFS with NetApp filer without
> kerberos-specific troubles so far. However, I'm currently trying to
> setup a Linux kerberized server for the first time, and I'm facing
> Kerberos issues.
I managed to get rid of the two initial errors (failure to select the
correct key if more than one key was present in the keytab, and failure
to reply to pre-authentication request) by generating principals with
DES keys right from the start, instead of adding a DES key to an
already-existing principal later. There isn't any error in kerberos logs
anymore. However, mount still doesn't succeed, for unknown failure in
rpc.svcgssd (apparently):

May  3 22:07:07 loubianka rpc.svcgssd[5729]: leaving poll
May  3 22:07:07 loubianka rpc.svcgssd[5729]: handling null request
May  3 22:07:07 loubianka rpc.svcgssd[5729]: sname =
nfs/beria.zarb.home@ZARB.HOME
May  3 22:07:07 loubianka rpc.svcgssd[5729]: nfs4_gss_princ_to_ids:
calling nsswitch->princ_to_ids
May  3 22:07:07 loubianka rpc.svcgssd[5729]: nss_getpwnam: name
'nfs/beria.zarb.home@ZARB.HOME' domain '(null)': resulting localname
'nfs/beria.zarb.home'
May  3 22:07:07 loubianka rpc.svcgssd[5729]: nfs4_gss_princ_to_ids:
nsswitch->princ_to_ids returned -2
May  3 22:07:07 loubianka rpc.svcgssd[5729]: nfs4_gss_princ_to_ids:
final return value is -2
May  3 22:07:07 loubianka rpc.svcgssd[5729]: DEBUG: serialize_krb5_ctx:
lucid version!
May  3 22:07:07 loubianka rpc.svcgssd[5729]:
prepare_krb5_rfc1964_buffer: serializing keys with enctype 4 and length 8
May  3 22:07:07 loubianka rpc.svcgssd[5729]: doing downcall
May  3 22:07:07 loubianka rpc.svcgssd[5729]: mech: krb5, hndl len: 4,
ctx len 85, timeout: 1273002810 (85583 from now), clnt:
nfs@beria.zarb.home, uid: -1, gid: -1, num aux grps: 0:
May  3 22:07:07 loubianka rpc.svcgssd[5729]: qword_eol: fflush failed:
errno 95 (Operation not supported)
May  3 22:07:07 loubianka rpc.svcgssd[5729]: WARNING: error writing to
downcall channel /proc/net/rpc/auth.rpcsec.context/channel: Operation
not supported
May  3 22:07:07 loubianka rpc.svcgssd[5729]: sending null reply
May  3 22:07:07 loubianka rpc.svcgssd[5729]: writing message: \x
\x6082023606092a864886f71201020201006e82022530820221a003020105a10302010ea20703050020000000a38201516182014d30820149a003020105a10b1b095a4152422e484f4d45a2253023a003020103a11c301a1b036e66731b136c6f756269616e6b612e7a6172622e686f6d65a382010c30820108a003020101a103020102a281fb0481f87e4272c666342bb6b0b15e9cd002e38a80a61c6ff22f4c36906f55ed954826c7f5cf47f014d6994a4bbbb26c94b235bd2652e6887ee77b4efc90d1ff704e905ac0b25fc411f0f86208c533ed2c8d8c080dc04cd6498a50a23e15ba5035135cdb7517e89abda282bb258987aeb62c9555e406cf8c0461faf3eaf1d4b2cb9f62c9ea3bd67522294ecfc204247b46b96aa744dbc374bc5e371589a89bdfaee12a7865f97c1693cd42e581ce457df7400412580d2d3418e7c67f193adf19d8f9a2ee4101743ad50760d8cc36e778b936a7e2c11b11320a06b6399c8ab358853a4ad6e35ecca2f5974b224ec1c9c97262312043cdc8f938125492a481b63081b3a003020101a281ab0481a83ed20fcc8c164138b903cd084a73d8cb5443b925bb1574a976ea02cb5cc428b4045e246f9d4127c3bd85e23e319b9b538ae428951b05f02fd2fc550cb4189e8aeb6b9b8565393a6553f5d54b6ca2dbe6c1b8167e84d3612334969c9e

7adda30b4b9b0b516dfb95cc681c336ed961c67eb9ff5979d1cbe8b25346ee3b9b831e4dfb2886c3532cf265d38d5f0f425b1de71e715cb5577496e2fa57347ba24e8328fe60181cede1a8db
1272917287 0 0 \x08000000
\x607006092a864886f71201020202006f61305fa003020105a10302010fa2533051a003020101a24a0448dbfcd096f64638016b06d173c349533a18516fae606f6e49952bb4bcb47d4b90cdf2fe787d2522e3c52271f249e9c29a2566ddfffa27d562ba3e98c10f9ac30ca79127a244810e91
May  3 22:07:07 loubianka rpc.svcgssd[5729]: finished handling null request
May  3 22:07:07 loubianka rpc.svcgssd[5729]: entering poll

The same output appears twice for each attempt. Googling for 'qword_eol'
refers to changes in nfs-utils last year adding more logs message in
case of failure, and a strong feeling the issue occurs in server kernel
(2.6.33.2).

Here are clients logs:
May  3 22:07:14 beria rpc.gssd[17990]: handle_gssd_upcall: 'mech=krb5
uid=0 '
May  3 22:07:14 beria rpc.gssd[17990]: handling krb5 upcall
(/var/lib/nfs/rpc_pipefs/nfs/clnt6)
May  3 22:07:14 beria rpc.gssd[17990]: process_krb5_upcall: service is
'<null>'
May  3 22:07:14 beria rpc.gssd[17990]: Full hostname for
'loubianka.zarb.home' is 'loubianka.zarb.home'
May  3 22:07:14 beria rpc.gssd[17990]: Full hostname for
'beria.zarb.home' is 'beria.zarb.home'
May  3 22:07:14 beria rpc.gssd[17990]: Key table entry not found while
getting keytab entry for 'root/beria.zarb.home@ZARB.HOME'
May  3 22:07:14 beria rpc.gssd[17990]: Success getting keytab entry for
'nfs/beria.zarb.home@ZARB.HOME'
May  3 22:07:14 beria rpc.gssd[17990]: INFO: Credentials in CC
'FILE:/tmp/krb5cc_machine_ZARB.HOME' are good until 1273002810
May  3 22:07:14 beria rpc.gssd[17990]: INFO: Credentials in CC
'FILE:/tmp/krb5cc_machine_ZARB.HOME' are good until 1273002810
May  3 22:07:14 beria rpc.gssd[17990]: using
FILE:/tmp/krb5cc_machine_ZARB.HOME as credentials cache for machine creds
May  3 22:07:14 beria rpc.gssd[17990]: using environment variable to
select krb5 ccache FILE:/tmp/krb5cc_machine_ZARB.HOME
May  3 22:07:14 beria rpc.gssd[17990]: creating context using fsuid 0
(save_uid 0)
May  3 22:07:14 beria rpc.gssd[17990]: creating tcp client for server
loubianka.zarb.home
May  3 22:07:14 beria rpc.gssd[17990]: DEBUG: port already set to 2049
May  3 22:07:14 beria rpc.gssd[17990]: creating context with server
nfs@loubianka.zarb.home
May  3 22:07:14 beria rpc.gssd[17990]: WARNING: Failed to create krb5
context for user with uid 0 for server loubianka.zarb.home
May  3 22:07:14 beria rpc.gssd[17990]: WARNING: Failed to create machine
krb5 context with credentials cache FILE:/tmp/krb5cc_machine_ZARB.HOME
for server loubianka.zarb.home
May  3 22:07:14 beria rpc.gssd[17990]: WARNING: Machine cache is
prematurely expired or corrupted trying to recreate cache for server
loubianka.zarb.home
May  3 22:07:14 beria rpc.gssd[17990]: Full hostname for
'loubianka.zarb.home' is 'loubianka.zarb.home'
May  3 22:07:14 beria rpc.gssd[17990]: Full hostname for
'beria.zarb.home' is 'beria.zarb.home'
May  3 22:07:14 beria rpc.gssd[17990]: Key table entry not found while
getting keytab entry for 'root/beria.zarb.home@ZARB.HOME'
May  3 22:07:14 beria rpc.gssd[17990]: Success getting keytab entry for
'nfs/beria.zarb.home@ZARB.HOME'
May  3 22:07:14 beria rpc.gssd[17990]: INFO: Credentials in CC
'FILE:/tmp/krb5cc_machine_ZARB.HOME' are good until 1273002810
May  3 22:07:14 beria rpc.gssd[17990]: INFO: Credentials in CC
'FILE:/tmp/krb5cc_machine_ZARB.HOME' are good until 1273002810
May  3 22:07:14 beria rpc.gssd[17990]: using
FILE:/tmp/krb5cc_machine_ZARB.HOME as credentials cache for machine creds
May  3 22:07:14 beria rpc.gssd[17990]: using environment variable to
select krb5 ccache FILE:/tmp/krb5cc_machine_ZARB.HOME
May  3 22:07:14 beria rpc.gssd[17990]: creating context using fsuid 0
(save_uid 0)
May  3 22:07:14 beria rpc.gssd[17990]: creating tcp client for server
loubianka.zarb.home
May  3 22:07:14 beria rpc.gssd[17990]: DEBUG: port already set to 2049
May  3 22:07:14 beria rpc.gssd[17990]: creating context with server
nfs@loubianka.zarb.home
May  3 22:07:14 beria rpc.gssd[17990]: WARNING: Failed to create krb5
context for user with uid 0 for server loubianka.zarb.home
May  3 22:07:14 beria rpc.gssd[17990]: WARNING: Failed to create machine
krb5 context with credentials cache FILE:/tmp/krb5cc_machine_ZARB.HOME
for server loubianka.zarb.home
May  3 22:07:14 beria rpc.gssd[17990]: WARNING: Failed to create machine
krb5 context with any credentials cache for server loubianka.zarb.home
May  3 22:07:14 beria rpc.gssd[17990]: doing error downcall
May  3 22:07:14 beria rpc.gssd[17990]: destroying client
/var/lib/nfs/rpc_pipefs/nfs/clnt7
May  3 22:07:14 beria rpc.gssd[17990]: destroying client
/var/lib/nfs/rpc_pipefs/nfs/clnt6

I'm attaching network capture, even I can't figure additional
information from it by myself.
-- 
BOFH excuse #412:

Radial Telemetry Infiltration


--------------010901050703090802050103
Content-Type: application/octet-stream;
 name="out"
Content-Transfer-Encoding: base64
Content-Disposition: attachment;
 filename="out"

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
X5Q=

--------------010901050703090802050103--
