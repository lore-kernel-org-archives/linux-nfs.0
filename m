From: mehta kiran <kiranmehta1981@yahoo.com>
Subject: Re: problem mounting using NFSv4 when using -o sec=krb5  option
Date: Mon, 21 Mar 2005 07:45:26 -0800 (PST)
Message-ID: <20050321154527.32344.qmail@web51603.mail.yahoo.com>
References: <20050321151111.1C2051BB62@citi.umich.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DDP60-0006S9-2g
	for nfs@lists.sourceforge.net; Mon, 21 Mar 2005 07:45:36 -0800
Received: from web51603.mail.yahoo.com ([206.190.38.208])
	by sc8-sf-mx2.sourceforge.net with smtp (Exim 4.41)
	id 1DDP5x-00055W-AO
	for nfs@lists.sourceforge.net; Mon, 21 Mar 2005 07:45:36 -0800
To: Kevin Coffman <kwc@citi.umich.edu>
In-Reply-To: <20050321151111.1C2051BB62@citi.umich.edu>
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
             I tried things as directed by Trond in
    his previous mail and everything seemed to work
    fine initally. but when i rebooted system , 
    it started giving error whenever i start rpc.gssd
    on client machine.
    Error is :

[root@vcslinux6 ~]# Mar 21 14:47:27 vcslinux6
rpc.gssd[3487]: WARNING: Key table entry not found
while getting initial ticket for principal
'nfs/vcslinux6.vxindia.veritas.com@VXINDIA.VERITAS.COM'
from keytab 'FILE:/etc/krb5.keytab'
Mar 21 14:47:27 vcslinux6 rpc.gssd[3487]: ERROR: No
usable machine credentials obtained
  
     
while #klist -k /etc/krb5.keytab gives
2
nfs/vcslinux6.vxindia.veritas.com@VXINDIA.VERITAS.COM

I even tried by recreating kerberos database but in
vain. I still get the same error.

I observed one more thing.
Whenver i create principal(other then root/admin) ,
passwords i enter for them during their creation
are not accepted by kinit.

Please let me know where i went wrong.

--thanks,
 --kiran








--- Kevin Coffman <kwc@citi.umich.edu> wrote:

