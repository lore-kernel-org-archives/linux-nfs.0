From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH] prevent sunrpc deadlock with debug on
Date: Wed, 05 Jan 2005 18:21:39 +0100
Message-ID: <1104945700.520.22.camel@lade.trondhjem.org>
References: <20041216165714.GB2077@suse.de>
	 <1104277396.3976.10.camel@lade.trondhjem.org>
	 <20050105164455.GI26856@suse.de>
Mime-Version: 1.0
Content-Type: text/plain
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CmErB-0001QC-3n
	for nfs@lists.sourceforge.net; Wed, 05 Jan 2005 09:22:01 -0800
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.41)
	id 1CmEr6-0007zw-0Y
	for nfs@lists.sourceforge.net; Wed, 05 Jan 2005 09:22:00 -0800
To: Olaf Kirch <okir@suse.de>
In-Reply-To: <20050105164455.GI26856@suse.de>
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

on den 05.01.2005 Klokka 17:44 (+0100) skreiv Olaf Kirch:

> Still, if we ever run into a corrupted task struct, we will still
> deadlock. How about this:
> 
>   show_tasks(void)
>   {
>         struct list_head *le;
>         struct rpc_task *t;
> 
> -       spin_lock(&rpc_sched_lock);
> +	if (!spin_trylock(&rpc_sched_lock))
> +		return;
>         if (list_empty(&all_tasks)) {
>                 spin_unlock(&rpc_sched_lock);

In the end I opted to convert that deadlock into a BUG_ON() (see the
latest Bitkeeper kernel). The whole point of that code is to ensure that
people report real bugs in which the RPC state machine is being
corrupted. Its entire reason for existence disappears if people start
worrying about the debugging deadlocks, but not the underlying bugs.

BUG_ON() is a more definite obstruction, and so tends to get people
annoyed enough to file reports. 8-)

Cheers,
  Trond

-- 
Trond Myklebust <trond.myklebust@fys.uio.no>



-------------------------------------------------------
The SF.Net email is sponsored by: Beat the post-holiday blues
Get a FREE limited edition SourceForge.net t-shirt from ThinkGeek.
It's fun and FREE -- well, almost....http://www.thinkgeek.com/sfshirt
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
