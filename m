From: mehta kiran <kiranmehta1981@yahoo.com>
Subject: Re: problem mounting using NFSv4 when using -o sec=krb5  option
Date: Wed, 16 Mar 2005 06:36:47 -0800 (PST)
Message-ID: <20050316143647.52000.qmail@web51607.mail.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DBZds-0001A9-N8
	for nfs@lists.sourceforge.net; Wed, 16 Mar 2005 06:37:00 -0800
Received: from web51607.mail.yahoo.com ([206.190.38.212])
	by sc8-sf-mx1.sourceforge.net with smtp (Exim 4.41)
	id 1DBZdr-0000H1-4l
	for nfs@lists.sourceforge.net; Wed, 16 Mar 2005 06:37:00 -0800
To: Kevin Coffman <kwc@citi.umich.edu>
In-Reply-To: 6667
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

Hi , 
    Yes , module rpcsec_gss_krb5 is loaded.
    RHEL GA is installed on my machines
thanks,
 --kiran
--- Kevin Coffman <kwc@citi.umich.edu> wrote:
> Is your server's kernel built with
> CONFIG_RPCSEC_GSS_KRB5?
> If it is built as a module, is the module loaded?
> 
> 
> > Hi , 
> >     I have exported filesystems to client but
> >     when client mounts using
> >     mount -t nfs4 -o sec=krb5  vcslinux1:/ /share 
>  
> >     it gets  error :
> > -------------
> >      kernel: RPC: Couldn't create auth handle
> (flavor 
> >      390003)
> >      kernel: NFS: cannot create RPC client.
> >      rpc.idmapd: open
> >      (/var/lib/nfs/rpc_pipefs/nfs/clnt23)
> > --------------
> > 
> >      nfs sevver is runnnig on vcslinux1 system and
> 
> >      client on vcslinux5
> >      
> >     Ouput of klist -k /etc/krb5.keytab on server
> > 
> > 3
> >
>
nfs/vcslinux1.vxindia.veritas.com@VXINDIA.VERITAS.COM
> > 2 root/admin@VXINDIA.VERITAS.COM
> > 2
> >
>
root/vcslinux5.vxindia.veritas.com@VXINDIA.VERITAS.COM
> >    3
> >
>
ftp/vcslinux1.vxindia.veritas.com@VXINDIA.VERITAS.COM
> > 
> > 
> > All nfs daemons are running. rpc.svcgssd and
> > rpc.idmapd is also runnnig.
> > 
> > On client side rpc.gssd is runnnig with -m option.
> > 
> > 
> > thanks,
> >  --kiran
> > 
> > 
> > 
> > 
> > 		
> > __________________________________ 
> > Do you Yahoo!? 
> > Yahoo! Small Business - Try our new resources
> site!
> > http://smallbusiness.yahoo.com/resources/ 
> > 
> > 
> >
>
-------------------------------------------------------
> > SF email is sponsored by - The IT Product Guide
> > Read honest & candid reviews on hundreds of IT
> Products from real users.
> > Discover which products truly live up to the hype.
> Start reading now.
> >
>
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
> > _______________________________________________
> > NFS maillist  -  NFS@lists.sourceforge.net
> > https://lists.sourceforge.net/lists/listinfo/nfs
> 
> 
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
