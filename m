Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mailservice.tudelft.nl ([130.161.131.5]:35023 "EHLO
	mailservice.tudelft.nl" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751114Ab1DJA2M (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 9 Apr 2011 20:28:12 -0400
Message-ID: <4DA0F46D.3000909@tudelft.nl>
Date: Sun, 10 Apr 2011 02:06:05 +0200
From: Richard Smits <R.Smits@tudelft.nl>
To: Myles Uyema <mlists@uyema.net>
CC: linux-nfs <linux-nfs@vger.kernel.org>
Subject: Re: linux / automount not respecting sec=sys parameter when NFS server
 supports sys:krb5
References: <BANLkTintp8Hx-D46L0WC6-+JJK=jDvz1KQ@mail.gmail.com>
In-Reply-To: <BANLkTintp8Hx-D46L0WC6-+JJK=jDvz1KQ@mail.gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Myles Uyema wrote:
> We have a Netapp filer (8.0.1) exporting NFSv3 homedirs with -sec=sys:krb5,rw

This is interesting. Are you making an export on a Netapp filer that is
"sec=sys" AND "sec=krb5" ? (sys:krb5)

In my experience this doesn't work and you can only make a "sec=sys"
export OR a "sec=krb5" on the same directory/qtree.

Can you please clarify this ?

Greetings .. Richard Smits

> We have automount using LDAP for homedir mounts, explicitly specifying
> sec=sys for all users, except for the krb5 beta testers.
> 
> We are rolling out users with kerberos slowly across our linux
> machines. However, when a krb5 beta tester accessing any homedir,
> Linux and automount will choose to mount that homedir using sec=krb5.
> It's quite apparent that /etc/mtab shows the mount parameter as
> sec=sys, but /proc/mounts shows the same mount as sec=krb5
> 
> /etc/mtab
> nfstest101:/vol/krbtest01/testuser /home/testuser nfs
> rw,hard,intr,sec=sys,addr=10.21.127.101 0 0
> 
> /proc/mounts
> nfstest101:/vol/krbtest01/testuser /home/testuser nfs
> rw,vers=3,rsize=65536,wsize=65536,hard,intr,proto=tcp,timeo=600,retrans=2,sec=krb5,addr=10.21.127.101
> 0 0
> 
> If testuser then logs in (without a kerberos ticket) they cannot
> access their own home directory.
> 
> Why is linux/automount ignoring our explicit sec=sys parameter?
> 
> Linux 2.6.20 kernel CentOS 5.x
> Autofs 5.0.1
> mount (util-linux 2.13-pre7)
> MIT-Kerberos 5
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
