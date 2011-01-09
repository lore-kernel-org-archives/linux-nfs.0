Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from nm3.bullet.mail.sp2.yahoo.com ([98.139.91.73]:43801 "HELO
	nm3.bullet.mail.sp2.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751077Ab1AIMAB convert rfc822-to-8bit
	(ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 9 Jan 2011 07:00:01 -0500
Message-ID: <187328.13539.qm@web111708.mail.gq1.yahoo.com>
References: <965737.12090.qm@web111718.mail.gq1.yahoo.com>  <1294565607.30270.14.camel@ramone>  <874334.779.qm@web111720.mail.gq1.yahoo.com> <1294573274.30270.35.camel@ramone>
Date: Sun, 9 Jan 2011 03:59:58 -0800 (PST)
From: Mahmood Naderan <nt_mahmood@yahoo.com>
Subject: Re: Problem with sharing /home
To: nfs <linux-nfs@vger.kernel.org>
In-Reply-To: <1294573274.30270.35.camel@ramone>
Content-Type: text/plain; charset=iso-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Thanks for that. I changed the UID and GID for users who have conflict with each 
other. 

One more question. If I add a new user on server, can he ssh to the worker 
without problem?

Thanks, 
// Naderan *Mahmood;



----- Original Message ----
From: Daniel Stodden <daniel.stodden@citrix.com>
To: Mahmood Naderan <nt_mahmood@yahoo.com>
Cc: nfs <linux-nfs@vger.kernel.org>
Sent: Sun, January 9, 2011 3:11:14 PM
Subject: Re: Problem with sharing /home

On Sun, 2011-01-09 at 04:46 -0500, Mahmood Naderan wrote:
> >Edit passwd andgroup to fix it.
> I forgot to ask should I edit those files on server or worker?

Ideally on the worker.

The reason is that wherever you have to change the user account on the
server, you will need to recursively fix the permissions on her home
directory. That's more work. If necessary, check your favorite unix
manual for details.

See 'man 5 passwd' for info on the passwd file.

Daniel

> // Naderan *Mahmood;
> 
> 
> 
> ----- Original Message ----
> From: Daniel Stodden <daniel.stodden@citrix.com>
> To: Mahmood Naderan <nt_mahmood@yahoo.com>
> Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
> Sent: Sun, January 9, 2011 1:03:27 PM
> Subject: Re: Problem with sharing /home
> 
> 
> User names are meaningless to the filesystem. Numbers matter. Make sure
> that the name->uid map is identical in all passwd files.
> 
> In the case below, user1 can't write to /home/user1 because on worker
> she's got a different uid than on server. Likewise, user3 there appears
> to own /home/user1 because the uid in question was given to user3.
> 
> Try the 'id' and 'ls -n' commands to figure it out. Edit passwd and
> group to fix it.
> 
> Daniel
> 
> On Sun, 2011-01-09 at 02:41 -0500, Mahmood Naderan wrote:
> > Hi,
> > I have a server (192.168.1.1) and worker (192.168.1.2) stations and want to 
> > share /home which is belong to the server. This is the content of my 
> > /etc/exports:
> > /home                192.168.1.2(rw,sync,no_root_squash)
> > 
> > Before sharing, the list of users on both stations are:
> > server: root, mahmood, user1, user2
> > worker: root, mahmood, user3, user4
> > 
> > As you can see two users are common. Then I opened /etc/fstab on worker and 
> > commnet the original /home line and added this line:
> > server:/home  /home  nfs defaults 0 0
> >  
> > Then I ran "sudo exportfs -a" on server and "sudo mount -a" on the worker. 
> > Please look at the output of "ls -l" command on both server and worker:
> > mahmood@server:home$ ls -l
> > total 36
> > drwxr-xr-x 28 user1      users    4096 2011-01-08 21:49 user1
> > drwxr-xr-x  4 user2        users    4096 2011-01-08 21:55 user2
> > drwx------  2 root      root    16384 2010-10-24 17:23 lost+found
> > drwxr-xr-x 26 mahmood    mahmood  4096 2011-01-09 10:49 mahmood
> > 
> > mahmood@worker:home$ ls -l
> > total 36
> > drwxr-xr-x  4 user3  users    4096 2011-01-08 21:55 user1
> > drwxr-xr-x  9 user4 users    4096 2011-01-08 23:05 user2
> > drwx------  2 root    root    16384 2010-10-24 17:23 lost+found
> > drwxr-xr-x 26 mahmood mahmood  4096 2011-01-09 10:49 mahmood
> > drwxrwxrwx  5 root    root    4096 2011-01-05 21:27 shared
> > 
> > As you can see, the permission of user1 and user2 home direcoties are granted 
>
> >to 
> >
> > user3 and user4. But since "mahmood" and "root" have separate account on both 
>
> > stations, there is no problem with their access. 
> > 
> >  
> > The effect of this anomaly is that when user1 want to ssh from server to 
> >wroker, 
> >
> > he can not write anything in his home direcotry:
> > user1@server:~$ mkdir a
> > user1@server:~$ ssh worker
> > enter password....
> > user1@worker:~$ mkdir b
> > mkdir: cannot create directory `b': Permission denied
> > user1@worker:~$
> > 
> > How can I fix that?
> > 
> > Thanks,
> > // Naderan *Mahmood;
> > 
> > 
> >      
> > --
> > To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> > the body of a message to majordomo@vger.kernel.org
> > More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
> 
>      
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html


      
