From: Kevin Coffman <kwc@citi.umich.edu>
Subject: Re: problem mounting using NFSv4 when using -o sec=krb5
 option
Date: Wed, 16 Mar 2005 11:28:54 -0500
Message-ID: <20050316162854.53EA71BADE@citi.umich.edu>
References: <20050316154052.19953.qmail@web51602.mail.yahoo.com>
 <20050316161223.0C5A31BADE@citi.umich.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DBbOC-0007sk-Js
	for nfs@lists.sourceforge.net; Wed, 16 Mar 2005 08:28:56 -0800
Received: from citi.umich.edu ([141.211.133.111])
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1DBbOB-0004tq-30
	for nfs@lists.sourceforge.net; Wed, 16 Mar 2005 08:28:56 -0800
To: mehta kiran <kiranmehta1981@yahoo.com>
In-reply-to: <20050316161223.0C5A31BADE@citi.umich.edu> 
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

Also, "failed reading uid from krb5 upcall" and "Failed to write error 
downcall" should not normally happen.  What versions of kernel and 
nfs-utils do you have?


> > Error in log file on mount 
> > Mar 16 14:58:43 vcslinux5 rpc.gssd[4258]: WARNING:
> > failed reading uid from krb5 upcall pipe: Success
> > Mar 16 14:58:43 vcslinux5 rpc.gssd[4405]: WARNING: Key
> > table entry not found while getting initial ticket for
> > principal
> > 'nfs/vcslinux1.vxindia.veritas.com@VXINDIA.VERITAS.COM'
> > from keytab 'FILE:/etc/krb5.keytab'
> > Mar 16 14:58:43 vcslinux5 rpc.gssd[4405]: ERROR: No
> > usable machine credentials obtained
> > Mar 16 14:58:43 vcslinux5 rpc.gssd[4405]: WARNING:
> > Failed to obtain machine credentials for connection to
> > server vcslinux1.vxindia.veritas.com
> > Mar 16 14:59:08 vcslinux5 rpc.gssd[2760]: WARNING:
> > Failed to create krb5 context for user with uid 0 with
> > any credentials cache for server
> > vcslinux1.vxindia.veritas.com
> > Mar 16 14:59:08 vcslinux5 rpc.gssd[2760]: Failed to
> > write error downcall!
> > 
> > thanks,
> >  --kiran



-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
