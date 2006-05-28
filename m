From: Neil Brown <neilb@suse.de>
Subject: Re: Soft CPU Lockup on 2.6.15 with kernel nfsd
Date: Mon, 29 May 2006 09:58:30 +1000
Message-ID: <17530.14630.267759.700616@cse.unsw.edu.au>
References: <B5EB7762-BFC1-4CF0-B37B-E5589A941D6A@vanalteren.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from [10.3.1.94] (helo=sc8-sf-list2-new.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1FkV9k-0002Eb-TS
	for nfs@lists.sourceforge.net; Sun, 28 May 2006 16:58:48 -0700
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1FkV9k-0004Rv-SS
	for nfs@lists.sourceforge.net; Sun, 28 May 2006 16:58:48 -0700
Received: from ns1.suse.de ([195.135.220.2] helo=mx1.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1FkV9k-0000QC-Gd
	for nfs@lists.sourceforge.net; Sun, 28 May 2006 16:58:49 -0700
To: Ramon van Alteren <ramon@vanalteren.nl>
In-Reply-To: message from Ramon van Alteren on Saturday May 27
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

On Saturday May 27, ramon@vanalteren.nl wrote:
> Hi List,
> 
> I'm seeing several of these in my dmesg output on one of my NAS servers.
> Any pointers on where to start looking for a cause would be highly  
> appreciated.
> 
> Pid: 7122, comm:                 nfsd
> EIP: 0060:[<c057fe43>] CPU: 0
> EIP is at _read_lock_bh+0x12/0x1a
> EFLAGS: 00000216    Not tainted  (2.6.15-gentoo-r1)
> EAX: c069980c EBX: 00000000 ECX: f7ece000 EDX: f6100000
> ESI: c06997e0 EDI: ef7b4020 EBP: c0785b80 DS: 007b ES: 007b
> CR0: 8005003b CR2: 08056f98 CR3: 0073b000 CR4: 000006d0
> [<c05101c6>] ipt_do_table+0x6a/0x326
> [<c050a335>] ip_conntrack_in+0xd2/0x2c7
> [<c04d1fde>] ip_rcv_finish+0x0/0x2ba
> [<c051365b>] ipt_route_hook+0x37/0x3b
snip
> [<c021ebde>] nfsd+0x0/0x345
> [<c0101125>] kernel_thread_helper+0x5/0xb
> RPC: bad TCP reclen 0x0ddc8af7 (large)
> RPC: bad TCP reclen 0x272d2e25 (non-terminal)
> RPC: bad TCP reclen 0x46c6f2c8 (large)
> BUG: soft lockup detected on CPU#0!

Shouldn't the stack trace be "after" the 'soft lockup' message?

Anyway, the 'bad TCP reclen' is saying that you are getting incoming
garbage on tcp connections to the NFS server.  It must at least look
like TCP packets to get that far, but it definitely doesn't look like 
RPC packets in the TCP packets.

Why this is causing 'soft lockup' isn't clear.  The lockup seems to be
in an interrupt service routine.  Maybe something about these packets
is confusing netfilter enough that it is taking a long time to 
do something.

I would suggest checking your network, make sure there is no
unexpected traffic to port 2049.

NeilBrown


-------------------------------------------------------
All the advantages of Linux Managed Hosting--Without the Cost and Risk!
Fully trained technicians. The highest number of Red Hat certifications in
the hosting industry. Fanatical Support. Click to learn more
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=107521&bid=248729&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
