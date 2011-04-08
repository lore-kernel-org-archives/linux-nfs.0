Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:36588 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753317Ab1DHXad (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 8 Apr 2011 19:30:33 -0400
Received: by fxm17 with SMTP id 17so2629941fxm.19
        for <linux-nfs@vger.kernel.org>; Fri, 08 Apr 2011 16:30:32 -0700 (PDT)
Date: Fri, 8 Apr 2011 16:30:32 -0700
Message-ID: <BANLkTintp8Hx-D46L0WC6-+JJK=jDvz1KQ@mail.gmail.com>
Subject: linux / automount not respecting sec=sys parameter when NFS server
 supports sys:krb5
From: Myles Uyema <mlists@uyema.net>
To: linux-nfs <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

We have a Netapp filer (8.0.1) exporting NFSv3 homedirs with -sec=sys:krb5,rw
We have automount using LDAP for homedir mounts, explicitly specifying
sec=sys for all users, except for the krb5 beta testers.

We are rolling out users with kerberos slowly across our linux
machines. However, when a krb5 beta tester accessing any homedir,
Linux and automount will choose to mount that homedir using sec=krb5.
It's quite apparent that /etc/mtab shows the mount parameter as
sec=sys, but /proc/mounts shows the same mount as sec=krb5

/etc/mtab
nfstest101:/vol/krbtest01/testuser /home/testuser nfs
rw,hard,intr,sec=sys,addr=10.21.127.101 0 0

/proc/mounts
nfstest101:/vol/krbtest01/testuser /home/testuser nfs
rw,vers=3,rsize=65536,wsize=65536,hard,intr,proto=tcp,timeo=600,retrans=2,sec=krb5,addr=10.21.127.101
0 0

If testuser then logs in (without a kerberos ticket) they cannot
access their own home directory.

Why is linux/automount ignoring our explicit sec=sys parameter?

Linux 2.6.20 kernel CentOS 5.x
Autofs 5.0.1
mount (util-linux 2.13-pre7)
MIT-Kerberos 5
