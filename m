From: yagi shinnosuke <linus404@gmail.com>
Subject: Failed to create machine krb5 context with any credentials cache for
	server
Date: Fri, 18 Jun 2010 07:27:18 +0900
Message-ID: <AANLkTilsxbQrLAEwypOGgL72ePRNM7v5lm4H56HtrhGR@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-vw0-f46.google.com ([209.85.212.46]:60778 "EHLO
	mail-vw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760137Ab0FQW1T (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 17 Jun 2010 18:27:19 -0400
Received: by vws3 with SMTP id 3so231238vws.19
        for <linux-nfs@vger.kernel.org>; Thu, 17 Jun 2010 15:27:18 -0700 (PDT)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hello.

I have been trying to set up kerberized nfsv3 server and clients over IPv6
network, but run into a few problems.

When I try to mount NFS share, an error "permission denied." occured and
failed to mount.

My server is FreeBSD8. My client is Fedora 13.
Without Kerberos, I can mount NFS share.

Output of mount command is follow
=============================================================================================
# mount -t nfs nfsserv.localdomain:/export/work /mnt/nfs/ -o
sec=krb5,vers=3 -v
mount.nfs: timeout set for Tue Jun 15 10:54:11 2010
mount.nfs: trying text-based options
'sec=krb5,vers=3,addr=2002:192:168:1:217:a4ff:fe20:e5f0'
mount.nfs: prog 100003, trying vers=3, prot=6
mount.nfs: trying 2001:XXXX::a4ff:fe20:e5f0 prog 100003 vers 3 prot TCP
port 2049
mount.nfs: prog 100005, trying vers=3, prot=17
mount.nfs: trying 2001:XXXX::a4ff:fe20:e5f0 prog 100005 vers 3 prot UDP
port 818
mount.nfs: mount(2): Permission denied
mount.nfs: access denied by server while mounting
nfsserv.localdomain:/export/work
==============================================================================================

"nfsserv is hostname of NFS server and 2001:XXXX::a4ff:fe20:e5f0 is
its IPv6 address.


I run rpc.gssd with -vvvvv options, and I got following warnings.
==============================================================================================
creating context with server nfs-m9Topm0561QB9AHHLWeGtNQXobZC6xk2@public.gmane.org
WARNING: Failed to create krb5 context for user with uid 0 for server
nfsserv.localdomain
WARNING: Failed to create machine krb5 context with credentials cache
FILE:/tmp/krb5cc_machine_NWBOOT for server nfsserv.localdomain
WARNING: Failed to create machine krb5 context with any credentials
cache for server nfsserv.localdomain
doing error downcall
==============================================================================================

It seems that rpc.gssd could not create credentials for nfsserver.
However, I run kinit correctly on client.

My kinit and klist results are follow.
==============================================================================================
[root@fedoravm]# kinit root
Password for root@NWBOOT:
[root@fedoravm]# klist
Ticket cache: FILE:/tmp/krb5cc_0
Default principal: root@NWBOOT

Valid starting     Expires            Service principal
06/15/10 16:53:22  06/16/10 16:53:15  krbtgt/NWBOOT@NWBOOT
       renew until 06/22/10 16:53:15
==============================================================================================

I read following page and added root keytab to client, but nothing changed.
 http://www.mail-archive.com/linux-nfs@vger.kernel.org/msg01360.html

My Client Keytab:
==============================================================================================
[root@fedoravm]# ktutil
ktutil:  rkt /etc/krb5.keytab
ktutil:  list -e
slot KVNO Principal
---- ----
---------------------------------------------------------------------
  1    1          nfs/fedoravm.localdomain@NWBOOT (DES cbc mode with
CRC-32)
  2    1         root/fedoravm.localdomain@NWBOOT (DES cbc mode with
CRC-32)
  3    1         host/fedoravm.localdomain@NWBOOT (DES cbc mode with
CRC-32)
==============================================================================================

My Server Keytab:
==============================================================================================
nfsserv# ktutil list
FILE:/etc/krb5.keytab:

Vno  Type         Principal
 1  des-cbc-crc  nfs/nfsserv.localdomain@NWBOOT
 1  des-cbc-crc  root/nfsserv.localdomain@NWBOOT
 1  des-cbc-crc  host/nfsserv.localdomain@NWBOOT
==============================================================================================


I have surveyed web pages to find nothing about Kerberized NFS over IPv6.
I'm not sure it works or not.
Does rpc.gssd works on IPv6 enviromnent?

Can anybody give me any hints or suggestions?

Thanks.
