Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mailservice.tudelft.nl ([130.161.131.5]:51825 "EHLO
	mailservice.tudelft.nl" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759327Ab1DPMAx (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 16 Apr 2011 08:00:53 -0400
Message-ID: <4DA984F2.20600@tudelft.nl>
Date: Sat, 16 Apr 2011 14:00:50 +0200
From: Richard Smits <R.Smits@tudelft.nl>
To: Myles Uyema <mlists@uyema.net>
CC: linux-nfs <linux-nfs@vger.kernel.org>
Subject: Re: linux / automount not respecting sec=sys parameter when NFS server
 supports sys:krb5
References: <BANLkTintp8Hx-D46L0WC6-+JJK=jDvz1KQ@mail.gmail.com>	<4DA0F46D.3000909@tudelft.nl> <BANLkTim8R0f=gXBLzV2Ym-KaRpOCq672SQ@mail.gmail.com>
In-Reply-To: <BANLkTim8R0f=gXBLzV2Ym-KaRpOCq672SQ@mail.gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Great tip. We did not knew this... I have tried it and it works great.
This will make our admin tasks a lot easier.

We also use automount scripts for different mountpoints to different
servers. We use an attribute in our AD for this.

> However, when a krb5 beta tester accessing any homedir,
> Linux and automount will choose to mount that homedir using sec=krb5.

How does the automounter makes this choice ? (sys or krb5) Is this a
manual setting or an entry in your ldap directory ?

Greetings ..

Myles Uyema wrote:
> Yes, on the filer /etc/exports (and exportfs output) the parameter is
> -sec=sys:krb5
> It works generally for mounts listed in /etc/fstab, but automount is a
> weird one.
> 
> I believe we have narrowed it down to 2.6.20 kernel behavior. More
> news forthcoming with a newer kernel.
> 
> On Sat, Apr 9, 2011 at 5:06 PM, Richard Smits <R.Smits@tudelft.nl> wrote:
>> Myles Uyema wrote:
>>> We have a Netapp filer (8.0.1) exporting NFSv3 homedirs with -sec=sys:krb5,rw
>> This is interesting. Are you making an export on a Netapp filer that is
>> "sec=sys" AND "sec=krb5" ? (sys:krb5)
>>
>> In my experience this doesn't work and you can only make a "sec=sys"
>> export OR a "sec=krb5" on the same directory/qtree.
>>
>> Can you please clarify this ?
>>
>> Greetings .. Richard Smits
>>
>>> We have automount using LDAP for homedir mounts, explicitly specifying
>>> sec=sys for all users, except for the krb5 beta testers.
>>>
>>> We are rolling out users with kerberos slowly across our linux
>>> machines. However, when a krb5 beta tester accessing any homedir,
>>> Linux and automount will choose to mount that homedir using sec=krb5.
>>> It's quite apparent that /etc/mtab shows the mount parameter as
>>> sec=sys, but /proc/mounts shows the same mount as sec=krb5
>>>
>>> /etc/mtab
>>> nfstest101:/vol/krbtest01/testuser /home/testuser nfs
>>> rw,hard,intr,sec=sys,addr=10.21.127.101 0 0
>>>
>>> /proc/mounts
>>> nfstest101:/vol/krbtest01/testuser /home/testuser nfs
>>> rw,vers=3,rsize=65536,wsize=65536,hard,intr,proto=tcp,timeo=600,retrans=2,sec=krb5,addr=10.21.127.101
>>> 0 0
>>>
>>> If testuser then logs in (without a kerberos ticket) they cannot
>>> access their own home directory.
>>>
>>> Why is linux/automount ignoring our explicit sec=sys parameter?
>>>
>>> Linux 2.6.20 kernel CentOS 5.x
>>> Autofs 5.0.1
>>> mount (util-linux 2.13-pre7)
>>> MIT-Kerberos 5
>>> --
>>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>>> the body of a message to majordomo@vger.kernel.org
>>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
