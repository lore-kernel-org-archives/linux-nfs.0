From: Kevin Coffman <kwc@citi.umich.edu>
Subject: Re: problem mounting using NFSv4 when using -o sec=krb5
 option
Date: Wed, 16 Mar 2005 11:12:23 -0500
Message-ID: <20050316161223.0C5A31BADE@citi.umich.edu>
References: <20050316154052.19953.qmail@web51602.mail.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Trond Myklebust <trond.myklebust@fys.uio.no>,
	nfs@lists.sourceforge.net
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DBb8D-0006qp-TF
	for nfs@lists.sourceforge.net; Wed, 16 Mar 2005 08:12:25 -0800
Received: from citi.umich.edu ([141.211.133.111])
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1DBb8C-0002vx-2E
	for nfs@lists.sourceforge.net; Wed, 16 Mar 2005 08:12:25 -0800
To: mehta kiran <kiranmehta1981@yahoo.com>
In-reply-to: <20050316154052.19953.qmail@web51602.mail.yahoo.com> 
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

A keytab hold's a machine's keys.  Not keys to talk to other servers.  
(Those are obtained from the KDC.)

The client machine, vcslinux5, should have a keytab entry for:
	nfs/vcslinux5.veritas.com@VXINDIA.VERITAS.COM

The server machine, vcslinux1, should have a keytab entry for:
	nfs/vcslinux1.veritas.com@VXINDIA.VERITAS.COM

