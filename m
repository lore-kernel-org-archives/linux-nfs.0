From: mehta kiran <kiranmehta1981@yahoo.com>
Subject: Re: problem mounting using NFSv4 when using -o sec=krb5  option
Date: Tue, 22 Mar 2005 07:41:15 -0800 (PST)
Message-ID: <20050322154116.21290.qmail@web51608.mail.yahoo.com>
References: <20050322153418.29AD91BBA5@citi.umich.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DDlVU-0008RK-2o
	for nfs@lists.sourceforge.net; Tue, 22 Mar 2005 07:41:24 -0800
Received: from web51608.mail.yahoo.com ([206.190.38.213])
	by sc8-sf-mx2.sourceforge.net with smtp (Exim 4.41)
	id 1DDlVS-0000DI-Lc
	for nfs@lists.sourceforge.net; Tue, 22 Mar 2005 07:41:23 -0800
To: Kevin Coffman <kwc@citi.umich.edu>
In-Reply-To: <20050322153418.29AD91BBA5@citi.umich.edu>
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

So this will work sometime later !!!! gr8
Thanks a lot , Kevin

  
--- Kevin Coffman <kwc@citi.umich.edu> wrote:

> The server code is expecting a ticket for
> 'nfs/vcslinux6.vxindia.veritas
> .com', but it is getting a ticket for
> 'nfs/vcsnfs.vxindia.veritas.com'. 
>  This is a limitation of the rpcsec_gss library. 
> This is on my list of 
> things to try and change.
> 
> Kevin
> 
> 
> > Hi Kevin ,
> > 
> >      As you told , kerberos library does reverse
> >      lookup to get hostname to determine the
> >      principal it needs ticket for.
> >      I followed the steps as mentioned in my
> previous
> >      mail so that i can access nfs using same ip
> on
> >      system2 if system1 crashes.
> >      while mounting i used NFS.domainname(entry
> >      i added to DNS : NFS.domainname <virtual_ip>)
> >      As key for NFS.domainname is present on nfs
> >      server shouldn't mount be successful?
> >      
> >       But this is not the case.
> >       Messages on server(vcslinux6)
> >       
> > Mar 22 14:04:08 vcslinux6 rpc.svcgssd[4969]:
> WARNING:
> > gss_accept_sec_context failed
> > Mar 22 14:04:08 vcslinux6 rpc.svcgssd[4969]:
> ERROR:
> > GSS-API: error in handle_nullreq:
> > gss_accept_sec_context(): Miscellaneous failure -
> > Wrong principal in request
> > Mar 22 14:04:08 vcslinux6 rpc.svcgssd[4969]:
> WARNING:
> > failed to write message
> > Mar 22 14:05:01 vcslinux6 crond(pam_unix)[6083]:
> > session opened for user root by (uid=0)
> > 
> > 
> >     Messsages on client (vcslinux5)
> > 
> > [root@vcslinux5 ~]# Mar 22 14:04:49 vcslinux5
> > rpc.gssd[4117]: WARNING: Failed to create krb5
> context
> > for user with uid 0 with any credentials cache for
> > server vcsnfs.vxindia.veritas.com
> > 
> >    Message on KDC(vcslinux1)
> > 
> > Mar 22 14:33:18 vcslinux1 krb5kdc[4134]: AS_REQ (7
> > etypes {18 17 16 23 1 3 2}) 10.212.99.13: ISSUE:
> > authtime 1111482198, etypes {rep=1 tkt=23 ses=16},
> >
>
nfs/vcslinux5.vxindia.veritas.com@VXINDIA.VERITAS.COM
> > for krbtgt/VXINDIA.VERITAS.COM@VXINDIA.VERITAS.COM
> > Mar 22 14:33:41 vcslinux1 krb5kdc[4134]: TGS_REQ
> (7
> > etypes {18 17 16 23 1 3 2}) 10.212.99.13: ISSUE:
> > authtime 1111482198, etypes {rep=16 tkt=1 ses=1},
> >
>
nfs/vcslinux5.vxindia.veritas.com@VXINDIA.VERITAS.COM
> > for
> nfs/vcsnfs.vxindia.veritas.com@VXINDIA.VERITAS.COM
> > Mar 22 14:33:41 vcslinux1 krb5kdc[4134]: TGS_REQ
> (7
> > etypes {18 17 16 23 1 3 2}) 10.212.99.13: ISSUE:
> > authtime 1111482198, etypes {rep=16 tkt=1 ses=1},
> >
>
nfs/vcslinux5.vxindia.veritas.com@VXINDIA.VERITAS.COM
> > for
> nfs/vcsnfs.vxindia.veritas.com@VXINDIA.VERITAS.COM
> > 
> >   
> >  
> > thanks,
> >  --kiran
> > 
> > 
> > 
> >     
> > --- Kevin Coffman <kwc@citi.umich.edu> wrote:
> > 
> > > I'm happy to hear the normal case is working.
> > > 
> > > The Kerberos library code does a reverse lookup
> of
> > > the host it is 
> > > trying to connect to in order to obtain the
> "real"
> > > host name.  It uses 
> > > that name to determine what principal it needs a
> > > ticket for.  It would 
> > > help to see the exact messages from rpc.gssd,
> > > rpc.svcgssd, and from the 
> > > KDC.
> > > 
> > > 
> > > > Hi Kevin , 
> > > >     God knows how , but everyting is working
> fine
> > > now.
> > > >     I could not figure out why was it failing
> > > earlier.
> > > >     
> > > >     I have one question.
> > > >     Is is possible to use common ip to access 
> > > >     machines when kerberos is running .i:e
> > > >     I want to access system1 with an ip say
> IP.
> > > >     when system1 crashes , i want to start
> > > services
> > > >     of system1 on system2 but want to access
> > > system2
> > > >     with same IP.
> > > > 
> > > >      what is tried was
> > > >      create keys (on machine running KDC) for
> > > >      for all machines in my subnet.
> > > >      
> > > >      After this take an ip and register it
> with
> > > DNS 
> > > >      with some name say NFS.domain.
> > > >      Create key (on machine running kdc) for
> > > > NFS.domain
> > > >      For machines those which will run nfs
> server
> > > , 
> > > >      ktadd respective machine key + ktadd
> > > NFS.domain
> > > >      key and copy keytab file to respective
> > > machines.
> > > >      For all other machines just ktadd
> respective 
> > > >      machine key and copy keytab file to
> > > respective 
> > > >      machines.
> > > >      In short , 
> > > >      on machine running nfs server,
> > > >      #klist -k /etc/krb5.keytab
> > > >       2 nfs/<hostname.domainname>@<realm>
> > > >       2 nfs/NFS.domainname@<realm>
> > > > 
> > > >      for other machines(nfs clients)
> > > >      #klist -k /etc/krb5.keytab
> > > >       2 nfs/<hostname.domainname>@<realm>
> > > >      
> > > >      but when i try to mount exported
> filesystems
> > > >      from nfs client , 
> > > >      using 
> > > >      #mount -t nfs4 -osec=krb5
> NFS.doaminname:/
> > > /share
> > > > 
> > > >       Failed to create krb5 context for user
> with
> > > uid
> > > > 0
> > > >       with any credential cache for server 
> > > >       NFS.domainname 
> > > >  
> > > >       Everything works well if genuine server
> name
> > > is 
> > > >       used for mounting.Problem arises only
> when
> > > >       (virtual ip) NFS.domainname is used.
> > > > 
> > > >    thanks,
> > > >  --kiran
> > > >      
> > > > 
> > > > 
> > > > --- mehta kiran <kiranmehta1981@yahoo.com>
> wrote:
> > > > 
> > > > > Missed one thing.
> > > > >  I used kadmin.local to create principals(on
> > > machine
> > > > > runnnig KDC)
> > > > > 
> > > > > thanks,
> > > > >  --kiran
> > > > > --- mehta kiran <kiranmehta1981@yahoo.com>
> > > wrote:
> > > > > > Hi Kevin , 
> > > > > >     I created new database and new
> principal
> > > and 
> > > > > >     keytab files.
> > > > > > 
> > > > > >     Kinit does not accept passowrd for
> > > principals
> > > > > >     nfs/vcslinux5.vxindia.veritas.com
> > > > > >     and
> 
=== message truncated ===



		
__________________________________ 
Do you Yahoo!? 
Yahoo! Small Business - Try our new resources site!
http://smallbusiness.yahoo.com/resources/ 


-------------------------------------------------------
This SF.net email is sponsored by: 2005 Windows Mobile Application Contest
Submit applications for Windows Mobile(tm)-based Pocket PCs or Smartphones
for the chance to win $25,000 and application distribution. Enter today at
http://ads.osdn.com/?ad_id=6882&alloc_id=15148&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
