From: =?ISO-8859-1?Q?Carlos_Andr=E9?= <candrecn@gmail.com>
Subject: Re: Kerberos+NFSv4: Security - Multiple sessions with same user. One
	ticket for all?
Date: Wed, 26 Aug 2009 19:31:56 -0300
Message-ID: <f6ce31e30908261531m1ce99cd8m9ddde6269f0e536f@mail.gmail.com>
References: <f6ce31e30908260446g534bb70bxd742e35141ae99c1@mail.gmail.com>
	 <4A9521AE.3010900@s3group.cz>
	 <cbeb1f2b0908261409t21222b37le77f9afc03da038a@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Ondrej Valousek <webserv-K2D8ygZuxnnrBKCeMvbIDA@public.gmane.org>,
	NFS list <linux-nfs@vger.kernel.org>,
	Linux NFSv4 mailing list <nfsv4@linux-nfs.org>
To: le wang <lewang2000@gmail.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-vw0-f195.google.com ([209.85.212.195]:36404 "EHLO
	mail-vw0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753993AbZHZWbz convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 26 Aug 2009 18:31:55 -0400
Received: by vws33 with SMTP id 33so461047vws.33
        for <linux-nfs@vger.kernel.org>; Wed, 26 Aug 2009 15:31:57 -0700 (PDT)
In-Reply-To: <cbeb1f2b0908261409t21222b37le77f9afc03da038a-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Wang,

I know about "normal NFS" security issues... old times... "trust on
host"... -_-'
But I thought that this problem never happen using NFSv4+Kerberos5. In
resume, it's more secure then only NFS (without Kerberos), but still
have alot of serious security problems...

On Wed, Aug 26, 2009 at 6:09 PM, le wang<lewang2000@gmail.com> wrote:
> This is the security issue of NFS which exists extensively in NIS dir=
ectory
> environment since regular NFS authentication depends on UID and GID.
> $ ypcat password |grep $FOO to get the user FOO's UID and GID;
> Local root of ANY machine in this Directory could create a faked user=
 with
> FOO's UID and GID through cmd "groupadd" and "useradd", and then acce=
ss
> FOO's files on any machine.
> If Kerberos 5 is applied, this kind of security issue could be solved
> partially and limited on the scenario which Ondrej described below.
> -Le
>
>
> On Wed, Aug 26, 2009 at 7:51 AM, Ondrej Valousek <webserv-K2D8ygZuxnnrBKCeMvbIDA@public.gmane.org>=
 wrote:
>>
>> This issue has already been discussed on this list.
>> Local root has access to all credentials stored on that machine and =
there
>> is nothing you can do with this. You can only tell the user not to l=
og to a
>> machine which is already compromised by malicious attacker having ro=
ot
>> access.
>> Ondrej
>>
>> Carlos Andr=E9 wrote:
>>>
>>> I got a strange security issue. I logon via SSH or local console wi=
th
>>> my user and get a ticket, then if local root su to my user, local r=
oot
>>> can access my files.
>>>
>>> I'm using CentOS 5.3:
>>> kernel-2.6.18-128.2.1.el5
>>> krb5-workstation-1.6.1-31.el5_3.3
>>>
>>>
>>> SESSION 1:
>>> -----------------------------------------------------------------
>>> $ ssh root@1.2.3.4
>>> root@1.2.3.4's password:
>>> Last login: Wed Aug 26 08:06:49 2009 from X
>>> [root@KSTATION ~]# su carlos.andre
>>> [carlos.andre@KSTATION root]$ klist
>>> klist: No credentials cache found (ticket cache FILE:/tmp/krb5cc_10=
000)
>>>
>>>
>>> Kerberos 4 ticket cache: /tmp/tkt10000
>>> klist: You have no tickets cached
>>> [carlos.andre@KSTATION root]$ cd /misc/home/carlos.andre
>>> bash: cd: /misc/home/carlos.andre: Permission denied
>>> [carlos.andre@KSTATION root]$
>>> -----------------------------------------------------------------
>>> [--OK--]
>>>
>>>
>>> SESSION 2:
>>> -----------------------------------------------------------------
>>> $ ssh carlos.andre@1.2.3.4
>>> carlos.andre@1.2.3.4's password:
>>> Last login: Wed Aug 26 08:01:33 2009 from X
>>> [carlos.andre@KSTATION ~]$ klist
>>> Ticket cache: FILE:/tmp/krb5cc_10000_PPLMqF
>>> Default principal: carlos.andre@X.BR
>>>
>>> Valid starting =A0 =A0 Expires =A0 =A0 =A0 =A0 =A0 =A0Service princ=
ipal
>>> 08/26/09 08:30:12 =A008/26/09 18:30:12 =A0krbtgt/X.BR@X.BR
>>> =A0 =A0 =A0 =A0renew until 08/26/09 08:30:12
>>>
>>>
>>> Kerberos 4 ticket cache: /tmp/tkt10000
>>> klist: You have no tickets cached
>>> [carlos.andre@KSTATION ~]$ cd /misc/home/carlos.andre
>>> [carlos.andre@KSTATION carlos.andre]$ ls -la
>>> total 8
>>> drwxrwx--- 2 carlos.andre users 4096 Aug 21 09:04 .
>>> drwxr-xr-x 3 root =A0 =A0 =A0 =A0 root =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
0 Aug 26 08:30 ..
>>> [carlos.andre@KSTATION carlos.andre]$
>>> -----------------------------------------------------------------
>>> [--OK--]
>>>
>>>
>>> NOW BACK TO SESSION 1:
>>> -----------------------------------------------------------------
>>> [carlos.andre@KSTATION root]$ cd /misc/home/carlos.andre
>>> [carlos.andre@KSTATION carlos.andre]$ ls -la
>>> total 8
>>> drwxrwx--- 2 carlos.andre users 4096 Aug 21 09:04 .
>>> drwxr-xr-x 3 root =A0 =A0 =A0 =A0 root =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
0 Aug 26 08:30 ..
>>> [carlos.andre@KSTATION carlos.andre]$ klist
>>> klist: No credentials cache found (ticket cache FILE:/tmp/krb5cc_10=
000)
>>>
>>>
>>> Kerberos 4 ticket cache: /tmp/tkt10000
>>> klist: You have no tickets cached
>>> [carlos.andre@KSTATION carlos.andre]$
>>> -----------------------------------------------------------------
>>> [WTF!?!?]
>>>
>>> Then, if I log on someone machine, local root user (and 'su' to my
>>> user) will have access to my files like NFS without Kerberos?? This
>>> behavior is "correct" or it's a bug?
>>> And more strange it's credentials, root 'su'ed to my user doesnt go=
t
>>> credentials, but still have access to my files...
>>>
>>> Or I'm doing something wrong? -_-'
>>>
>>> Thanks.
>>> _______________________________________________
>>> NFSv4 mailing list
>>> NFSv4@linux-nfs.org
>>> http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4
>>>
>>
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-nfs"=
 in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at =A0http://vger.kernel.org/majordomo-info.html
>
>
>
> --
> Le Wang
> ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
> The good man is the friend of all living things.
> Gandhi, Mahatma(1869-1948)
> ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
>
> _______________________________________________
> NFSv4 mailing list
> NFSv4@linux-nfs.org
> http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4
>