The key version number of the key in the keytab (the number listed in 
the output of klist -k) must match the key version number of the entry 
in the Kerberos database.

 
> Hi , 
>   Client machine is vcslinux5 . I added entry for
>   nfs/vcslinux5.... to /etc/krb5.keytab on server.
> 
>   I copied same keytab file to client side.Is this ok?
> 
>   output of klist -k /etc/krb5.keytab on server
>  3 nfs/vcslinux5.veritas.com@VXINDIA.VERITAS.COM
>    3
> nfs/vcslinux1.vxindia.veritas.com@VXINDIA.VERITAS.COM
>    2 root/admin@VXINDIA.VERITAS.COM
>    2
> root/vcslinux5.vxindia.veritas.com@VXINDIA.VERITAS.COM
>    3
> root/vcslinux5.vxindia.veritas.com@VXINDIA.VERITAS.COM
>    2
> ftp/vcslinux1.vxindia.veritas.com@VXINDIA.VERITAS.COM
>    3
> nfs/vcslinux5.vxindia.veritas.com@VXINDIA.VERITAS.COM
> 
> 
> 
> Error in log file on mount 
> Mar 16 14:58:43 vcslinux5 rpc.gssd[4258]: WARNING:
> failed reading uid from krb5 upcall pipe: Success
> Mar 16 14:58:43 vcslinux5 rpc.gssd[4405]: WARNING: Key
> table entry not found while getting initial ticket for
> principal
> 'nfs/vcslinux1.vxindia.veritas.com@VXINDIA.VERITAS.COM'
> from keytab 'FILE:/etc/krb5.keytab'
> Mar 16 14:58:43 vcslinux5 rpc.gssd[4405]: ERROR: No
> usable machine credentials obtained
> Mar 16 14:58:43 vcslinux5 rpc.gssd[4405]: WARNING:
> Failed to obtain machine credentials for connection to
> server vcslinux1.vxindia.veritas.com
> Mar 16 14:59:08 vcslinux5 rpc.gssd[2760]: WARNING:
> Failed to create krb5 context for user with uid 0 with
> any credentials cache for server
> vcslinux1.vxindia.veritas.com
> Mar 16 14:59:08 vcslinux5 rpc.gssd[2760]: Failed to
> write error downcall!
> 
> thanks,
>  --kiran
>   
> --- Trond Myklebust <trond.myklebust@fys.uio.no>
> wrote:
> 
> > on den 16.03.2005 Klokka 06:47 (-0800) skreiv mehta
> > kiran:
> > > I rebooted the machine due to some problem.
> > > That problem has vanished but i get following
> > message
> > > 
> > > Mar 16 14:04:02 vcslinux5 rpc.gssd[2760]: WARNING:
> > > Failed to obtain machine credentials for
> > connection to
> > > server vcslinux1.vxindia.veritas.com
> > > Mar 16 14:04:02 vcslinux5 rpc.gssd[2760]: WARNING:
> > > failed reading uid from krb5 upcall pipe: Success
> > > Mar 16 14:04:02 vcslinux5 rpc.gssd[4405]: WARNING:
> > Key
> > > table entry not found while getting initial ticket
> > for
> > > principal
> > >
> >
> 'nfs/vcslinux1.vxindia.veritas.com@VXINDIA.VERITAS.COM'
> > > from keytab 'FILE:/etc/krb5.keytab'
> > > Mar 16 14:04:02 vcslinux5 rpc.gssd[4405]: ERROR:
> > No
> > > usable machine credentials obtained
> > 
> > So what is the name of your client? It looks like
> > your keytab file has a
> > credential for nfs/vcslinux1, but the syslog entries
> > above appear to
> > refer to vcslinux5.
> > 
> > If the client name is vcslinux5, then the credential
> > in the keytab
> > should be
> >
> nfs/vcslinux5.vxindia.veritas.com@VXINDIA.VERITAS.COM
> > 
> > 
> > Cheers,
> >   Trond
> > 
> > 
> > > --- mehta kiran <kiranmehta1981@yahoo.com> wrote:
> > > > Hi , 
> > > >     Yes , module rpcsec_gss_krb5 is loaded.
> > > >     RHEL GA is installed on my machines
> > > > thanks,
> > > >  --kiran
> > > > --- Kevin Coffman <kwc@citi.umich.edu> wrote:
> > > > > Is your server's kernel built with
> > > > > CONFIG_RPCSEC_GSS_KRB5?
> > > > > If it is built as a module, is the module
> > loaded?
> > > > > 
> > > > > 
> > > > > > Hi , 
> > > > > >     I have exported filesystems to client
> > but
> > > > > >     when client mounts using
> > > > > >     mount -t nfs4 -o sec=krb5  vcslinux1:/
> > > > /share 
> > > > >  
> > > > > >     it gets  error :
> > > > > > -------------
> > > > > >      kernel: RPC: Couldn't create auth
> > handle
> > > > > (flavor 
> > > > > >      390003)
> > > > > >      kernel: NFS: cannot create RPC client.
> > > > > >      rpc.idmapd: open
> > > > > >      (/var/lib/nfs/rpc_pipefs/nfs/clnt23)
> > > > > > --------------
> > > > > > 
> > > > > >      nfs sevver is runnnig on vcslinux1
> > system
> > > > and
> > > > > 
> > > > > >      client on vcslinux5
> > > > > >      
> > > > > >     Ouput of klist -k /etc/krb5.keytab on
> > server
> > > > > > 
> > > > > > 3
> > > > > >
> > > > >
> > > >
> > >
> >
> nfs/vcslinux1.vxindia.veritas.com@VXINDIA.VERITAS.COM
> > > > > > 2 root/admin@VXINDIA.VERITAS.COM
> > > > > > 2
> > > > > >
> > > > >
> > > >
> > >
> >
> root/vcslinux5.vxindia.veritas.com@VXINDIA.VERITAS.COM
> > > > > >    3
> > > > > >
> > > > >
> > > >
> > >
> >
> ftp/vcslinux1.vxindia.veritas.com@VXINDIA.VERITAS.COM
> > > > > > 
> > > > > > 
> > > > > > All nfs daemons are running. rpc.svcgssd and
> > > > > > rpc.idmapd is also runnnig.
> > > > > > 
> > > > > > On client side rpc.gssd is runnnig with -m
> > > > option.
> > > > > > 
> > > > > > 
> > > > > > thanks,
> > > > > >  --kiran
> > > > > > 
> > > > > > 
> > > > > > 
> > > > > > 
> > > > > > 		
> > > > > > __________________________________ 
> > > > > > Do you Yahoo!? 
> > > > > > Yahoo! Small Business - Try our new
> > resources
> > > > > site!
> > > > > > http://smallbusiness.yahoo.com/resources/ 
> > > > > > 
> > > > > > 
> > > > > >
> > > > >
> > > >
> > >
> >
> -------------------------------------------------------
> > > > > > SF email is sponsored by - The IT Product
> > Guide
> > > > > > Read honest & candid reviews on hundreds of
> > IT
> > > > > Products from real users.
> > > > > > Discover which products truly live up to the
> > > > hype.
> > > > > Start reading now.
> > > > > >
> > > > >
> > > >
> > >
> >
> http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
> > > > > >
> > _______________________________________________
> > > > > > NFS maillist  -  NFS@lists.sourceforge.net
> > > > > >
> > https://lists.sourceforge.net/lists/listinfo/nfs
> > > > > 
> > > > > 
> > > > > 
> > > > 
> > > > 
> > > > 		
> > > > __________________________________ 
> > > > Do you Yahoo!? 
> > > > Yahoo! Small Business - Try our new resources
> > site!
> > > > http://smallbusiness.yahoo.com/resources/ 
> > > > 
> > > > 
> > > >
> > >
> >
> -------------------------------------------------------
> > > > SF email is sponsored by - The IT Product Guide
> > > > Read honest & candid reviews on hundreds of IT
> > > > Products from real users.
> > > > Discover which products truly live up to the
> > hype.
> > > > Start reading now.
> > > >
> > >
> >
> http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
> > > > _______________________________________________
> > > > NFS maillist  -  NFS@lists.sourceforge.net
> > > > https://lists.sourceforge.net/lists/listinfo/nfs
> > > > 
> > > 
> > > __________________________________________________
> > > Do You Yahoo!?
> > > Tired of spam?  Yahoo! Mail has the best spam
> > protection around 
> > > http://mail.yahoo.com 
> > > 
> > > 
> > >
> >
> -------------------------------------------------------
> > > SF email is sponsored by - The IT Product Guide
> > > Read honest & candid reviews on hundreds of IT
> > Products from real users.
> > > Discover which products truly live up to the hype.
> > Start reading now.
> > >
> >
> http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
> > > _______________________________________________
> > > NFS maillist  -  NFS@lists.sourceforge.net
> > > https://lists.sourceforge.net/lists/listinfo/nfs
> > -- 
> > Trond Myklebust <trond.myklebust@fys.uio.no>
> > 
> > 
> 
> 
> __________________________________________________
> Do You Yahoo!?
> Tired of spam?  Yahoo! Mail has the best spam protection around 
> http://mail.yahoo.com 




-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
