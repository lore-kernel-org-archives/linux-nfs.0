From: mehta kiran <kiranmehta1981@yahoo.com>
Subject: Re: problem mounting using NFSv4 when using -o sec=krb5  option
Date: Thu, 17 Mar 2005 03:59:52 -0800 (PST)
Message-ID: <20050317115952.29291.qmail@web51602.mail.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DBtfT-0000fh-VC
	for nfs@lists.sourceforge.net; Thu, 17 Mar 2005 03:59:59 -0800
Received: from web51602.mail.yahoo.com ([206.190.38.207])
	by sc8-sf-mx1.sourceforge.net with smtp (Exim 4.41)
	id 1DBtfR-0001np-WF
	for nfs@lists.sourceforge.net; Thu, 17 Mar 2005 03:59:59 -0800
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

Hi kevin , 
 I am using RHEL4 GA.
 kernel : 2.6.9-5.EL
 nfs-utils : nfs-utils-1.0.6-46
  
 As per what you told , i have added entries on both
 client and server.

*client:vcslinux6#klist -k /etc/krb5.keytab
2
nfs/vcslinux6.vxindia.veritas.com@VXINDIA.VERITAS.COM

*server:vcslinux5#klist -k /etc/krb5.keytab

2
nfs/vcslinux5.vxindia.veritas.com@VXINDIA.VERITAS.COM


*kdc:vcslinux1#klist -k /etc/krb5.keytab

2 root/admin@VXINDIA.VERITAS.COM
2
nfs/vcslinux1.vxindia.veritas.com@VXINDIA.VERITAS.COM
3
nfs/vcslinux5.vxindia.veritas.com@VXINDIA.VERITAS.COM
2
nfs/vcslinux6.vxindia.veritas.com@VXINDIA.VERITAS.COM

I inserted rpcsec_gss_krb5 module on all machines.
started krb5kdc and kadmind.
started all nfs daemons  , rpc.svcgssd , rpc.idmapd on
server and exported filesystem with proper options.

started rpc.idmapd on client(vcslinux6).
But when i run #rpc.gssd -m -v -f
Mar 17 11:13:03 vcslinux6 kernel: RPC: AUTH_GSS upcall
timed out.
Mar 17 11:13:03 vcslinux6 kernel: Please check user
daemon is running!


in log file:
Using keytab file '/etc/krb5.keytab'
WARNING: Decrypt integrity check failed while getting
initial ticket for principal
'nfs/vcslinux6.vxindia.veritas.com@VXINDIA.VERITAS.COM'
from keytab 'FILE:/etc/krb5.keytab'
ERROR: No usable machine credentials obtained
processing client list

-------
Then i tried making kvno for vcslinux5 (on kdc) = 2
i could not.
[root@vcslinux1 ~]# kadmin
Authenticating as principal
root/admin@VXINDIA.VERITAS.COM with password.
Password for root/admin@VXINDIA.VERITAS.COM:
kadmin:  modprinc -kvno 2
nfs/vcslinux5.vxindia.veritas.com
Principal
"nfs/vcslinux5.vxindia.veritas.com@VXINDIA.VERITAS.COM"
modified.
kadmin:  ktadd -e des-cbc-crc:normal -k /tmp/keytab 
nfs/vcslinux5.vxindia.veritas.com@VXINDIA.VERITAS.COM
Entry for principal
nfs/vcslinux5.vxindia.veritas.com@VXINDIA.VERITAS.COM
with kvno 3, encryption type DES cbc mode with CRC-32
added to keytab WRFILE:/tmp/keytab.

Please let me know where i went wrong .

--- Kevin Coffman <kwc@citi.umich.edu> wrote:
> Also, "failed reading uid from krb5 upcall" and
> "Failed to write error 
> downcall" should not normally happen.  What versions
> of kernel and 
> nfs-utils do you have?
> 
> 
> > > Error in log file on mount 
> > > Mar 16 14:58:43 vcslinux5 rpc.gssd[4258]:
> WARNING:
> > > failed reading uid from krb5 upcall pipe:
> Success
> > > Mar 16 14:58:43 vcslinux5 rpc.gssd[4405]:
> WARNING: Key
> > > table entry not found while getting initial
> ticket for
> > > principal
> > >
>
'nfs/vcslinux1.vxindia.veritas.com@VXINDIA.VERITAS.COM'
> > > from keytab 'FILE:/etc/krb5.keytab'
> > > Mar 16 14:58:43 vcslinux5 rpc.gssd[4405]: ERROR:
> No
> > > usable machine credentials obtained
> > > Mar 16 14:58:43 vcslinux5 rpc.gssd[4405]:
> WARNING:
> > > Failed to obtain machine credentials for
> connection to
> > > server vcslinux1.vxindia.veritas.com
> > > Mar 16 14:59:08 vcslinux5 rpc.gssd[2760]:
> WARNING:
> > > Failed to create krb5 context for user with uid
> 0 with
> > > any credentials cache for server
> > > vcslinux1.vxindia.veritas.com
> > > Mar 16 14:59:08 vcslinux5 rpc.gssd[2760]: Failed
> to
> > > write error downcall!
> > > 
> > > thanks,
> > >  --kiran
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
Yahoo! Mail - now with 250MB free storage. Learn more. 
http://info.mail.yahoo.com/mail_250


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
