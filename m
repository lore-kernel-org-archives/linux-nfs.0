From: mehta kiran <kiranmehta1981@yahoo.com>
Subject: Re: problem mounting using NFSv4 when using -o sec=krb5 option
Date: Thu, 17 Mar 2005 23:43:57 -0800 (PST)
Message-ID: <20050318074358.12947.qmail@web51604.mail.yahoo.com>
References: <38c3c4860503170547ed9e1fc@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Kevin Coffman <kwc@citi.umich.edu>, nfs@lists.sourceforge.net
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DCC9O-0008Ub-QX
	for nfs@lists.sourceforge.net; Thu, 17 Mar 2005 23:44:06 -0800
Received: from web51604.mail.yahoo.com ([206.190.38.209])
	by sc8-sf-mx2.sourceforge.net with smtp (Exim 4.41)
	id 1DCC9N-0007WE-0L
	for nfs@lists.sourceforge.net; Thu, 17 Mar 2005 23:44:06 -0800
To: Suresh Jayaram <sureshjayaram@gmail.com>
In-Reply-To: <38c3c4860503170547ed9e1fc@mail.gmail.com>
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
   I tried with new library.
   libgssapi-0.2 and librpcsecgss-0.4 got installed
   in /usr/local/lib.

   Entry in /etc/gssapi_mech.conf has entry as 
/usr/lib/libgssapi_krb5.so mechglue_internal_krb5_init

   Still i get  error while starting rpc.gssd 

[root@vcslinux6 ~]# rpc.gssd -f -vvv
Using keytab file '/etc/krb5.keytab'
Processing keytab entry for principal
'nfs/vcslinux6.vxindia.veritas.com@VXINDIA.VERITAS.COM'
We will use this entry
(nfs/vcslinux6.vxindia.veritas.com@VXINDIA.VERITAS.COM)
WARNING: Decrypt integrity check failed while getting
initial ticket for principal
'nfs/vcslinux6.vxindia.veritas.com@VXINDIA.VERITAS.COM'
from keytab 'FILE:/etc/krb5.keytab'
ERROR: No usable machine credentials obtained
processing client list


and while mouting it says:
rpc.gssd may not be running...


   May be i am going wrong in procedure of adding 
   entries in keytab.

   Steps.

   On machine runnnig KDC:
   1.create database using kbd5_util create -s.
   2.using "kadmin.local" interface
        addprinc root/admin
        ktadd -e des-cbc-crc:normal -k /tmp/keytab  
        root/admin

        addprinc nfs/vcslinux5.vxindia.veritas.com
        ktadd -e des-cbc-crc:normal -k /tmp/keytab  
        nfs/vcslinux5.vxindia.veritas.com
        
        addprinc nfs/vcslinux6.vxindia.veritas.com
        ktadd -e des-cbc-crc:normal -k /tmp/keytab  
        nfs/vcslinux6.vxindia.veritas.com
   3.At the end do cp /tmp/keytab /etc/krb5.keytab.
   4.Output of klist -k /etc/krb5.keytab 

2 root/admin@VXINDIA.VERITAS.COM
2
nfs/vcslinux6.vxindia.veritas.com@VXINDIA.VERITAS.COM
2
nfs/vcslinux5.vxindia.veritas.com@VXINDIA.VERITAS.COM

   Machine running nfs server(vcslinux5)

   1.create database using kdb5_util create -s
   2. using "kadmin.local" interace create
      entry for nfs/vcslinux5.vxindia.veritas.com
   3.output of klist -k /etc/krb5.keytab   

2
nfs/vcslinux5.vxindia.veritas.com@VXINDIA.VERITAS.COM

   Similarly on machine running nfs client(vcslinux6)
   after making entry using kadmin.local interface  
   for it 
   output of klist -k /etc/krb5.keytab

2
nfs/vcslinux6.vxindia.veritas.com@VXINDIA.VERITAS.COM

On "all" the machine  , /etc/krb.conf
has  foloowing entries for realms and domain_realms
[realms]
 VXINDIA.VERITAS.COM = {
  kdc = vcslinux1.vxindia.veritas.com:88
  admin_server = vcslinux1.vxindia.veritas.com:749
  default_domain = vxindia.veritas.com
 }

[domain_realm]
 .vxindia.veritas.com = VXINDIA.VERITAS.COM
  vxindia.veritas.com = VXINDIA.VERITAS.COM


Did i go wrong anywhere ?

--thanks,
 --kiran


   



--- Suresh Jayaram <sureshjayaram@gmail.com> wrote:

> Hi Kiran,
> 
> Run rpc.gssd also in verbose mode
> >>RPC: AUTH_GSS upcall timed out.
> This means rpc.gssd is not running.
> Check gssapi_mech.conf in client machine also.
> Those Warning messages you can ignore..
> 
> Update your libgssapi and librpcsecgss packages
> (libgssapi-0.2 and
> librpcsecgss-0.4)
> 
> HTH
> Suresh
> 
> 
> On Thu, 17 Mar 2005 04:56:53 -0800 (PST), mehta
> kiran
> <kiranmehta1981@yahoo.com> wrote:
> > one more thing.
> > 
> > On machine running kdc ,
> > 
> >   entry for vcslinux5 is with kvno 3
> >   while entry for vcslinux5 on vcslinux5 is with
> kvno
> >   2 . Is this making a difference
> > 
> > thanks,
> > --kiran
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
> > > > > > > Error in log file on mount
> > > > > > > Mar 16 14:58:43 vcslinux5
> rpc.gssd[4258]:
> > > > > WARNING:
> > > > > > > failed reading uid from krb5 upcall
> pipe:
> > > > > Success
> > > > > > > Mar 16 14:58:43 vcslinux5
> rpc.gssd[4405]:
> > > > > WARNING: Key
> > > > > > > table entry not found while getting
> initial
> 
=== message truncated ===



		
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
