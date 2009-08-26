From: le wang <lewang2000@gmail.com>
Subject: Re: Kerberos+NFSv4: Security - Multiple sessions with same user. One
	ticket for all?
Date: Wed, 26 Aug 2009 17:09:18 -0400
Message-ID: <cbeb1f2b0908261409t21222b37le77f9afc03da038a@mail.gmail.com>
References: <f6ce31e30908260446g534bb70bxd742e35141ae99c1@mail.gmail.com>
	<4A9521AE.3010900@s3group.cz>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============2097023403=="
Cc: NFS list <linux-nfs@vger.kernel.org>,
	Linux NFSv4 mailing list <nfsv4@linux-nfs.org>
To: Ondrej Valousek <webserv@s3group.cz>
Return-path: <nfsv4-bounces@linux-nfs.org>
In-Reply-To: <4A9521AE.3010900@s3group.cz>
List-Unsubscribe: <http://linux-nfs.org/cgi-bin/mailman/options/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=unsubscribe>
List-Archive: <http://linux-nfs.org/pipermail/nfsv4>
List-Post: <mailto:nfsv4@linux-nfs.org>
List-Help: <mailto:nfsv4-request@linux-nfs.org?subject=help>
List-Subscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=subscribe>
Sender: nfsv4-bounces@linux-nfs.org
Errors-To: nfsv4-bounces@linux-nfs.org
List-ID: <linux-nfs.vger.kernel.org>

--===============2097023403==
Content-Type: multipart/alternative; boundary=001636b2b4774033cb047211dd2b

--001636b2b4774033cb047211dd2b
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

This is the security issue of NFS which exists extensively in NIS directory
environment since regular NFS authentication depends on UID and GID.
$ ypcat password |grep $FOO to get the user FOO's UID and GID;
Local root of ANY machine in this Directory could create a faked user with
FOO's UID and GID through cmd "groupadd" and "useradd", and then access
FOO's files on any machine.
If Kerberos 5 is applied, this kind of security issue could be solved
partially and limited on the scenario which Ondrej described below.
-Le


On Wed, Aug 26, 2009 at 7:51 AM, Ondrej Valousek <webserv@s3group.cz> wrote=
:

> This issue has already been discussed on this list.
> Local root has access to all credentials stored on that machine and there
> is nothing you can do with this. You can only tell the user not to log to=
 a
> machine which is already compromised by malicious attacker having root
> access.
> Ondrej
>
> Carlos Andr=E9 wrote:
>
>> I got a strange security issue. I logon via SSH or local console with
>> my user and get a ticket, then if local root su to my user, local root
>> can access my files.
>>
>> I'm using CentOS 5.3:
>> kernel-2.6.18-128.2.1.el5
>> krb5-workstation-1.6.1-31.el5_3.3
>>
>>
>> SESSION 1:
>> -----------------------------------------------------------------
>> $ ssh root@1.2.3.4
>> root@1.2.3.4's password:
>> Last login: Wed Aug 26 08:06:49 2009 from X
>> [root@KSTATION ~]# su carlos.andre
>> [carlos.andre@KSTATION root]$ klist
>> klist: No credentials cache found (ticket cache FILE:/tmp/krb5cc_10000)
>>
>>
>> Kerberos 4 ticket cache: /tmp/tkt10000
>> klist: You have no tickets cached
>> [carlos.andre@KSTATION root]$ cd /misc/home/carlos.andre
>> bash: cd: /misc/home/carlos.andre: Permission denied
>> [carlos.andre@KSTATION root]$
>> -----------------------------------------------------------------
>> [--OK--]
>>
>>
>> SESSION 2:
>> -----------------------------------------------------------------
>> $ ssh carlos.andre@1.2.3.4
>> carlos.andre@1.2.3.4's password:
>> Last login: Wed Aug 26 08:01:33 2009 from X
>> [carlos.andre@KSTATION ~]$ klist
>> Ticket cache: FILE:/tmp/krb5cc_10000_PPLMqF
>> Default principal: carlos.andre@X.BR
>>
>> Valid starting     Expires            Service principal
>> 08/26/09 08:30:12  08/26/09 18:30:12  krbtgt/X.BR@X.BR
>>        renew until 08/26/09 08:30:12
>>
>>
>> Kerberos 4 ticket cache: /tmp/tkt10000
>> klist: You have no tickets cached
>> [carlos.andre@KSTATION ~]$ cd /misc/home/carlos.andre
>> [carlos.andre@KSTATION carlos.andre]$ ls -la
>> total 8
>> drwxrwx--- 2 carlos.andre users 4096 Aug 21 09:04 .
>> drwxr-xr-x 3 root         root               0 Aug 26 08:30 ..
>> [carlos.andre@KSTATION carlos.andre]$
>> -----------------------------------------------------------------
>> [--OK--]
>>
>>
>> NOW BACK TO SESSION 1:
>> -----------------------------------------------------------------
>> [carlos.andre@KSTATION root]$ cd /misc/home/carlos.andre
>> [carlos.andre@KSTATION carlos.andre]$ ls -la
>> total 8
>> drwxrwx--- 2 carlos.andre users 4096 Aug 21 09:04 .
>> drwxr-xr-x 3 root         root               0 Aug 26 08:30 ..
>> [carlos.andre@KSTATION carlos.andre]$ klist
>> klist: No credentials cache found (ticket cache FILE:/tmp/krb5cc_10000)
>>
>>
>> Kerberos 4 ticket cache: /tmp/tkt10000
>> klist: You have no tickets cached
>> [carlos.andre@KSTATION carlos.andre]$
>> -----------------------------------------------------------------
>> [WTF!?!?]
>>
>> Then, if I log on someone machine, local root user (and 'su' to my
>> user) will have access to my files like NFS without Kerberos?? This
>> behavior is "correct" or it's a bug?
>> And more strange it's credentials, root 'su'ed to my user doesnt got
>> credentials, but still have access to my files...
>>
>> Or I'm doing something wrong? -_-'
>>
>> Thanks.
>> _______________________________________________
>> NFSv4 mailing list
>> NFSv4@linux-nfs.org
>> http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4
>>
>>
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>



