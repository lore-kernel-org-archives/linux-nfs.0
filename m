From: mehta kiran <kiranmehta1981@yahoo.com>
Subject: Re: problem starting rpc.svcgssd for NFSv4
Date: Mon, 14 Mar 2005 07:56:53 -0800 (PST)
Message-ID: <20050314155653.61401.qmail@web51608.mail.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net, Kevin Coffman <kwc@citi.umich.edu>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DArwD-0001yt-Ie
	for nfs@lists.sourceforge.net; Mon, 14 Mar 2005 07:57:01 -0800
Received: from web51608.mail.yahoo.com ([206.190.38.213])
	by sc8-sf-mx2.sourceforge.net with smtp (Exim 4.41)
	id 1DArwB-0005nS-SJ
	for nfs@lists.sourceforge.net; Mon, 14 Mar 2005 07:57:01 -0800
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

Hi Kevin , 
      output of klist -k /etc/krb5.keytab" is

         Keytab name: FILE:/etc/krb5.keytab
         klist: Unsupported key table format version  
         number while starting keytab scan

         These are the different packages
         (and their versions) installed on 
          my machines(RHEL4 GA)

          krb5-workstation-1.3.4-9
          krb5-server-1.3.4-9
          krb5-libs-1.3.4-9
          krbafs-utils-1.2.2-6
          krbafs-devel-1.2.2-6
          krbafs-1.2.2-6
          krb5-auth-dialog-0.2-1
          krb5-devel-1.3.4-9
          pam_krb5-2.1.2-1

thanks,
 --kiran

--- Kevin Coffman <kwc@citi.umich.edu> wrote:
> Hi Kiran,
> What version of Kerberos are you using?
> 
> The error seems to indicate that your keytab is not
> in the expected 
> format.  What does "klist -k /etc/krb5.keytab" show?
> 
> You may also want to get the latest libgssapi and
> librpcsecgss from:
> http://www.citi.umich.edu/projects/nfsv4/linux/
> 
> 
> > Hi , 
> >       I am trying to set up kerberos for NFSv4
> >       All the daemons other than rpc.svcgssd
> start.
> > 
> >       I have krb5kdc and kadmind running on
> (RHEL4)
> >       vcslinux1 system.
> > 
> >       
> >       file /etc/krb5.keytab has following
> contents:
> >      
> >
>
nfs/vcslinux1.vxindia.veritas.com@VXINDIA.VERITAS.COM
> >
>
root/vcslinux1.vxindia.veritas.com@VXINDIA.VERITAS.COM
> > 
> >       #rpc.svcgssd -v -f
> > 
> >       WARNING: unable to locate function 
> >       krb5_gss_internal_release_oid in krb5
> >       mechanism library: there will be problems
> >       if multiple mechanisms are used!
> >       ERROR: GSS-API: error in gss_acquire_cred():
> 
> >       Miscellaneous failure - Unsupported key
> table
> >       format version number unable to obtain root 
> >      (machine) credentials
> >       do you have a keytab entry for   
> >       nfs/<your.host>@<YOUR.REALM> in
> > /etc/krb5.keytab?
> > 
> > 
> > thanks,
> >  --kiran
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
Make Yahoo! your home page 
http://www.yahoo.com/r/hs


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
