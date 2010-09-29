Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.rwedea.de ([194.39.1.131]:38542 "EHLO mx1.rwedea.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751600Ab0I2JCb convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 29 Sep 2010 05:02:31 -0400
Content-Type: text/plain;
	charset="iso-8859-1"
Subject: NFS4 / GSS: Problem with users accessing the mounted directories (with root, everything ist okay)
Date: Wed, 29 Sep 2010 11:02:21 +0200
Message-ID: <D4AFE98FB48D2F4CBFEACD015C9642DF026628@sha2122.hamburg.rwedea.de>
From: "Beyersdorf, Wolfgang" <Wolfgang.Beyersdorf.Fa.Kontraktor@rwedea.com>
To: <linux-nfs@vger.kernel.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

 


Dear all,

I got NFS4 with GSS running on CentOS 5. Everything is okay, all TGTs are okay and is working fine for the user ROOT.

When I change to an other user, I got a permission denied, when I try to access the dierctory (e.g. ls -la)

Here is the /var/log/messages part for this access (with full debugging on ndf, ndfs and rcp):

Sep 29 10:11:59 sha9013 kernel: NFS: revalidating (0:1a/4030465)
Sep 29 10:11:59 sha9013 kernel: RPC:    0 new task procpid 15472
Sep 29 10:11:59 sha9013 kernel: RPC:    0 allocated task
Sep 29 10:11:59 sha9013 kernel: RPC:    0 looking up RPCSEC_GSS cred
Sep 29 10:11:59 sha9013 kernel: RPC: gc'ing RPC credentials for auth ffff810076dc22c0
Sep 29 10:11:59 sha9013 kernel: RPC:      gss_destroy_cred
Sep 29 10:11:59 sha9013 kernel: RPC:      gss_create_cred for uid 569926353, flavor 390003
Sep 29 10:11:59 sha9013 kernel: RPC: gss_upcall for uid 569926353
Sep 29 10:11:59 sha9013 kernel: RPC:      gss_find_upcall found nothing
Sep 29 10:11:59 sha9013 rpc.gssd[1645]: handling krb5 upcall
Sep 29 10:11:59 sha9013 rpc.gssd[1645]: getting credentials for client with uid 569926353 for server sha9012.hamburg.rwedea.de
Sep 29 10:11:59 sha9013 rpc.gssd[1645]: CC file 'krb5cc_569926353' being considered
Sep 29 10:11:59 sha9013 rpc.gssd[1645]: CC file 'krb5cc_569926353' matches owner check and has mtime of 1285746876
Sep 29 10:11:59 sha9013 rpc.gssd[1645]: CC file 'krb5cc_0_osSsov' being considered
Sep 29 10:11:59 sha9013 rpc.gssd[1645]: '/tmp/krb5cc_0_osSsov' owned by 0, not 569926353
Sep 29 10:11:59 sha9013 rpc.gssd[1645]: CC file 'krb5cc_0_mLx0Bh' being considered
Sep 29 10:11:59 sha9013 rpc.gssd[1645]: '/tmp/krb5cc_0_mLx0Bh' owned by 0, not 569926353
Sep 29 10:11:59 sha9013 rpc.gssd[1645]: using FILE:/tmp/krb5cc_569926353 as credentials cache for client with uid 569926353 for server sha9012.hamburg.rwede
Sep 29 10:11:59 sha9013 rpc.gssd[1645]: using environment variable to select krb5 ccache FILE:/tmp/krb5cc_569926353
Sep 29 10:11:59 sha9013 rpc.gssd[1645]: creating context using fsuid 569926353 (save_uid 0)
Sep 29 10:11:59 sha9013 rpc.gssd[1645]: creating tcp client for server sha9012.hamburg.rwedea.de
Sep 29 10:11:59 sha9013 rpc.gssd[1645]: creating context with server nfs@sha9012.hamburg.rwedea.de			<================================== system ist wating for 25 seconds
Sep 29 10:12:23 sha9013 rpc.gssd[1645]: WARNING: Failed to create krb5 context for user with uid 569926353 for server sha9012.hamburg.rwedea.de
Sep 29 10:12:23 sha9013 rpc.gssd[1645]: WARNING: Failed to create krb5 context for user with uid 569926353 for server sha9012.hamburg.rwedea.de
Sep 29 10:12:23 sha9013 rpc.gssd[1645]: doing error downcall
Sep 29 10:12:23 sha9013 kernel: RPC:      gss_fill_context returning 13
Sep 29 10:12:23 sha9013 kernel: RPC:      gss_find_upcall found msg ffff81007e824ec0
Sep 29 10:12:23 sha9013 kernel: RPC:      gss_destroy_ctx
Sep 29 10:12:23 sha9013 kernel: RPC:      gss_pipe_downcall returning length 16
Sep 29 10:12:23 sha9013 kernel: RPC: gss_create_upcall for uid 569926353 result -13
Sep 29 10:12:23 sha9013 kernel: RPC:      rpc_release_client(ffff810073dbc200, 1)
Sep 29 10:12:23 sha9013 kernel: nfs_revalidate_inode: (0:1a/4030465) getattr failed, error=-13
Sep 29 10:12:23 sha9013 kernel: RPC:     looking up RPCSEC_GSS cred
Sep 29 10:12:23 sha9013 kernel: RPC: gss_upcall for uid 569926353
Sep 29 10:12:23 sha9013 kernel: RPC:      gss_find_upcall found nothing
Sep 29 10:12:23 sha9013 rpc.gssd[1645]: handling krb5 upcall
Sep 29 10:12:23 sha9013 kernel: RPC:    0 freeing task
Sep 29 10:12:23 sha9013 rpc.gssd[1645]: getting credentials for client with uid 569926353 for server sha9012.hamburg.rwedea.de
Sep 29 10:12:23 sha9013 rpc.gssd[1645]: CC file 'krb5cc_569926353' being considered
Sep 29 10:12:23 sha9013 rpc.gssd[1645]: CC file 'krb5cc_569926353' matches owner check and has mtime of 1285746876
Sep 29 10:12:23 sha9013 rpc.gssd[1645]: CC file 'krb5cc_0_osSsov' being considered
Sep 29 10:12:23 sha9013 rpc.gssd[1645]: '/tmp/krb5cc_0_osSsov' owned by 0, not 569926353
Sep 29 10:12:23 sha9013 rpc.gssd[1645]: CC file 'krb5cc_0_mLx0Bh' being considered
Sep 29 10:12:23 sha9013 rpc.gssd[1645]: '/tmp/krb5cc_0_mLx0Bh' owned by 0, not 569926353
Sep 29 10:12:23 sha9013 rpc.gssd[1645]: using FILE:/tmp/krb5cc_569926353 as credentials cache for client with uid 569926353 for server sha9012.hamburg.rwede
Sep 29 10:12:23 sha9013 rpc.gssd[1645]: using environment variable to select krb5 ccache FILE:/tmp/krb5cc_569926353
Sep 29 10:12:23 sha9013 rpc.gssd[1645]: creating context using fsuid 569926353 (save_uid 0)
Sep 29 10:12:23 sha9013 rpc.gssd[1645]: creating tcp client for server sha9012.hamburg.rwedea.de
Sep 29 10:12:23 sha9013 rpc.gssd[1645]: creating context with server nfs@sha9012.hamburg.rwedea.de
Sep 29 10:12:48 sha9013 rpc.gssd[1645]: WARNING: Failed to create krb5 context for user with uid 569926353 for server sha9012.hamburg.rwedea.de
Sep 29 10:12:48 sha9013 rpc.gssd[1645]: WARNING: Failed to create krb5 context for user with uid 569926353 for server sha9012.hamburg.rwedea.de
Sep 29 10:12:48 sha9013 rpc.gssd[1645]: doing error downcall
Sep 29 10:12:48 sha9013 kernel: RPC:      gss_fill_context returning 13
Sep 29 10:12:48 sha9013 kernel: RPC:      gss_find_upcall found msg ffff81007e824ec0
Sep 29 10:12:48 sha9013 kernel: RPC:      gss_destroy_ctx
Sep 29 10:12:48 sha9013 kernel: RPC:      gss_pipe_downcall returning length 16
Sep 29 10:12:48 sha9013 kernel: RPC: gss_create_upcall for uid 569926353 result -13
Sep 29 10:12:48 sha9013 kernel: NFS: permission(0:1a/4030465), mask=0x1, res=-13
Sep 29 10:12:48 sha9013 kernel: RPC:     looking up RPCSEC_GSS cred
Sep 29 10:12:48 sha9013 kernel: RPC: gss_upcall for uid 569926353
Sep 29 10:12:48 sha9013 kernel: RPC:      gss_find_upcall found nothing
Sep 29 10:12:48 sha9013 rpc.gssd[1645]: handling krb5 upcall
Sep 29 10:12:48 sha9013 rpc.gssd[1645]: getting credentials for client with uid 569926353 for server sha9012.hamburg.rwedea.de
Sep 29 10:12:48 sha9013 rpc.gssd[1645]: CC file 'krb5cc_569926353' being considered
Sep 29 10:12:48 sha9013 rpc.gssd[1645]: CC file 'krb5cc_569926353' matches owner check and has mtime of 1285746876
Sep 29 10:12:48 sha9013 rpc.gssd[1645]: CC file 'krb5cc_0_osSsov' being considered
Sep 29 10:12:48 sha9013 rpc.gssd[1645]: '/tmp/krb5cc_0_osSsov' owned by 0, not 569926353
Sep 29 10:12:48 sha9013 rpc.gssd[1645]: CC file 'krb5cc_0_mLx0Bh' being considered
Sep 29 10:12:48 sha9013 rpc.gssd[1645]: '/tmp/krb5cc_0_mLx0Bh' owned by 0, not 569926353
Sep 29 10:12:48 sha9013 rpc.gssd[1645]: using FILE:/tmp/krb5cc_569926353 as credentials cache for client with uid 569926353 for server sha9012.hamburg.rwede
Sep 29 10:12:48 sha9013 rpc.gssd[1645]: using environment variable to select krb5 ccache FILE:/tmp/krb5cc_569926353
Sep 29 10:12:48 sha9013 rpc.gssd[1645]: creating context using fsuid 569926353 (save_uid 0)
Sep 29 10:12:48 sha9013 rpc.gssd[1645]: creating tcp client for server sha9012.hamburg.rwedea.de
Sep 29 10:12:48 sha9013 rpc.gssd[1645]: creating context with server nfs@sha9012.hamburg.rwedea.de



A  klist gives the following result:
========================

Ticket cache: FILE:/tmp/krb5cc_569926353
Default principal: xdiwb@HAMBURG.RWEDEA.DE

Valid starting     Expires            Service principal
09/29/10 08:59:35  09/29/10 18:59:54  krbtgt/HAMBURG.RWEDEA.DE@HAMBURG.RWEDEA.DE
        renew until 09/30/10 08:59:35
09/29/10 09:00:02  09/29/10 18:59:54  nfs/sha9012.hamburg.rwedea.de@HAMBURG.RWEDEA.DE
        renew until 09/30/10 08:59:35
09/29/10 09:54:43  09/29/10 18:59:54  nfs/sha2059.hamburg.rwedea.de@HAMBURG.RWEDEA.DE
        renew until 09/30/10 08:59:35


Kerberos 4 ticket cache: /tmp/tkt569926353
klist: You have no tickets cached


Here the result from ls -la:
===================

?---------  ? ?    ?        ?            ? nfs4test
drwxr-xr-x  3 root root  4096 Sep 13 15:19 opt
dr-xr-xr-x 95 root root     0 Sep 27 14:28 proc
drwxr-x---  3 root root  4096 Jan 26  2010 root
drwxr-xr-x  2 root root 12288 Sep 15 04:02 sbin
drwxr-xr-x  2 root root  4096 Jan 26  2010 selinux
drwxr-xr-x  2 root root  4096 Jan 26  2010 srv
drwxr-xr-x 30 root root     0 Sep 28 09:19 sw
drwxr-xr-x 11 root root     0 Sep 27 14:28 sys
-rw-r--r--  1 root root  6932 Sep 28 10:35 tdump.dmp
drwxr-xr-x  2 root root  4096 Sep 13 17:04 test
drwxrwxrwt  4 root root  4096 Sep 29 08:59 tmp
drwxr-xr-x 14 root root  4096 Sep 13 15:01 usr
drwxr-xr-x 19 root root  4096 Sep 13 15:01 var



On the server, there is nothing inside the /var/log/messages


Could anybody help me?

Thanks a lot.



Mit freundlichen Grüßen / Best regards

Wolfgang Beyersdorf

RWE Dea AG
Abteilung IT-Infraktrukturen
Überseering 40, 22297 Hamburg, Germany
T +49 40 6375-3258
M +40 160 5497897
E Wolfgang.Beyersdorf.FA.Kontraktor@rwedea.com
I www.rwedea.com

RWE Dea AG
Vorsitzender des Aufsichtsrats: Dr. Ulrich Jobs
Vorstand: Thomas Rappuhn (Vorsitzender), Lutz-Michael Liebau, Ralf to Baben

Sitz der Gesellschaft: Hamburg
Eingetragen beim AG Hamburg, Handelsregister - Nr.: HRB 6882


