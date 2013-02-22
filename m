Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:39661 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756894Ab3BVPde (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 22 Feb 2013 10:33:34 -0500
Date: Fri, 22 Feb 2013 10:33:33 -0500
To: Thomas Wunder <thomas.wunder@swt-bamberg.de>
Cc: linux-nfs@vger.kernel.org
Subject: Re: NFSv4 mount fails with 'No such file or directory'
Message-ID: <20130222153333.GC20588@fieldses.org>
References: <201302211335.03123.thomas.wunder@swt-bamberg.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <201302211335.03123.thomas.wunder@swt-bamberg.de>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Feb 21, 2013 at 01:35:02PM +0100, Thomas Wunder wrote:
> Hey,
> I'm trying to mount a NFSv4 Kerberos secured share using linux as well as on OS X and in both cases I get a "No such file or directory" error while the server log messages differ and the share is definitely in the right (specified) place. Here's some config stuff from my server (swtnas2) that you might be interested in:
> 
> # grep -v '^#' /etc/exports 
> /backups                     gss/krb5(rw,async,fsid=0,no_subtree_check,crossmnt,insecure,no_root_squash)

Probably you just need to drop the fsid=0.  It's not needed if you're
server's recent enough, and it messes up the paths.  (With the fsid=0,
you'd need to mount /testusr1, not /backups/testusr1, from an NFSv4
client.)

--b.

