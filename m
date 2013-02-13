Return-Path: linux-nfs-owner@vger.kernel.org
Received: from ax13.adsl.tnnet.fi ([217.112.254.13]:54588 "EHLO
	mail.opinsys.fi" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1756589Ab3BMPnh (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 13 Feb 2013 10:43:37 -0500
Received: from localhost (localhost [127.0.0.1])
	by mail.opinsys.fi (Postfix) with ESMTP id 7E46C281E0D
	for <linux-nfs@vger.kernel.org>; Wed, 13 Feb 2013 15:29:29 +0000 (UTC)
Received: from mail.opinsys.fi ([127.0.0.1])
	by localhost (mail.opinsys.fi [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id 6uPvXGKvdC1v for <linux-nfs@vger.kernel.org>;
	Wed, 13 Feb 2013 15:29:29 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
	by mail.opinsys.fi (Postfix) with ESMTP id C43E5281E06
	for <linux-nfs@vger.kernel.org>; Wed, 13 Feb 2013 15:29:28 +0000 (UTC)
Received: from mail.opinsys.fi ([127.0.0.1])
	by localhost (mail.opinsys.fi [127.0.0.1]) (amavisd-new, port 10026)
	with ESMTP id YkTgBDRjUNNN for <linux-nfs@vger.kernel.org>;
	Wed, 13 Feb 2013 15:29:28 +0000 (UTC)
Received: from mail.opinsys.fi (mail.opinsys.fi [10.246.133.21])
	by mail.opinsys.fi (Postfix) with ESMTP id 44147281E0D
	for <linux-nfs@vger.kernel.org>; Wed, 13 Feb 2013 15:29:28 +0000 (UTC)
Date: Wed, 13 Feb 2013 15:29:27 +0000 (UTC)
From: Veli-Matti Lintu <veli-matti.lintu@opinsys.fi>
To: linux-nfs@vger.kernel.org
Message-ID: <127351146.98508.1360769367943.JavaMail.root@opinsys.fi>
In-Reply-To: <471074187.98491.1360768929786.JavaMail.root@opinsys.fi>
Subject: Kernels 3.7 and newer break rpc.gssd -n
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


I've been using kerberized nfs4 mounts without machine credentials for 
quite some time by running rpc.gssd with the -n option. This has 
resulted rpc.gssd in using ccache in /tmp/krb5cc_0 when doing the mount 
instead of machine credentials. This functionality seems to break when 
using kernel 3.7 or newer. 3.6.11 and earlier work like expected.

The use case for this is diskless workstations that do not have machine 
credentials stored on them as they have no secure storage medium. When a 
user logs in, the home directory is mounted using the user's credentials 
only.

Steps to reproduce the problem:

# kinit user (this creates /tmp/krb5cc_0)
# rpc.gssd -f -n -vvvv
# mount -t nfs4 -o sec=krb5 server.example.org:/home /mnt

The mount works when using kernel 3.6.11 or earlier and fails on 3.7-rc1 
or later. Testing was done on Ubuntu 12.04 and 12.10 using Ubuntu kernels
and kernel.org kernels (up to 3.8-rc7) with similar results.

nfs-utils versions 1.2.5 and the latest version from git master head 
(git://linux-nfs.org/nfs-utils) behave the same way.


rpc.gssd outputs the following when the mount command is given:

3.6.11:

# rpc.gssd -f -n -vvvv
beginning poll
dir_notify_handler: sig 37 si 0xbfb2c4ec data 0xbfb2c56c
dir_notify_handler: sig 37 si 0xbfb2c4ec data 0xbfb2c56c
dir_notify_handler: sig 37 si 0xbfb2c4ec data 0xbfb2c56c
dir_notify_handler: sig 37 si 0xbfb26bac data 0xbfb26c2c
dir_notify_handler: sig 37 si 0xbfb2c4ec data 0xbfb2c56c
handling gssd upcall (/run/rpc_pipefs/nfs/clnt0)
handle_gssd_upcall: 'mech=krb5 uid=0 enctypes=18,17,16,23,3,1,2 '
handling krb5 upcall (/run/rpc_pipefs/nfs/clnt0)
process_krb5_upcall: service is '<null>'
getting credentials for client with uid 0 for server server.example.org
...

3.7-rc1:

# rpc.gssd -f -n -vvvv
beginning poll
dir_notify_handler: sig 37 si 0xbf9e2d8c data 0xbf9e2e0c
dir_notify_handler: sig 37 si 0xbf9de3cc data 0xbf9de44c
handling gssd upcall (/run/rpc_pipefs/nfs/clnt1a)
handle_gssd_upcall: 'mech=krb5 uid=0 service=* enctypes=18,17,16,23,3,1,2 '
handling krb5 upcall (/run/rpc_pipefs/nfs/clnt1a)
process_krb5_upcall: service is '*'
...


It seems like the kernel now asks rpc.gssd to fetch credentials for 
service '*' instead of NULL like with 3.6 and earlier.

This leads to method process_krb5_upcall() in 
nfs-utils/utils/gssd/gssd_proc.c where there's a comment saying:

        /*
         * If "service" is specified, then the kernel is indicating that
         * we must use machine credentials for this request.  (Regardless
         * of the uid value or the setting of root_uses_machine_creds.)
         * If the service value is "*", then any service name can be used.
         * Otherwise, it specifies the service name that should be used.
         * (For now, the values of service will only be "*" or "nfs".)
         *
         * Restricting gssd to use "nfs" service name is needed for when
         * the NFS server is doing a callback to the NFS client.  In this
         * case, the NFS server has to authenticate itself as "nfs" --
         * even if there are other service keys such as "host" or "root"
         * in the keytab.
         *
         * Another case when the kernel may specify the service attribute
         * is when gssd is being asked to create the context for a
         * SETCLIENT_ID operation.  In this case, machine credentials
         * must be used for the authentication.  However, the service name
         * used for this case is not important.
         *
         */

It looks like rpc.gssd does not want to load the user credentials 
because the service name is * instead of null like before. When I 
patched gssd_proc.c in gssd sources to ignore the check for 
service_name==NULL, rpc.gssd returned the user credentials and the nfs 
mount succeeded.

Is this something that should be still be supported? Any pointers where I 
should start looking for a fix?

Veli-Matti
