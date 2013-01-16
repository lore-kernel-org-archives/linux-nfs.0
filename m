Return-Path: linux-nfs-owner@vger.kernel.org
Received: from moutng.kundenserver.de ([212.227.17.8]:51052 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754088Ab3APMC6 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 16 Jan 2013 07:02:58 -0500
Received: from localhost (localhost.localdomain [127.0.0.1])
	by hermod.mgr (Postfix) with ESMTP id A65E91DC2E7
	for <linux-nfs@vger.kernel.org>; Wed, 16 Jan 2013 13:02:51 +0100 (CET)
Received: from hermod.mgr ([127.0.0.1])
	by localhost (hermod.mgr [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id FH51eVaABu0d for <linux-nfs@vger.kernel.org>;
	Wed, 16 Jan 2013 13:02:41 +0100 (CET)
Received: from [172.16.1.2] (midgard.mgr [172.16.1.2])
	by hermod.mgr (Postfix) with ESMTP id A15071DC222
	for <linux-nfs@vger.kernel.org>; Wed, 16 Jan 2013 13:02:41 +0100 (CET)
Message-ID: <50F696E1.7000405@lhanke.de>
Date: Wed, 16 Jan 2013 13:02:41 +0100
From: "Dr. Lars Hanke" <lars@lhanke.de>
MIME-Version: 1.0
To: linux-nfs@vger.kernel.org
Subject: Kerberos NFSv4, no supported encryption types
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I try to set-up a NFSv4 test system using Kerberos authentication. I use 
an existing Kerberos/LDAP infrastructure (MIT/OpenLDAP) for user 
authentication. I can log into the test machine using pam_krb5, so the 
basic Kerberos setup should be sane. I can also mount exports using host 
based authentication and NFSv4, so the basic NFS setup should also exist.

This is my /etc/exports:
/srv/nfs            gss/krb5(rw,sync,no_subtree_check,fsid=0)
/srv/nfs/test    gss/krb5(rw,sync,no_subtree_check)

On the same system I try to mount the export as root user:
|#: mount -t nfs4 -o sec=krb5 nfs4.mgr:/test mnt
mount.nfs4: access denied by server while mounting nfs4.mgr:/test|

Throwing a couple of '-v' at rpc.gssd I see the following log:

|Jan 15 22:00:11 nfs4 rpc.gssd[8116]: handling gssd upcall 
(/var/lib/nfs/rpc_pipefs/nfs/clntc)
Jan 15 22:00:11 nfs4 rpc.gssd[8116]: handle_gssd_upcall: 'mech=krb5 uid=0 '
Jan 15 22:00:11 nfs4 rpc.gssd[8116]: handling krb5 upcall 
(/var/lib/nfs/rpc_pipefs/nfs/clntc)
Jan 15 22:00:11 nfs4 rpc.gssd[8116]: process_krb5_upcall: service is 
'<null>'
Jan 15 22:00:11 nfs4 rpc.gssd[8116]: Full hostname for 'nfs4.mgr' is 
'nfs4.mgr'
Jan 15 22:00:11 nfs4 rpc.gssd[8116]: Full hostname for 'nfs4.mgr' is 
'nfs4.mgr'
Jan 15 22:00:11 nfs4 rpc.gssd[8116]: Key table entry not found while 
getting keytab entry for 'root/nfs4.mgr@MGR'
Jan 15 22:00:11 nfs4 rpc.gssd[8116]: Success getting keytab entry for 
'nfs/nfs4.mgr@MGR'
Jan 15 22:00:11 nfs4 rpc.gssd[8116]: INFO: Credentials in CC 
'FILE:/tmp/krb5cc_machine_MGR' are good until 1358369976
Jan 15 22:00:11 nfs4 rpc.gssd[8116]: INFO: Credentials in CC 
'FILE:/tmp/krb5cc_machine_MGR' are good until 1358369976
Jan 15 22:00:11 nfs4 rpc.gssd[8116]: using FILE:/tmp/krb5cc_machine_MGR 
as credentials cache for machine creds
Jan 15 22:00:11 nfs4 rpc.gssd[8116]: using environment variable to 
select krb5 ccache FILE:/tmp/krb5cc_machine_MGR
Jan 15 22:00:11 nfs4 rpc.gssd[8116]: creating context using fsuid 0 
(save_uid 0)
Jan 15 22:00:11 nfs4 rpc.gssd[8116]: creating tcp client for server nfs4.mgr
Jan 15 22:00:11 nfs4 rpc.gssd[8116]: DEBUG: port already set to 2049
Jan 15 22:00:11 nfs4 rpc.gssd[8116]: creating context with server 
nfs@nfs4.mgr
Jan 15 22:00:11 nfs4 rpc.gssd[8116]: in authgss_create_default()
Jan 15 22:00:11 nfs4 rpc.gssd[8116]: in authgss_create()
Jan 15 22:00:11 nfs4 rpc.gssd[8116]: authgss_create: name is 0x1bbee10
Jan 15 22:00:11 nfs4 rpc.gssd[8116]: authgss_create: gd->name is 0x1bb46e0
Jan 15 22:00:11 nfs4 rpc.gssd[8116]: in authgss_refresh()
Jan 15 22:00:11 nfs4 rpc.gssd[8116]: struct rpc_gss_sec:
Jan 15 22:00:11 nfs4 rpc.gssd[8116]:      mechanism_OID: { 1 2 134 72 
134 247 18 1 2 2 }
Jan 15 22:00:11 nfs4 rpc.gssd[8116]:      qop: 0
Jan 15 22:00:11 nfs4 rpc.gssd[8116]:      service: 1
Jan 15 22:00:11 nfs4 rpc.gssd[8116]:      cred: 0x1bb9ae0
Jan 15 22:00:11 nfs4 rpc.gssd[8116]:      req_flags: 00000002
Jan 15 22:00:11 nfs4 rpc.gssd[8116]: rpcsec_gss: gss_init_sec_context: 
(major) Unspecified GSS failure.  Minor code may provide more 
information - (minor) No supported encryption types (config file error?)
Jan 15 22:00:11 nfs4 rpc.gssd[8116]: in authgss_destroy()
Jan 15 22:00:11 nfs4 rpc.gssd[8116]: in authgss_destroy_context()
Jan 15 22:00:11 nfs4 rpc.gssd[8116]: authgss_destroy: freeing name 0x1bb46e0
Jan 15 22:00:11 nfs4 rpc.gssd[8116]: authgss_create_default: freeing 
name 0x1bbee10
Jan 15 22:00:11 nfs4 rpc.gssd[8116]: WARNING: Failed to create krb5 
context for user with uid 0 for server nfs4.mgr
Jan 15 22:00:11 nfs4 rpc.gssd[8116]: WARNING: Failed to create machine 
krb5 context with credentials cache FILE:/tmp/krb5cc_machine_MGR for 
server nfs4.mgr
Jan 15 22:00:11 nfs4 rpc.gssd[8116]: WARNING: Machine cache is 
prematurely expired or corrupted trying to recreate cache for server 
nfs4.mgr

This happens twice for each mount attempt. Apperently it fails to 
initialize a security context due to unsupported encryption types. Here 
I'm lost. Which config file might it refer to? Who defines these 
encryption types?

Thanks for your help,
  - lars.
|