> /backups/testusr1            gss/krb5(rw,async,nohide,no_subtree_check,insecure,no_root_squash)
> #
> 
> # grep -v '^#' /etc/idmapd.conf 
> [General]
> Verbosity = 3
> Pipefs-Directory = /var/lib/nfs/rpc_pipefs
> Domain = staff.swt.wiai.uni-bamberg.de
> Local-Realms = SWT.WIAI.UNI-BAMBERG.DE
> [Mapping]
> Nobody-User = nobody
> Nobody-Group = nogroup
> #
> (the idmapd.conf of the linux client looks exactly the same, for the OSX client I can't seem to find an equivalent)
> I also added 'allow_weak_crypto = true' to my /etc/krb5.conf cranked up the log level wherever I could. 
> 
> 
> 
> I.  Trying to mount from the linux client:
> # date; mount -vvv -t nfs4 -o sec=krb5,soft,intr swtnas2:/backups/testusr1 /mnt/nfs2/
> Thu Feb 21 12:23:59 CET 2013
> mount: fstab path: "/etc/fstab"
> mount: mtab path:  "/etc/mtab"
> mount: lock path:  "/etc/mtab~"
> mount: temp path:  "/etc/mtab.tmp"
> mount: UID:        0
> mount: eUID:       0
> mount: spec:  "swtnas2:/backups/testusr1"
> mount: node:  "/mnt/nfs2/"
> mount: types: "nfs4"
> mount: opts:  "sec=krb5,soft,intr"
> mount: external mount: argv[0] = "/sbin/mount.nfs4"
> mount: external mount: argv[1] = "swtnas2:/backups/testusr1"
> mount: external mount: argv[2] = "/mnt/nfs2/"
> mount: external mount: argv[3] = "-v"
> mount: external mount: argv[4] = "-o"
> mount: external mount: argv[5] = "rw,sec=krb5,soft,intr"
> mount.nfs4: timeout set for Thu Feb 21 12:25:59 2013
> mount.nfs4: trying text-based options 'sec=krb5,soft,intr,addr=141.13.106.118,clientaddr=141.13.106.66'
> mount.nfs4: mount(2): No such file or directory
> mount.nfs4: mounting swtnas2:/backups/testusr1 failed, reason given by server:
>   No such file or directory
> #
> 
> These are the client side log-messages of gssd and idmapd:
> ---snip---
> Feb 21 12:23:59 tomsbox2 rpc.gssd[16825]: dir_notify_handler: sig 37 si 0x7fffc21daa70 data 0x7fffc21da940
> Feb 21 12:23:59 tomsbox2 rpc.idmapd[16766]: New client: c5
> Feb 21 12:23:59 tomsbox2 rpc.gssd[16825]: dir_notify_handler: sig 37 si 0x7fffc21daa70 data 0x7fffc21da940
> Feb 21 12:23:59 tomsbox2 rpc.idmapd[16766]: Opened /var/lib/nfs/rpc_pipefs/nfs/clntc5/idmap
> Feb 21 12:23:59 tomsbox2 rpc.gssd[16825]: dir_notify_handler: sig 37 si 0x7fffc21daa70 data 0x7fffc21da940
> Feb 21 12:23:59 tomsbox2 rpc.idmapd[16766]: New client: c6
> Feb 21 12:23:59 tomsbox2 rpc.gssd[16825]: handling gssd upcall (/var/lib/nfs/rpc_pipefs/nfs/clntc5)
> Feb 21 12:23:59 tomsbox2 rpc.gssd[16825]: handle_gssd_upcall: 'mech=krb5 uid=0 enctypes=18,17,16,23,3,1,2 '
> Feb 21 12:23:59 tomsbox2 rpc.gssd[16825]: handling krb5 upcall (/var/lib/nfs/rpc_pipefs/nfs/clntc5)
> Feb 21 12:23:59 tomsbox2 rpc.gssd[16825]: process_krb5_upcall: service is '<null>'
> Feb 21 12:23:59 tomsbox2 rpc.gssd[16825]: Full hostname for 'swtnas2.staff.swt.wiai.uni-bamberg.de' is 'swtnas2.staff.swt.wiai.uni-bamberg.de'
> Feb 21 12:23:59 tomsbox2 rpc.gssd[16825]: Full hostname for 'tomsbox2.staff.swt.wiai.uni-bamberg.de' is 'tomsbox2.staff.swt.wiai.uni-bamberg.de'
> Feb 21 12:23:59 tomsbox2 rpc.gssd[16825]: No key table entry found for TOMSBOX2$@SWT.WIAI.UNI-BAMBERG.DE while getting keytab entry for 'TOMSBOX2$@SWT.WIAI.UNI-BAMBERG.DE'
> Feb 21 12:23:59 tomsbox2 rpc.gssd[16825]: No key table entry found for root/tomsbox2.staff.swt.wiai.uni-bamberg.de@SWT.WIAI.UNI-BAMBERG.DE while getting keytab entry for 'root/tomsbox2.staff.swt.wiai.uni-bamberg.de@SWT.WIAI.UNI-BAMBERG.DE'
> Feb 21 12:23:59 tomsbox2 rpc.gssd[16825]: Success getting keytab entry for 'nfs/tomsbox2.staff.swt.wiai.uni-bamberg.de@SWT.WIAI.UNI-BAMBERG.DE'
> Feb 21 12:23:59 tomsbox2 rpc.gssd[16825]: INFO: Credentials in CC 'FILE:/tmp/krb5cc_machine_SWT.WIAI.UNI-BAMBERG.DE' are good until 1361527573
> Feb 21 12:23:59 tomsbox2 rpc.gssd[16825]: INFO: Credentials in CC 'FILE:/tmp/krb5cc_machine_SWT.WIAI.UNI-BAMBERG.DE' are good until 1361527573
> Feb 21 12:23:59 tomsbox2 rpc.gssd[16825]: using FILE:/tmp/krb5cc_machine_SWT.WIAI.UNI-BAMBERG.DE as credentials cache for machine creds
> Feb 21 12:23:59 tomsbox2 rpc.gssd[16825]: using environment variable to select krb5 ccache FILE:/tmp/krb5cc_machine_SWT.WIAI.UNI-BAMBERG.DE
> Feb 21 12:23:59 tomsbox2 rpc.gssd[16825]: creating context using fsuid 0 (save_uid 0)
> Feb 21 12:23:59 tomsbox2 rpc.gssd[16825]: creating tcp client for server swtnas2.staff.swt.wiai.uni-bamberg.de
> Feb 21 12:23:59 tomsbox2 rpc.gssd[16825]: DEBUG: port already set to 2049
> Feb 21 12:23:59 tomsbox2 rpc.gssd[16825]: creating context with server nfs@swtnas2.staff.swt.wiai.uni-bamberg.de
> Feb 21 12:23:59 tomsbox2 rpc.gssd[16825]: DEBUG: serialize_krb5_ctx: lucid version!
> Feb 21 12:23:59 tomsbox2 rpc.gssd[16825]: prepare_krb5_rfc4121_buffer: protocol 1
> Feb 21 12:23:59 tomsbox2 rpc.gssd[16825]: prepare_krb5_rfc4121_buffer: serializing key with enctype 18 and size 32
> Feb 21 12:23:59 tomsbox2 rpc.gssd[16825]: doing downcall
> Feb 21 12:23:59 tomsbox2 rpc.idmapd[16766]: Client c5: (user) name "root@staff.swt.wiai.uni-bamberg.de" -> id "0"
> Feb 21 12:23:59 tomsbox2 rpc.idmapd[16766]: Client c5: (group) name "root@staff.swt.wiai.uni-bamberg.de" -> id "0"
> Feb 21 12:23:59 tomsbox2 rpc.gssd[16825]: dir_notify_handler: sig 37 si 0x7fffc21daa70 data 0x7fffc21da940
> Feb 21 12:23:59 tomsbox2 rpc.gssd[16825]: dir_notify_handler: sig 37 si 0x7fffc21daa70 data 0x7fffc21da940
> Feb 21 12:23:59 tomsbox2 rpc.idmapd[16766]: Stale client: c6
> Feb 21 12:23:59 tomsbox2 rpc.idmapd[16766]: #011-> closed /var/lib/nfs/rpc_pipefs/nfs/clntc6/idmap
> Feb 21 12:23:59 tomsbox2 rpc.gssd[16825]: destroying client /var/lib/nfs/rpc_pipefs/nfs/clntc6
> Feb 21 12:23:59 tomsbox2 rpc.gssd[16825]: dir_notify_handler: sig 37 si 0x7fffc21daa70 data 0x7fffc21da940
> Feb 21 12:23:59 tomsbox2 rpc.gssd[16825]: dir_notify_handler: sig 37 si 0x7fffc21daa70 data 0x7fffc21da940
> Feb 21 12:23:59 tomsbox2 rpc.gssd[16825]: dir_notify_handler: sig 37 si 0x7fffc21daa70 data 0x7fffc21da940
> Feb 21 12:23:59 tomsbox2 rpc.gssd[16825]: dir_notify_handler: sig 37 si 0x7fffc21daa70 data 0x7fffc21da940
> Feb 21 12:23:59 tomsbox2 rpc.gssd[16825]: dir_notify_handler: sig 37 si 0x7fffc21daa70 data 0x7fffc21da940
> Feb 21 12:23:59 tomsbox2 rpc.idmapd[16766]: Stale client: c5
> Feb 21 12:23:59 tomsbox2 rpc.idmapd[16766]: #011-> closed /var/lib/nfs/rpc_pipefs/nfs/clntc5/idmap
> Feb 21 12:23:59 tomsbox2 rpc.gssd[16825]: destroying client /var/lib/nfs/rpc_pipefs/nfs/clntc5
> ---snap---
> 
> This is what I get in the server's log when I try to mount from the linux client:
> ---snip---
> Feb 21 12:23:59 swtnas2 rpc.svcgssd[27492]: leaving poll
> Feb 21 12:23:59 swtnas2 rpc.svcgssd[27492]: handling null request
> Feb 21 12:23:59 swtnas2 rpc.svcgssd[27492]: svcgssd_limit_krb5_enctypes: Calling gss_set_allowable_enctypes with 7 enctypes from the kernel
> Feb 21 12:23:59 swtnas2 rpc.svcgssd[27492]: sname = nfs/tomsbox2.staff.swt.wiai.uni-bamberg.de@SWT.WIAI.UNI-BAMBERG.DE
> Feb 21 12:23:59 swtnas2 rpc.svcgssd[27492]: DEBUG: serialize_krb5_ctx: lucid version!
> Feb 21 12:23:59 swtnas2 rpc.svcgssd[27492]: prepare_krb5_rfc4121_buffer: protocol 1
> Feb 21 12:23:59 swtnas2 rpc.svcgssd[27492]: prepare_krb5_rfc4121_buffer: serializing key with enctype 18 and size 32
> Feb 21 12:23:59 swtnas2 rpc.svcgssd[27492]: doing downcall
> Feb 21 12:23:59 swtnas2 rpc.svcgssd[27492]: mech: krb5, hndl len: 4, ctx len 52, timeout: 1361527573 (81734 from now), clnt: nfs@tomsbox2.staff.swt.wiai.uni-bamberg.de, uid: -1, gid: -1, num aux grps: 0:
> Feb 21 12:23:59 swtnas2 rpc.svcgssd[27492]: sending null reply
> Feb 21 12:23:59 swtnas2 rpc.svcgssd[27492]: writing message: **SHORTENED BECAUSE I DON'T KNOW WHETHER IT CONTAINS CONFIDENTIAL INFORMATION**
> Feb 21 12:23:59 swtnas2 rpc.svcgssd[27492]: finished handling null request
> Feb 21 12:23:59 swtnas2 rpc.svcgssd[27492]: entering poll
> Feb 21 12:23:59 swtnas2 rpc.idmapd[27564]: nfsdcb: authbuf=gss/krb5 authtype=user
> Feb 21 12:23:59 swtnas2 rpc.idmapd[27564]: Server : (user) id "0" -> name "root@staff.swt.wiai.uni-bamberg.de"
> Feb 21 12:23:59 swtnas2 rpc.idmapd[27564]: nfsdcb: authbuf=gss/krb5 authtype=group
> Feb 21 12:23:59 swtnas2 rpc.idmapd[27564]: Server : (group) id "0" -> name "root@staff.swt.wiai.uni-bamberg.de"
> ---snap---
> 
> 
> II.  Trying to mount from the OS X client:
> # date; mount -t nfs -o vers=4,sec=krb5,intr,soft swtnas2:/backups/testusr1 /Users/myuser/Desktop/nfs/
> mount_nfs: cant't mount /backups/testusr1 from swtnas2 onto /Users/myuser/Desktop/nfs: No such file or directory
> #
> 
> (I'm no MAC expert thus I have no clue how to get more detailed debugging information here)
> 
> 
> This is what I get in the server's log when I try to mount from the OS X client:
> ---snip---
> Feb 21 12:35:18 swtnas2 rpc.svcgssd[27492]: leaving poll
> Feb 21 12:35:18 swtnas2 rpc.svcgssd[27492]: handling null request
> Feb 21 12:35:18 swtnas2 rpc.svcgssd[27492]: svcgssd_limit_krb5_enctypes: Calling gss_set_allowable_enctypes with 7 enctypes from the kernel
> Feb 21 12:35:18 swtnas2 rpc.svcgssd[27492]: sname = root@SWT.WIAI.UNI-BAMBERG.DE
> Feb 21 12:35:18 swtnas2 rpc.svcgssd[27492]: DEBUG: serialize_krb5_ctx: lucid version!
> Feb 21 12:35:18 swtnas2 rpc.svcgssd[27492]: prepare_krb5_rfc1964_buffer: serializing keys with enctype 4 and length 8
> Feb 21 12:35:18 swtnas2 rpc.svcgssd[27492]: doing downcall
> Feb 21 12:35:18 swtnas2 rpc.svcgssd[27492]: mech: krb5, hndl len: 4, ctx len 85, timeout: 1361472669 (26151 from now), clnt: <null>, uid: 0, gid: 0, num aux grps: 1:
> Feb 21 12:35:18 swtnas2 rpc.svcgssd[27492]:   (   1) 0
> Feb 21 12:35:18 swtnas2 rpc.svcgssd[27492]: sending null reply
> Feb 21 12:35:18 swtnas2 rpc.svcgssd[27492]: writing message: **SHORTENED BECAUSE I DON'T KNOW WHETHER IT CONTAINS CONFIDENTIAL INFORMATION**
> Feb 21 12:35:18 swtnas2 rpc.svcgssd[27492]: finished handling null request
> Feb 21 12:35:18 swtnas2 rpc.svcgssd[27492]: entering poll
> ---snap---
> 
> 
> 
> The clients obviously work quite different, however (if I got that right) it seems it's no authentication issue as I suspected initially. I don't really have an idea of what the log output should look like upon a successful mount so I don't have a plan where to go from here. Can you give me a hand?
> 
> Thanks!
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
