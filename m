From: Tom Tucker <tom@opengridcomputing.com>
Subject: Re: Latency problem with some clients but not others
Date: Wed, 15 Aug 2007 12:40:03 -0500
Message-ID: <1187199603.4851.18.camel@trinity.ogc.int>
References: <46C33597.3030004@caps-entreprise.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: Romain Dolbeau <romain.dolbeau@caps-entreprise.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1ILMs2-0002ld-Q4
	for nfs@lists.sourceforge.net; Wed, 15 Aug 2007 10:41:26 -0700
Received: from rrcs-71-42-183-126.sw.biz.rr.com ([71.42.183.126]
	helo=smtp.opengridcomputing.com)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1ILMs6-000518-R8
	for nfs@lists.sourceforge.net; Wed, 15 Aug 2007 10:41:31 -0700
In-Reply-To: <46C33597.3030004@caps-entreprise.com>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

Could be unrelated but...

I had a similar issue with a Supermicro motherboard that had a new
version of the Intel e1000 LOM chip. Updating the driver from the Intel
web site made the problem go away. 

On Wed, 2007-08-15 at 19:19 +0200, Romain Dolbeau wrote:
> Hello all,
> 
> I have a strange latency problem that affect some clients
> but not others. The server is a x86_64 Debian machine.
> 
> I've created a test case with just 2 64 bits clients. Both use
> the same kernel, and have the same packages installed. They both
> mount the same filesystems at the mountpoint through amd (the
> maps are distributed through NIS).
> 
> The user is the same, with one single logging through SSH.
> Nothing is running (except kdm) on either clients.
> All machines are directly hooked to the same gigabit switch.
> The network traffic was extremely low during the test.
> Both clients were freshly rebooted.
> 
> One of the client is a dual Xeon 5130 system, with an on-board
> intel NIC (module e1000). The other is a single Core 2 Duo 6320,
> with an on-board ??? NIC (module r8169).
> 
> When doing a ./configure (lots of small r/w accesses) inside one
> of the NFS mounted filesystem, the first system is fairly fast,
> while the other is much slower - each line of the configure script
> takes up to a second to display a result. *But*, pure throughput is
> fine - if I use dd to write or read a large file, the speed is what
> I would expect from the wire.
> 
> The problem is reproductible to all similar clients to the
> second system, but I also have other clients (for instance
> old 32 bits systems with 3c59x cards) that do not exhibit
> the problem. In fact, it seems that all my 32 bits clients
> are fast (well, as fast as they can be :-), and all my 64 bits
> are slow, except two : the one above, and an old Pentium D
> machine with an e100 card.
> 
> Any idea where I should look ? My only clue is that all my slow
> 64 bits client uses the same driver (r8169), whereas the fast one
> uses e1000 and e100, could that be the source of the problem ?
> (I don't havea spare NIC to try) ; is there any know problem
> with such cheap on-board NIC ? How could I tell ?
> 
> Thanks in advance for any help.
> 
> P.S. just in case it's significant...
> 
> * mount display : "type nfs 
> (nodev,nosuid,nounmount,noatime,rsize=8192,wsize=8192,vers=3,proto=tcp)"
>   for all filesystems on all clients.
> * kernel is current Debian stable (2.6.18-4) or testing (2.6.21-2),
>   same symptoms for both.
> * I've tried both the included r8169 driver and the one from Realtek,
>   same symptoms for both.
> 


-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
