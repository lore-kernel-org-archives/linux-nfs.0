From: Kevin Coffman <kwc@citi.umich.edu>
Subject: Re: problem mounting using NFSv4 when using -o sec=krb5
 option
Date: Wed, 16 Mar 2005 09:34:15 -0500
Message-ID: <20050316143415.9BA2B1BADE@citi.umich.edu>
References: <20050316133908.96924.qmail@web51608.mail.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DBZbG-00013J-Tn
	for nfs@lists.sourceforge.net; Wed, 16 Mar 2005 06:34:18 -0800
Received: from citi.umich.edu ([141.211.133.111])
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1DBZbF-0008Qz-6P
	for nfs@lists.sourceforge.net; Wed, 16 Mar 2005 06:34:18 -0800
To: mehta kiran <kiranmehta1981@yahoo.com>
In-reply-to: <20050316133908.96924.qmail@web51608.mail.yahoo.com> 
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

Is your server's kernel built with CONFIG_RPCSEC_GSS_KRB5?
If it is built as a module, is the module loaded?


> Hi , 
>     I have exported filesystems to client but
>     when client mounts using
>     mount -t nfs4 -o sec=krb5  vcslinux1:/ /share   
>     it gets  error :
> -------------
>      kernel: RPC: Couldn't create auth handle (flavor 
>      390003)
>      kernel: NFS: cannot create RPC client.
>      rpc.idmapd: open
>      (/var/lib/nfs/rpc_pipefs/nfs/clnt23)
> --------------
> 
>      nfs sevver is runnnig on vcslinux1 system and 
>      client on vcslinux5
>      
>     Ouput of klist -k /etc/krb5.keytab on server
> 
> 3
> nfs/vcslinux1.vxindia.veritas.com@VXINDIA.VERITAS.COM
> 2 root/admin@VXINDIA.VERITAS.COM
> 2
> root/vcslinux5.vxindia.veritas.com@VXINDIA.VERITAS.COM
>    3
> ftp/vcslinux1.vxindia.veritas.com@VXINDIA.VERITAS.COM
> 
> 
> All nfs daemons are running. rpc.svcgssd and
> rpc.idmapd is also runnnig.
> 
> On client side rpc.gssd is runnnig with -m option.
> 
> 
> thanks,
>  --kiran
> 
> 
> 
> 
> 		
> __________________________________ 
> Do you Yahoo!? 
> Yahoo! Small Business - Try our new resources site!
> http://smallbusiness.yahoo.com/resources/ 
> 
> 
> -------------------------------------------------------
> SF email is sponsored by - The IT Product Guide
> Read honest & candid reviews on hundreds of IT Products from real users.
> Discover which products truly live up to the hype. Start reading now.
> http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
> _______________________________________________
> NFS maillist  -  NFS@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/nfs




-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
