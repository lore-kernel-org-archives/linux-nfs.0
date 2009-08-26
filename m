From: =?ISO-8859-1?Q?Carlos_Andr=E9?= <candrecn@gmail.com>
Subject: Kerberos+NFSv4: Security - Multiple sessions with same user. One
	ticket for all?
Date: Wed, 26 Aug 2009 08:46:37 -0300
Message-ID: <f6ce31e30908260446g534bb70bxd742e35141ae99c1@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: NFS list <linux-nfs@vger.kernel.org>,
	Linux NFSv4 mailing list <nfsv4@linux-nfs.org>
Return-path: <nfsv4-bounces@linux-nfs.org>
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

I got a strange security issue. I logon via SSH or local console with
my user and get a ticket, then if local root su to my user, local root
can access my files.

I'm using CentOS 5.3:
kernel-2.6.18-128.2.1.el5
krb5-workstation-1.6.1-31.el5_3.3


SESSION 1:
-----------------------------------------------------------------
$ ssh root@1.2.3.4
root@1.2.3.4's password:
Last login: Wed Aug 26 08:06:49 2009 from X
[root@KSTATION ~]# su carlos.andre
[carlos.andre@KSTATION root]$ klist
klist: No credentials cache found (ticket cache FILE:/tmp/krb5cc_10000)


Kerberos 4 ticket cache: /tmp/tkt10000
klist: You have no tickets cached
[carlos.andre@KSTATION root]$ cd /misc/home/carlos.andre
bash: cd: /misc/home/carlos.andre: Permission denied
[carlos.andre@KSTATION root]$
-----------------------------------------------------------------
[--OK--]


SESSION 2:
-----------------------------------------------------------------
$ ssh carlos.andre@1.2.3.4
carlos.andre@1.2.3.4's password:
Last login: Wed Aug 26 08:01:33 2009 from X
[carlos.andre@KSTATION ~]$ klist
Ticket cache: FILE:/tmp/krb5cc_10000_PPLMqF
Default principal: carlos.andre@X.BR

Valid starting     Expires            Service principal
08/26/09 08:30:12  08/26/09 18:30:12  krbtgt/X.BR@X.BR
        renew until 08/26/09 08:30:12


Kerberos 4 ticket cache: /tmp/tkt10000
klist: You have no tickets cached
[carlos.andre@KSTATION ~]$ cd /misc/home/carlos.andre
[carlos.andre@KSTATION carlos.andre]$ ls -la
total 8
drwxrwx--- 2 carlos.andre users 4096 Aug 21 09:04 .
drwxr-xr-x 3 root         root               0 Aug 26 08:30 ..
[carlos.andre@KSTATION carlos.andre]$
-----------------------------------------------------------------
[--OK--]


NOW BACK TO SESSION 1:
-----------------------------------------------------------------
[carlos.andre@KSTATION root]$ cd /misc/home/carlos.andre
[carlos.andre@KSTATION carlos.andre]$ ls -la
total 8
drwxrwx--- 2 carlos.andre users 4096 Aug 21 09:04 .
drwxr-xr-x 3 root         root               0 Aug 26 08:30 ..
[carlos.andre@KSTATION carlos.andre]$ klist
klist: No credentials cache found (ticket cache FILE:/tmp/krb5cc_10000)


Kerberos 4 ticket cache: /tmp/tkt10000
klist: You have no tickets cached
[carlos.andre@KSTATION carlos.andre]$
-----------------------------------------------------------------
[WTF!?!?]

Then, if I log on someone machine, local root user (and 'su' to my
user) will have access to my files like NFS without Kerberos?? This
behavior is "correct" or it's a bug?
And more strange it's credentials, root 'su'ed to my user doesnt got
credentials, but still have access to my files...

Or I'm doing something wrong? -_-'

Thanks.
