From: Olaf Kirch <okir@suse.de>
Subject: Re: rpc-srv/tcp: nfsd: sent only -107 bytes of #### - shutting down socket error
Date: Mon, 20 Sep 2004 18:58:06 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20040920165805.GA19606@suse.de>
References: <EXCHG20030Yg83alUoh0000182d@EXCHG2003.microtech-ks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1C9RUR-0008Gs-5R
	for nfs@lists.sourceforge.net; Mon, 20 Sep 2004 09:58:11 -0700
Received: from cantor.suse.de ([195.135.220.2])
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.41)
	id 1C9RUP-00006z-Kg
	for nfs@lists.sourceforge.net; Mon, 20 Sep 2004 09:58:11 -0700
To: Roger Heflin <rheflin@atipa.com>
In-Reply-To: <EXCHG20030Yg83alUoh0000182d@EXCHG2003.microtech-ks.com>
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

On Mon, Sep 20, 2004 at 11:41:34AM -0500, Roger Heflin wrote:
> Any indications of exactly what this error means?
> 
> rpc-srv/tcp: nfsd: sent only -107 bytes of #### - shutting down socket error

It means nfsd got an ENOTCONN from sendto(). You want to increase the
number of nfsds; these messages should mostly go away then.

Olaf

> 
> They are receiving the error in the range of 10-30 times per second on the
> heavily used nfs servers.
> 
> This is running with nfs over tcp, with 32k packet sizes, what 4 nfs servers
> and roughly 230 clients.  Until the amount of nfs usage increased this error
> did not appear to be happening, or was not noticed.
> 
> The clients are also getting these messages:
> RPC: tcp_data_ready socket info not found!
> 
> /proc/mounts confirms the 32k read/write, and that tcp is being used.
> 
> There are some other odd things happening, the admins and users indicate
> that 
> they have had several instances of editing an existing file and then saving 
> the file and that file not being there after they exit and save in the 
> editor, and not sure if this is a related problem or something else
> entirely.
> 
>                         Roger
> 
> 
>  
> 
> 
> 
> 
> -------------------------------------------------------
> This SF.Net email is sponsored by: YOU BE THE JUDGE. Be one of 170
> Project Admins to receive an Apple iPod Mini FREE for your judgement on
> who ports your project to Linux PPC the best. Sponsored by IBM.
> Deadline: Sept. 24. Go here: http://sf.net/ppc_contest.php
> _______________________________________________
> NFS maillist  -  NFS@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/nfs

-- 
Olaf Kirch     |  The Hardware Gods hate me.
okir@suse.de   |
---------------+ 


-------------------------------------------------------
This SF.Net email is sponsored by: YOU BE THE JUDGE. Be one of 170
Project Admins to receive an Apple iPod Mini FREE for your judgement on
who ports your project to Linux PPC the best. Sponsored by IBM.
Deadline: Sept. 24. Go here: http://sf.net/ppc_contest.php
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
