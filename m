Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-iw0-f174.google.com ([209.85.214.174]:39230 "EHLO
	mail-iw0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756153Ab1DPAHo convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 15 Apr 2011 20:07:44 -0400
Received: by iwn34 with SMTP id 34so2531206iwn.19
        for <linux-nfs@vger.kernel.org>; Fri, 15 Apr 2011 17:07:43 -0700 (PDT)
In-Reply-To: <4DA0F46D.3000909@tudelft.nl>
References: <BANLkTintp8Hx-D46L0WC6-+JJK=jDvz1KQ@mail.gmail.com>
	<4DA0F46D.3000909@tudelft.nl>
Date: Fri, 15 Apr 2011 17:07:43 -0700
Message-ID: <BANLkTim8R0f=gXBLzV2Ym-KaRpOCq672SQ@mail.gmail.com>
Subject: Re: linux / automount not respecting sec=sys parameter when NFS
 server supports sys:krb5
From: Myles Uyema <mlists@uyema.net>
To: Richard Smits <R.Smits@tudelft.nl>
Cc: linux-nfs <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Yes, on the filer /etc/exports (and exportfs output) the parameter is
-sec=sys:krb5
It works generally for mounts listed in /etc/fstab, but automount is a
weird one.

I believe we have narrowed it down to 2.6.20 kernel behavior. More
news forthcoming with a newer kernel.

On Sat, Apr 9, 2011 at 5:06 PM, Richard Smits <R.Smits@tudelft.nl> wrote:
> Myles Uyema wrote:
>> We have a Netapp filer (8.0.1) exporting NFSv3 homedirs with -sec=sys:krb5,rw
>
> This is interesting. Are you making an export on a Netapp filer that is
> "sec=sys" AND "sec=krb5" ? (sys:krb5)
>
> In my experience this doesn't work and you can only make a "sec=sys"
> export OR a "sec=krb5" on the same directory/qtree.
>
> Can you please clarify this ?
>
> Greetings .. Richard Smits
>
>> We have automount using LDAP for homedir mounts, explicitly specifying
>> sec=sys for all users, except for the krb5 beta testers.
>>
>> We are rolling out users with kerberos slowly across our linux
>> machines. However, when a krb5 beta tester accessing any homedir,
>> Linux and automount will choose to mount that homedir using sec=krb5.
>> It's quite apparent that /etc/mtab shows the mount parameter as
>> sec=sys, but /proc/mounts shows the same mount as sec=krb5
>>
>> /etc/mtab
>> nfstest101:/vol/krbtest01/testuser /home/testuser nfs
>> rw,hard,intr,sec=sys,addr=10.21.127.101 0 0
>>
>> /proc/mounts
>> nfstest101:/vol/krbtest01/testuser /home/testuser nfs
>> rw,vers=3,rsize=65536,wsize=65536,hard,intr,proto=tcp,timeo=600,retrans=2,sec=krb5,addr=10.21.127.101
>> 0 0
>>
>> If testuser then logs in (without a kerberos ticket) they cannot
>> access their own home directory.
>>
>> Why is linux/automount ignoring our explicit sec=sys parameter?
>>
>> Linux 2.6.20 kernel CentOS 5.x
>> Autofs 5.0.1
>> mount (util-linux 2.13-pre7)
>> MIT-Kerberos 5
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
