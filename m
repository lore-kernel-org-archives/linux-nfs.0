From: mehta kiran <kiranmehta1981@yahoo.com>
Subject: Re: problem mounting using NFSv4 when using -o sec=krb5  option
Date: Tue, 22 Mar 2005 00:06:37 -0800 (PST)
Message-ID: <20050322080637.79883.qmail@web51607.mail.yahoo.com>
References: <20050322044007.44312.qmail@web51604.mail.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DDePT-0004U2-QG
	for nfs@lists.sourceforge.net; Tue, 22 Mar 2005 00:06:43 -0800
Received: from web51607.mail.yahoo.com ([206.190.38.212])
	by sc8-sf-mx2.sourceforge.net with smtp (Exim 4.41)
	id 1DDePT-0003Ps-4m
	for nfs@lists.sourceforge.net; Tue, 22 Mar 2005 00:06:43 -0800
To: Kevin Coffman <kwc@citi.umich.edu>
In-Reply-To: <20050322044007.44312.qmail@web51604.mail.yahoo.com>
Sender: nfs-admin@lists.sourceforge.net
Errors-To: nfs-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

Hi Kevin , 
    God knows how , but everyting is working fine now.
    I could not figure out why was it failing earlier.
    
    I have one question.
    Is is possible to use common ip to access 
    machines when kerberos is running .i:e
    I want to access system1 with an ip say IP.
    when system1 crashes , i want to start services
    of system1 on system2 but want to access system2
    with same IP.

     what is tried was
     create keys (on machine running KDC) for
     for all machines in my subnet.
     
     After this take an ip and register it with DNS 
     with some name say NFS.domain.
     Create key (on machine running kdc) for
NFS.domain
     For machines those which will run nfs server , 
     ktadd respective machine key + ktadd NFS.domain
     key and copy keytab file to respective machines.
     For all other machines just ktadd respective 
     machine key and copy keytab file to respective 
     machines.
     In short , 
     on machine running nfs server,
     #klist -k /etc/krb5.keytab
      2 nfs/<hostname.domainname>@<realm>
      2 nfs/NFS.domainname@<realm>

     for other machines(nfs clients)
     #klist -k /etc/krb5.keytab
      2 nfs/<hostname.domainname>@<realm>
     
     but when i try to mount exported filesystems
     from nfs client , 
     using 
     #mount -t nfs4 -osec=krb5 NFS.doaminname:/ /share

      Failed to create krb5 context for user with uid
0
      with any credential cache for server 
      NFS.domainname 
 
      Everything works well if genuine server name is 
      used for mounting.Problem arises only when
      (virtual ip) NFS.domainname is used.

   thanks,
 --kiran
     


--- mehta kiran <kiranmehta1981@yahoo.com> wrote:

> Missed one thing.
>  I used kadmin.local to create principals(on machine
> runnnig KDC)
> 
> thanks,
>  --kiran
> --- mehta kiran <kiranmehta1981@yahoo.com> wrote:
> > Hi Kevin , 
> >     I created new database and new principal and 
> >     keytab files.
> > 
> >     Kinit does not accept passowrd for principals
> >     nfs/vcslinux5.vxindia.veritas.com
> >     and
> >     nfs/vcslinux6.vxindia.veritas.com
> > 
> >     Please let me know if i can provide some
> > info(and
> > how) (logs) which can point out the problem
> > 
> > thanks,
> >  --kiran
> > 
> > 
> > 
> > 
> > --- Kevin Coffman <kwc@citi.umich.edu> wrote:
> > > > 
> > > > Hi , 
> > > >              I tried things as directed by
> Trond
> > > in
> > > >     his previous mail and everything seemed to
> > > work
> > > >     fine initally. but when i rebooted system
> , 
> > > >     it started giving error whenever i start
> > > rpc.gssd
> > > >     on client machine.
> > > >     Error is :
> > > > 
> > > > [root@vcslinux6 ~]# Mar 21 14:47:27 vcslinux6
> > > > rpc.gssd[3487]: WARNING: Key table entry not
> > found
> > > > while getting initial ticket for principal
> > > >
> > >
> >
>
'nfs/vcslinux6.vxindia.veritas.com@VXINDIA.VERITAS.COM'
> > > > from keytab 'FILE:/etc/krb5.keytab'
> > > > Mar 21 14:47:27 vcslinux6 rpc.gssd[3487]:
> ERROR:
> > > No
> > > > usable machine credentials obtained
> > > >   
> > > >      
> > > > while #klist -k /etc/krb5.keytab gives
> > > > 2
> > > >
> > >
> >
>
nfs/vcslinux6.vxindia.veritas.com@VXINDIA.VERITAS.COM
> > > 
> > > 
> > > I'm confused by this, but I do not know what to
> > look
> > > for.
> > > 
> > > 
> > > > I even tried by recreating kerberos database
> but
> > > in
> > > > vain. I still get the same error.
> > > 
> > > If you recreated the Kerberos database, you need
> > to
> > > create new principals and keytab files.  Did you
> > do
> > > this?
> > > 
> > > > I observed one more thing.
> > > > Whenver i create principal(other then
> > root/admin)
> > > ,
> > > > passwords i enter for them during their
> creation
> > > > are not accepted by kinit.
> > > 
> > > This is also strange and _might_ be related. 
> How
> > > are
> > > you creating the principals -- using kadmin or
> > > kadmin.local?
> > > Which principals are you referring to here?
> > > 
> > > > 
> > > > Please let me know where i went wrong.
> > > > 
> > > > --thanks,
> > > >  --kiran
> > > 
> > > 
> > 
> > __________________________________________________
> > Do You Yahoo!?
> > Tired of spam?  Yahoo! Mail has the best spam
> > protection around 
> > http://mail.yahoo.com 
> > 
> > 
> >
>
-------------------------------------------------------
> > SF email is sponsored by - The IT Product Guide
> > Read honest & candid reviews on hundreds of IT
> > Products from real users.
> > Discover which products truly live up to the hype.
> > Start reading now.
> >
>
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
> > _______________________________________________
> > NFS maillist  -  NFS@lists.sourceforge.net
> > https://lists.sourceforge.net/lists/listinfo/nfs
> > 
> 
> __________________________________________________
> Do You Yahoo!?
> Tired of spam?  Yahoo! Mail has the best spam
> protection around 
> http://mail.yahoo.com 
> 
> 
>
-------------------------------------------------------
> SF email is sponsored by - The IT Product Guide
> Read honest & candid reviews on hundreds of IT
> Products from real users.
> Discover which products truly live up to the hype.
> Start reading now.
>
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
> _______________________________________________
> NFS maillist  -  NFS@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/nfs
> 



		
__________________________________ 
Do you Yahoo!? 
Yahoo! Small Business - Try our new resources site!
http://smallbusiness.yahoo.com/resources/ 


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
