Return-Path: linux-nfs-owner@vger.kernel.org
Received: from partagas.dragonet.es ([217.70.240.130]:36123 "EHLO
	partagas.dragonet.es" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752723Ab2A1VPt (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 28 Jan 2012 16:15:49 -0500
Received: from [192.168.1.3] (217-70-247-131.dragonet.es [217.70.247.131] (may be forged))
	(authenticated bits=0)
	by partagas.dragonet.es (8.12.11/8.12.11) with ESMTP id q0SL2QgW008105
	for <linux-nfs@vger.kernel.org>; Sat, 28 Jan 2012 22:02:33 +0100
Message-ID: <4F24624C.7050107@steve-ss.com>
Date: Sat, 28 Jan 2012 22:02:04 +0100
From: steve <steve@steve-ss.com>
MIME-Version: 1.0
To: linux-nfs@vger.kernel.org
Subject: nfs4 gss/krb5 read only mount problem
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi
This is my first post here so hi everyone.
My problem is that if I export an nfs4 share 'conventionally', the 
mounted share is mounted rw. If I mount using gss/krb5 it is read only. 
I think I can explain this best using examples of what I've tried:

openSUSE 12.1

/etc/fstab:
/home    /export/home   none    rw,bind  0  0

1. kerberized /etc/exports
/export             gss/krb5(rw,fsid=0,insecure,no_subtree_check,async)
/export/home    gss/krb5(rw,nohide,insecure,no_subtree_check,async)
then:
mount -t nfs4 hh3:/home /mnt -o sec=krb5
no write access

2. conventional /etc/exports
/export             *(rw,fsid=0,insecure,no_subtree_check,async)
/export/home    *(rw,nohide,insecure,no_subtree_check,async)
then:
mount -t nfs4 hh3:/home /mnt
write access OK

3. kerberized variation on /etc/exports
/export   *(rw,fsid=0,crossmnt,insecure,no_subtree_check,async,sec=krb5)
/export/home    *(rw,insecure,no_subtree_check,async,sec=krb5)
then:
mount -t nfs4 hh3:/home /mnt -o sec=krb5
no write access

I have tried all combos of crossmnt and nohide

idmapd seems to be mapping correctly and id<user>  gives what getent
gives

Any ideas? Why does the kerberized mount not allow rw access? Could this 
be a nfs4 problem or a Kerberos problem?
Thanks,
Steve

