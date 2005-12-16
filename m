From: Ryan Richter <ryan@tau.solarneutrino.net>
Subject: Re: lockd: couldn't create RPC handle for (host)
Date: Fri, 16 Dec 2005 18:58:42 -0500
Message-ID: <20051216235841.GA20539@tau.solarneutrino.net>
References: <20051216205536.GA20497@tau.solarneutrino.net> <1134776945.7952.4.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: nfs@lists.sourceforge.net, linux-kernel@vger.kernel.org,
	ryan@tau.solarneutrino.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1EnPTN-00089l-17
	for nfs@lists.sourceforge.net; Fri, 16 Dec 2005 15:58:49 -0800
Received: from solarneutrino.net ([66.199.224.43] helo=tau.solarneutrino.net)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1EnPTL-00008F-UK
	for nfs@lists.sourceforge.net; Fri, 16 Dec 2005 15:58:49 -0800
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <1134776945.7952.4.camel@lade.trondhjem.org>
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

On Fri, Dec 16, 2005 at 06:49:05PM -0500, Trond Myklebust wrote:
> On Fri, 2005-12-16 at 15:55 -0500, Ryan Richter wrote:
> > Hi, nfs locking stopped working on my file server running 2.6.15-rc5
> > today.  All clients that try locking operations hang, and I get the
> > message from the server:
> > 
> > lockd: couldn't create RPC handle for w.x.y.z
> 
> Points either to a client which is not responding to callbacks, or an
> OOM situation on the server.
> 
> Does 'rpcinfo -u w.x.y.z 100021' work from the server?

No.

$ rpcinfo -u jacquere 100021
rpcinfo: RPC: Timed out
program 100021 version 0 is not available
zsh: exit 1     rpcinfo -u jacquere 100021

So I see now lockd is not present on the client. But...

$ rpcinfo -p jacquere
   program vers proto   port
    100000    2   tcp    111  portmapper
    100000    2   udp    111  portmapper
    100021    1   udp  32768  nlockmgr
    100021    3   udp  32768  nlockmgr
    100021    4   udp  32768  nlockmgr
    100024    1   udp    867  status
    100024    1   tcp    870  status

So what does that mean?

> > Also, the lockd process is unkillable, it looks like I'll have to
> > reboot.
> 
> lockd cannot be killed as long as you have active nfsd threads or active
> nfs client partitions. That is by design.

OK, that's good to know.

Thanks,
-ryan


-------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc. Do you grep through log files
for problems?  Stop!  Download the new AJAX search engine that makes
searching your log files as easy as surfing the  web.  DOWNLOAD SPLUNK!
http://ads.osdn.com/?ad_id=7637&alloc_id=16865&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
