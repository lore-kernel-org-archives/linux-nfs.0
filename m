From: Kevin Coffman <kwc@citi.umich.edu>
Subject: Re: problem mounting using NFSv4 when using -o sec=krb5
 option
Date: Tue, 22 Mar 2005 09:05:21 -0500
Message-ID: <20050322140521.2A8391BBB3@citi.umich.edu>
References: <20050322041335.35676.qmail@web51604.mail.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DDk0a-00042q-OO
	for nfs@lists.sourceforge.net; Tue, 22 Mar 2005 06:05:24 -0800
Received: from citi.umich.edu ([141.211.133.111])
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1DDk0Y-0005tC-2E
	for nfs@lists.sourceforge.net; Tue, 22 Mar 2005 06:05:24 -0800
To: mehta kiran <kiranmehta1981@yahoo.com>
In-reply-to: <20050322041335.35676.qmail@web51604.mail.yahoo.com> 
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

If you create a principal using a password, you should be able to 
authenticate as that pricipal using that password.  However, once you 
do a ktadd for that principal the password will no longer work.  See my 
previous message about what ktadd does.

Are you able to do a kinit using the keytab for nfs/vcslinux5.vxindia.ve
ritas.com?
("kinit -k -t /etc/krb5.keytab  nfs/vcslinux5.vxindia.veritas.com")

Can you list the keys in your keytab using the ktutil program?  I 
suspect that something is wrong with your keytab file.  How did you 
move it from the KDC machine to your NFS client?


> Hi Kevin , 
>     I created new database and new principal and 
>     keytab files.
> 
>     Kinit does not accept passowrd for principals
>     nfs/vcslinux5.vxindia.veritas.com
>     and
>     nfs/vcslinux6.vxindia.veritas.com
> 
>     Please let me know if i can provide some info(and
> how) (logs) which can point out the problem
> 
> thanks,
>  --kiran
> 
> 
> 
> 
> --- Kevin Coffman <kwc@citi.umich.edu> wrote:
> > > 
> > > Hi , 
> > >              I tried things as directed by Trond
> > in
> > >     his previous mail and everything seemed to
> > work
> > >     fine initally. but when i rebooted system , 
> > >     it started giving error whenever i start
> > rpc.gssd
> > >     on client machine.
> > >     Error is :
> > > 
> > > [root@vcslinux6 ~]# Mar 21 14:47:27 vcslinux6
> > > rpc.gssd[3487]: WARNING: Key table entry not found
> > > while getting initial ticket for principal
> > >
> >
> 'nfs/vcslinux6.vxindia.veritas.com@VXINDIA.VERITAS.COM'
> > > from keytab 'FILE:/etc/krb5.keytab'
> > > Mar 21 14:47:27 vcslinux6 rpc.gssd[3487]: ERROR:
> > No
> > > usable machine credentials obtained
> > >   
> > >      
> > > while #klist -k /etc/krb5.keytab gives
> > > 2
> > >
> >
> nfs/vcslinux6.vxindia.veritas.com@VXINDIA.VERITAS.COM
> > 
> > 
> > I'm confused by this, but I do not know what to look
> > for.
> > 
> > 
> > > I even tried by recreating kerberos database but
> > in
> > > vain. I still get the same error.
> > 
> > If you recreated the Kerberos database, you need to
> > create new principals and keytab files.  Did you do
> > this?
> > 
> > > I observed one more thing.
> > > Whenver i create principal(other then root/admin)
> > ,
> > > passwords i enter for them during their creation
> > > are not accepted by kinit.
> > 
> > This is also strange and _might_ be related.  How
> > are
> > you creating the principals -- using kadmin or
> > kadmin.local?
> > Which principals are you referring to here?
> > 
> > > 
> > > Please let me know where i went wrong.
> > > 
> > > --thanks,
> > >  --kiran
> > 
> > 
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