--=20
Le Wang
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
The good man is the friend of all living things.
Gandhi, Mahatma(1869-1948)
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

--001636b2b4774033cb047211dd2b
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

This is the security issue of NFS which exists extensively in NIS directory=
 environment since regular NFS authentication depends on UID and GID.<br>$ =
ypcat password |grep $FOO to get the user FOO&#39;s UID and GID;<br>Local r=
oot of ANY machine in this Directory could create a faked user with FOO&#39=
;s UID and GID through cmd &quot;groupadd&quot; and &quot;useradd&quot;, an=
d then access FOO&#39;s files on any machine.<br>
If Kerberos 5 is applied, this kind of security issue could be solved parti=
ally and limited on the scenario which Ondrej described below.<br>-Le=A0 =
=A0 =A0 <br>=A0<br><br><div class=3D"gmail_quote">On Wed, Aug 26, 2009 at 7=
:51 AM, Ondrej Valousek <span dir=3D"ltr">&lt;<a href=3D"mailto:webserv@s3g=
roup.cz">webserv@s3group.cz</a>&gt;</span> wrote:<br>
<blockquote class=3D"gmail_quote" style=3D"border-left: 1px solid rgb(204, =
204, 204); margin: 0pt 0pt 0pt 0.8ex; padding-left: 1ex;">This issue has al=
ready been discussed on this list.<br>
Local root has access to all credentials stored on that machine and there i=
s nothing you can do with this. You can only tell the user not to log to a =
machine which is already compromised by malicious attacker having root acce=
ss.<br>

Ondrej<br>
<br>
Carlos Andr=E9 wrote:<br>
<blockquote class=3D"gmail_quote" style=3D"border-left: 1px solid rgb(204, =
204, 204); margin: 0pt 0pt 0pt 0.8ex; padding-left: 1ex;">
I got a strange security issue. I logon via SSH or local console with<br>
my user and get a ticket, then if local root su to my user, local root<br>
can access my files.<br>
<br>
I&#39;m using CentOS 5.3:<br>
kernel-2.6.18-128.2.1.el5<br>
krb5-workstation-1.6.1-31.el5_3.3<br>
<br>
<br>
SESSION 1:<br>
-----------------------------------------------------------------<br>
$ ssh <a href=3D"mailto:root@1.2.3.4" target=3D"_blank">root@1.2.3.4</a><br=
>
<a href=3D"mailto:root@1.2.3.4" target=3D"_blank">root@1.2.3.4</a>&#39;s pa=
ssword:<br>
Last login: Wed Aug 26 08:06:49 2009 from X<br>
[root@KSTATION ~]# su carlos.andre<br>
[carlos.andre@KSTATION root]$ klist<br>
klist: No credentials cache found (ticket cache FILE:/tmp/krb5cc_10000)<br>
<br>
<br>
Kerberos 4 ticket cache: /tmp/tkt10000<br>
klist: You have no tickets cached<br>
[carlos.andre@KSTATION root]$ cd /misc/home/carlos.andre<br>
bash: cd: /misc/home/carlos.andre: Permission denied<br>
[carlos.andre@KSTATION root]$<br>
-----------------------------------------------------------------<br>
[--OK--]<br>
<br>
<br>
SESSION 2:<br>
-----------------------------------------------------------------<br>
$ ssh <a href=3D"mailto:carlos.andre@1.2.3.4" target=3D"_blank">carlos.andr=
e@1.2.3.4</a><br>
<a href=3D"mailto:carlos.andre@1.2.3.4" target=3D"_blank">carlos.andre@1.2.=
3.4</a>&#39;s password:<br>
Last login: Wed Aug 26 08:01:33 2009 from X<br>
[carlos.andre@KSTATION ~]$ klist<br>
Ticket cache: FILE:/tmp/krb5cc_10000_PPLMqF<br>
Default principal: <a href=3D"mailto:carlos.andre@X.BR" target=3D"_blank">c=
arlos.andre@X.BR</a><br>
<br>
Valid starting =A0 =A0 Expires =A0 =A0 =A0 =A0 =A0 =A0Service principal<br>
08/26/09 08:30:12 =A008/26/09 18:30:12 =A0krbtgt/<a href=3D"http://X.BR" ta=
rget=3D"_blank">X.BR</a>@<a href=3D"http://X.BR" target=3D"_blank">X.BR</a>=
<br>
 =A0 =A0 =A0 =A0renew until 08/26/09 08:30:12<br>
