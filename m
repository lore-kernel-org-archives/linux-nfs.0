From: Kevin Coffman <kwc@citi.umich.edu>
Subject: Re: problem mounting using NFSv4 when using -o sec=krb5
 option
Date: Mon, 21 Mar 2005 16:36:04 -0500
Message-ID: <20050321213604.8A2931BACE@citi.umich.edu>
References: <20050321154527.32344.qmail@web51603.mail.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DDUZC-0007sz-PX
	for nfs@lists.sourceforge.net; Mon, 21 Mar 2005 13:36:06 -0800
Received: from citi.umich.edu ([141.211.133.111])
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1DDUZB-00026l-8n
	for nfs@lists.sourceforge.net; Mon, 21 Mar 2005 13:36:06 -0800
To: mehta kiran <kiranmehta1981@yahoo.com>
In-reply-to: <20050321154527.32344.qmail@web51603.mail.yahoo.com> 
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

> 
> Hi , 
>              I tried things as directed by Trond in
>     his previous mail and everything seemed to work
>     fine initally. but when i rebooted system , 
>     it started giving error whenever i start rpc.gssd
>     on client machine.
>     Error is :
> 
> [root@vcslinux6 ~]# Mar 21 14:47:27 vcslinux6
> rpc.gssd[3487]: WARNING: Key table entry not found
> while getting initial ticket for principal
> 'nfs/vcslinux6.vxindia.veritas.com@VXINDIA.VERITAS.COM'
> from keytab 'FILE:/etc/krb5.keytab'
> Mar 21 14:47:27 vcslinux6 rpc.gssd[3487]: ERROR: No
> usable machine credentials obtained
>   
>      
> while #klist -k /etc/krb5.keytab gives
> 2
> nfs/vcslinux6.vxindia.veritas.com@VXINDIA.VERITAS.COM


I'm confused by this, but I do not know what to look for.


> I even tried by recreating kerberos database but in
> vain. I still get the same error.

If you recreated the Kerberos database, you need to
create new principals and keytab files.  Did you do this?

> I observed one more thing.
> Whenver i create principal(other then root/admin) ,
> passwords i enter for them during their creation
> are not accepted by kinit.

This is also strange and _might_ be related.  How are
you creating the principals -- using kadmin or kadmin.local?
Which principals are you referring to here?

> 
> Please let me know where i went wrong.
> 
> --thanks,
>  --kiran



-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
