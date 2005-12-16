From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: lockd: couldn't create RPC handle for (host)
Date: Fri, 16 Dec 2005 18:49:05 -0500
Message-ID: <1134776945.7952.4.camel@lade.trondhjem.org>
References: <20051216205536.GA20497@tau.solarneutrino.net>
Mime-Version: 1.0
Content-Type: text/plain
Cc: nfs@lists.sourceforge.net, linux-kernel@vger.kernel.org
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1EnPKN-0007ap-9a
	for nfs@lists.sourceforge.net; Fri, 16 Dec 2005 15:49:31 -0800
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1EnPKM-0000cb-1F
	for nfs@lists.sourceforge.net; Fri, 16 Dec 2005 15:49:31 -0800
To: Ryan Richter <ryan@tau.solarneutrino.net>
In-Reply-To: <20051216205536.GA20497@tau.solarneutrino.net>
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

On Fri, 2005-12-16 at 15:55 -0500, Ryan Richter wrote:
> Hi, nfs locking stopped working on my file server running 2.6.15-rc5
> today.  All clients that try locking operations hang, and I get the
> message from the server:
> 
> lockd: couldn't create RPC handle for w.x.y.z

Points either to a client which is not responding to callbacks, or an
OOM situation on the server.

Does 'rpcinfo -u w.x.y.z 100021' work from the server?

> Also, the lockd process is unkillable, it looks like I'll have to
> reboot.

lockd cannot be killed as long as you have active nfsd threads or active
nfs client partitions. That is by design.

Cheers,
  Trond



-------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc. Do you grep through log files
for problems?  Stop!  Download the new AJAX search engine that makes
searching your log files as easy as surfing the  web.  DOWNLOAD SPLUNK!
http://ads.osdn.com/?ad_id=7637&alloc_id=16865&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
