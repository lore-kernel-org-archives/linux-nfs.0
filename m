From: Kevin Coffman <kwc@citi.umich.edu>
Subject: Re: problem starting rpc.svcgssd for NFSv4
Date: Mon, 14 Mar 2005 10:45:32 -0500
Message-ID: <20050314154532.ECA421BACA@citi.umich.edu>
References: <20050314133645.26617.qmail@web51604.mail.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net, Kevin Coffman <kwc@citi.umich.edu>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DArlA-0001SC-6z
	for nfs@lists.sourceforge.net; Mon, 14 Mar 2005 07:45:36 -0800
Received: from citi.umich.edu ([141.211.133.111])
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1DArl8-00062G-L1
	for nfs@lists.sourceforge.net; Mon, 14 Mar 2005 07:45:36 -0800
To: mehta kiran <kiranmehta1981@yahoo.com>
In-reply-to: <20050314133645.26617.qmail@web51604.mail.yahoo.com> 
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

Hi Kiran,
What version of Kerberos are you using?

The error seems to indicate that your keytab is not in the expected 
format.  What does "klist -k /etc/krb5.keytab" show?

You may also want to get the latest libgssapi and librpcsecgss from:
http://www.citi.umich.edu/projects/nfsv4/linux/


> Hi , 
>       I am trying to set up kerberos for NFSv4
>       All the daemons other than rpc.svcgssd start.
> 
>       I have krb5kdc and kadmind running on (RHEL4)
>       vcslinux1 system.
> 
>       
>       file /etc/krb5.keytab has following contents:
>      
> nfs/vcslinux1.vxindia.veritas.com@VXINDIA.VERITAS.COM
> root/vcslinux1.vxindia.veritas.com@VXINDIA.VERITAS.COM
> 
>       #rpc.svcgssd -v -f
> 
>       WARNING: unable to locate function 
>       krb5_gss_internal_release_oid in krb5
>       mechanism library: there will be problems
>       if multiple mechanisms are used!
>       ERROR: GSS-API: error in gss_acquire_cred(): 
>       Miscellaneous failure - Unsupported key table
>       format version number unable to obtain root 
>      (machine) credentials
>       do you have a keytab entry for   
>       nfs/<your.host>@<YOUR.REALM> in
> /etc/krb5.keytab?
> 
> 
> thanks,
>  --kiran
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