> Kiran,
> Sorry, I was away for a few days with bad
> connectivity.
> 
> Each time you run the "ktadd" command to create a
> keytab entry, the key 
> version number (kvno) for that principal is updated.
>  You cannot simply 
> modify the kvno for a principal because the kvno is
> associated with the 
> key.  I'd advise throwing out the keytab on
> vcslinux5 and create a new 
> keytab for that principal.
> 
> 
> P.S.  Here is what the ktadd command does:
> - It generates a new random key value for the
>   principal (with a new key version)
> - It puts this new key into the Kerberos DB,
> replacing
>   any previous key with a lower kvno
> - It puts this new key into the keytab file that was
>   specified
> 
> Therefore, each time you run ktadd, the old keytab
> entry
> becomes obsolete.
> 
> 
>  > one more thing.
> > 
> > On machine running kdc , 
> > 
> >    entry for vcslinux5 is with kvno 3
> >    while entry for vcslinux5 on vcslinux5 is with
> kvno
> >    2 . Is this making a difference
> > 
> > thanks,
> >  --kiran
> > 
> > 
> > 
> > --- Suresh Jayaram <sureshjayaram@gmail.com>
> wrote:
> > 
> > > Hi Kiran,
> > > 
> > > Try running rpc.gssd -f -vvv (really verbose and
> > > foreground) and
> > > rpc.svcgssd -vvv -f
> > > and see why it is failing. I has similar
> problems
> > > with NFSv4, before
> > > updating all my packages (currently available in
> > > CITI website).
> > > 
> > > Possibly the path of libgssapi_krb5.so may not
> be
> > > proper. Check your
> > > /etc/gssapi_mech.conf
> > > 
> > > Basically after installation of all packages,
> you
> > > need to create 2
> > > principals in kdc server; one for server and one
> for
> > > client and
> > > extract them appropriately.
> > > Make sure all three machines are in Timesync and
> > > hostname of them are
> > > resolvable. Run rpc.mountd, rpc.idmapd,
> rpc.svcgssd
> > > and rpc.nfsd in
> > > server and rpc.idmapd and rpc.gssd in client.
> > > 
> > > HTH
> > > Suresh
> > > 
> > > 
> > > On Thu, 17 Mar 2005 03:59:52 -0800 (PST), mehta
> > > kiran
> > > <kiranmehta1981@yahoo.com> wrote:
> > > > Hi kevin ,
> > > > I am using RHEL4 GA.
> > > > kernel : 2.6.9-5.EL
> > > > nfs-utils : nfs-utils-1.0.6-46
> > > > 
> > > > As per what you told , i have added entries on
> > > both
> > > > client and server.
> > > > 
> > > > *client:vcslinux6#klist -k /etc/krb5.keytab
> > > > 2
> > > >
> > >
> >
>
nfs/vcslinux6.vxindia.veritas.com@VXINDIA.VERITAS.COM
> > > > 
> > > > *server:vcslinux5#klist -k /etc/krb5.keytab
> > > > 
> > > > 2
> > > >
> > >
> >
>
nfs/vcslinux5.vxindia.veritas.com@VXINDIA.VERITAS.COM
> > > > 
> > > > *kdc:vcslinux1#klist -k /etc/krb5.keytab
> > > > 
> > > > 2 root/admin@VXINDIA.VERITAS.COM
> > > > 2
> > > >
> > >
> >
>
nfs/vcslinux1.vxindia.veritas.com@VXINDIA.VERITAS.COM
> > > > 3
> > > >
> > >
> >
>
nfs/vcslinux5.vxindia.veritas.com@VXINDIA.VERITAS.COM
> > > > 2
> > > >
> > >
> >
>
nfs/vcslinux6.vxindia.veritas.com@VXINDIA.VERITAS.COM
> > > > 
> > > > I inserted rpcsec_gss_krb5 module on all
> machines.
> > > > started krb5kdc and kadmind.
> > > > started all nfs daemons  , rpc.svcgssd ,
> > > rpc.idmapd on
> > > > server and exported filesystem with proper
> > > options.
> > > > 
> > > > started rpc.idmapd on client(vcslinux6).
> > > > But when i run #rpc.gssd -m -v -f
> > > > Mar 17 11:13:03 vcslinux6 kernel: RPC:
> AUTH_GSS
> > > upcall
> > > > timed out.
> > > > Mar 17 11:13:03 vcslinux6 kernel: Please check
> > > user
> > > > daemon is running!
> > > > 
> > > > in log file:
> > > > Using keytab file '/etc/krb5.keytab'
> > > > WARNING: Decrypt integrity check failed while
> > > getting
> > > > initial ticket for principal
> > > >
> > >
> >
>
'nfs/vcslinux6.vxindia.veritas.com@VXINDIA.VERITAS.COM'
> > > > from keytab 'FILE:/etc/krb5.keytab'
> > > > ERROR: No usable machine credentials obtained
> > > > processing client list
> > > > 
> > > > -------
> > > > Then i tried making kvno for vcslinux5 (on
> kdc) =
> > > 2
> > > > i could not.
> > > > [root@vcslinux1 ~]# kadmin
> > > > Authenticating as principal
> > > > root/admin@VXINDIA.VERITAS.COM with password.
> > > > Password for root/admin@VXINDIA.VERITAS.COM:
> > > > kadmin:  modprinc -kvno 2
> > > > nfs/vcslinux5.vxindia.veritas.com
> > > > Principal
> > > >
> > >
> >
>
"nfs/vcslinux5.vxindia.veritas.com@VXINDIA.VERITAS.COM"
> > > > modified.
> > > > kadmin:  ktadd -e des-cbc-crc:normal -k
> > > /tmp/keytab
> > > >
> > >
> >
>
nfs/vcslinux5.vxindia.veritas.com@VXINDIA.VERITAS.COM
> > > > Entry for principal
> > > >
> > >
> >
>
nfs/vcslinux5.vxindia.veritas.com@VXINDIA.VERITAS.COM
> > > > with kvno 3, encryption type DES cbc mode with
> > > CRC-32
> > > > added to keytab WRFILE:/tmp/keytab.
> > > > 
> > > > Please let me know where i went wrong .
> > > > 
> > > > --- Kevin Coffman <kwc@citi.umich.edu> wrote:
> > > > > Also, "failed reading uid from krb5 upcall"
> and
> > > > > "Failed to write error
> > > > > downcall" should not normally happen.  What
> > > versions
> > > > > of kernel and
> > > > > nfs-utils do you have?
> > > > >
> > > > >
> 
=== message truncated ===


__________________________________________________
Do You Yahoo!?
Tired of spam?  Yahoo! Mail has the best spam protection around 
http://mail.yahoo.com 


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
