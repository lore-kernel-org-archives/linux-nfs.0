From: Kevin Coffman <kwc@citi.umich.edu>
Subject: Re: Kerberized NFSv3 Client for Linux
Date: Mon, 14 Feb 2005 10:09:45 -0500
Message-ID: <20050214150945.BAE461BAF7@citi.umich.edu>
References: <38c3c48605021405536f044f64@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1D0hrG-0004Cw-AD
	for nfs@lists.sourceforge.net; Mon, 14 Feb 2005 07:09:54 -0800
Received: from citi.umich.edu ([141.211.133.111])
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1D0hrD-0007AU-JU
	for nfs@lists.sourceforge.net; Mon, 14 Feb 2005 07:09:54 -0800
To: Suresh Jayaram <sureshjayaram@gmail.com>
In-reply-to: <38c3c48605021405536f044f64@mail.gmail.com> 
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

Hi Suresh,
I don't think you mentioned Suse in your message to the Kerberos list.  
Does this mean you have Heimdal (as opposed to MIT) Kerberos libraries 
on your client?  (We have problems with the released Heimdal code.)

I assume you are running rpc.gssd on the client.  Can you run that with 
"-vvv" and send the output when you attempt to do the mount?


> Iam trying to setup kerberized NFS(v3) client for Linux.
> 
> My setup details
> NFS client: Suse Linux Enterprise Server (SLES 9) which has
> kernel - 2.6.5-7.97 (CONFIG_SUNRPC=y, CONFIG_SUNRPC_GSS=y,
> CONFIG_RPCSEC_GSS_KRB5=y )
> 
> nfs-utils-1.0.7 (patched - nfs-utils-1.0.7-CITI_NFS4_ALL-1.dif)
> util-linux-2.12 (patched - util-linux-2.12-CITI_NFS4_ALL-3.dif)
> 
> KDC Server: RedHat Linux
> NFS Server: Kerberized Solaris server (KDC Server & NFS Server are
> Tested and working fine)
> 
> To setup kerberized Linux Client, I presume a kernel with rpcsecgss
> support, patched nfs-utils pkg and patched util-linux pkg is
> sufficient. (Let me know any other pkg/configuration is required)
> 
> My NFS Server export entry is:
> share -F nfs -o sec=krb5 /export/home
> 
> Server has nfs principal registered to KDC and the user principal of
> client also registered to the Server.
> After doing a kinit if I try to mount the exported path, Iam getting
> 
> "mount: nfsserver:/export/home failed, reason given by server:
> Permission denied"
> Then I specified the client name in the exports file make gave
> readonly perms. Then also I got the same error.
> 
> Am I missing something ? Any pointers ..
> 
> thanks,
> Suresh
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
