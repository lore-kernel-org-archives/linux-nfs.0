From: Jeff Layton <jlayton@redhat.com>
Subject: Re: Error inserting sunrpc  Error inserting nfs
Date: Wed, 28 Feb 2007 10:04:57 -0500
Message-ID: <45E59A19.5080306@redhat.com>
References: <944755.15499.qm@web56604.mail.re3.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: AK <amithl_prem@yahoo.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HMQMZ-00041B-SP
	for nfs@lists.sourceforge.net; Wed, 28 Feb 2007 07:05:04 -0800
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HMQMb-0007hC-Ly
	for nfs@lists.sourceforge.net; Wed, 28 Feb 2007 07:05:06 -0800
In-Reply-To: <944755.15499.qm@web56604.mail.re3.yahoo.com>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

AK wrote:
> Hi All,
>  
> I get the following errors on bootup, reproduced by modprobe, as shown 
> below.
> Everything was working fine until I changed the rsize and wsize to: 
> 32768 and then rebooted the system.
> Now If I rechange it back to original 8192 value, it still fails.
> Any idea ???
>  
> ~thanks in advance!!!
>  
> modprobe nfs
> FATAL: Error inserting sunrpc 
> (/lib/modules/2.6.9-22.ELsmp/kernel/net/sunrpc/sunrpc.ko): Unknown 
> symbol in module, or unknown parameter (see dmesg)
> WARNING: Error running install command for sunrpc
> WARNING: Error inserting lockd 
> (/lib/modules/2.6.9-22.ELsmp/kernel/fs/lockd/lockd.ko): Unknown symbol 
> in module, or unknown parameter (see dmesg)
> FATAL: Error inserting nfs 
> (/lib/modules/2.6.9-22.ELsmp/kernel/fs/nfs/nfs.ko): Unknown symbol in 
> module, or unknown parameter (see dmesg)
> 

What shows up in dmesg? Does "modprobe sunrpc" also fail? Added anything
to modprobe.conf that affects the sunrpc module?

-- Jeff

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
