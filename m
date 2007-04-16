From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: Re: NFS livelock / starvation ?
Date: Mon, 16 Apr 2007 11:20:13 +0200
Message-ID: <1176715213.3035.27.camel@twins>
References: <67029b170704160124y7bfcb535h8dfbeb1530446469@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net, akpm@zip.com.au,
	neilb@cse.unsw.edu.au, linux-kernel@vger.kernel.org,
	trond.myklebust@fys.uio.no
To: Zhou Yingchao <yingchao.zhou@gmail.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HdNNk-0005DA-Vf
	for nfs@lists.sourceforge.net; Mon, 16 Apr 2007 02:20:21 -0700
Received: from amsfep16-int.chello.nl ([62.179.120.11])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HdNNn-0001CN-18
	for nfs@lists.sourceforge.net; Mon, 16 Apr 2007 02:20:23 -0700
In-Reply-To: <67029b170704160124y7bfcb535h8dfbeb1530446469@mail.gmail.com>
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

On Mon, 2007-04-16 at 16:24 +0800, Zhou Yingchao wrote:
> When we run a two nfs client and a nfs server in the following way, we
> met a livelock / starvation condition.
> 
> MachineA        MachineB
>  Client1             Client2
>  Server
> 
> As shown in the figure, we run a client and server on one machine, and
> run another client on another machine. When Client1 and Client2 make
> many writes at the same time, the Client1's request is blocked until
> Client2's writes finished.
> 
> We check the code, Client1 is blocked in generic_file_write-> ...
> >balance_dirty_pages, balance_dirty_pages call writeback_inodes to
> (only) flush data of the related fs.
> 
> In nfs, we found that the Server has enhanced its dirty_thresh. So in
> the loop of writeback_inodes, Client1 has no data to write out, and
> the condition "ns_reclaimable+wbs.nr_writeback<=dirty_thresh" will not
> be true until Client2 finishes its write request to Server. So the
> loop will only end after Client2 finished its write job.
> 
> The problem in this path is: why we write only pages of the related fs
> in writeback_inodes but check the dirty thresh for total pages?

I am working on patches to fix this.

Current version at (against -mm):
  http://programming.kicks-ass.net/kernel-patches/balance_dirty_pages/

However, after a rewrite of the BDI statistics work there are some
funnies, which I haven't had time to analyse yet :-/

I hope to post a new version soonish...


-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