<br>
<br>
Kerberos 4 ticket cache: /tmp/tkt10000<br>
klist: You have no tickets cached<br>
[carlos.andre@KSTATION ~]$ cd /misc/home/carlos.andre<br>
[carlos.andre@KSTATION carlos.andre]$ ls -la<br>
total 8<br>
drwxrwx--- 2 carlos.andre users 4096 Aug 21 09:04 .<br>
drwxr-xr-x 3 root =A0 =A0 =A0 =A0 root =A0 =A0 =A0 =A0 =A0 =A0 =A0 0 Aug 26=
 08:30 ..<br>
[carlos.andre@KSTATION carlos.andre]$<br>
-----------------------------------------------------------------<br>
[--OK--]<br>
<br>
<br>
NOW BACK TO SESSION 1:<br>
-----------------------------------------------------------------<br>
[carlos.andre@KSTATION root]$ cd /misc/home/carlos.andre<br>
[carlos.andre@KSTATION carlos.andre]$ ls -la<br>
total 8<br>
drwxrwx--- 2 carlos.andre users 4096 Aug 21 09:04 .<br>
drwxr-xr-x 3 root =A0 =A0 =A0 =A0 root =A0 =A0 =A0 =A0 =A0 =A0 =A0 0 Aug 26=
 08:30 ..<br>
[carlos.andre@KSTATION carlos.andre]$ klist<br>
klist: No credentials cache found (ticket cache FILE:/tmp/krb5cc_10000)<br>
<br>
<br>
Kerberos 4 ticket cache: /tmp/tkt10000<br>
klist: You have no tickets cached<br>
[carlos.andre@KSTATION carlos.andre]$<br>
-----------------------------------------------------------------<br>
[WTF!?!?]<br>
<br>
Then, if I log on someone machine, local root user (and &#39;su&#39; to my<=
br>
user) will have access to my files like NFS without Kerberos?? This<br>
behavior is &quot;correct&quot; or it&#39;s a bug?<br>
And more strange it&#39;s credentials, root &#39;su&#39;ed to my user doesn=
t got<br>
credentials, but still have access to my files...<br>
<br>
Or I&#39;m doing something wrong? -_-&#39;<br>
<br>
Thanks.<br>
_______________________________________________<br>
NFSv4 mailing list<br>
<a href=3D"mailto:NFSv4@linux-nfs.org" target=3D"_blank">NFSv4@linux-nfs.or=
g</a><br>
<a href=3D"http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4" target=3D"_=
blank">http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4</a><br>
 =A0<br>
</blockquote>
<br>
--<br>
To unsubscribe from this list: send the line &quot;unsubscribe linux-nfs&qu=
ot; in<br>
the body of a message to <a href=3D"mailto:majordomo@vger.kernel.org" targe=
t=3D"_blank">majordomo@vger.kernel.org</a><br>
More majordomo info at =A0<a href=3D"http://vger.kernel.org/majordomo-info.=
html" target=3D"_blank">http://vger.kernel.org/majordomo-info.html</a><br>
</blockquote></div><br><br clear=3D"all"><br>-- <br>Le Wang<br>~~~~~~~~~~~~=
~~~~~~~~~~~~~~~~~~~~~~~~<br>The good man is the friend of all living things=
.<br>Gandhi, Mahatma(1869-1948)<br>~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~<br>


--001636b2b4774033cb047211dd2b--

--===============2097023403==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFSv4 mailing list
NFSv4@linux-nfs.org
http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4
--===============2097023403==--
