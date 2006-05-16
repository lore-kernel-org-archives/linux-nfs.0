From: Neil Brown <neilb@suse.de>
Subject: Re: time_out_leases + 2.6 problem?
Date: Tue, 16 May 2006 10:30:00 +1000
Message-ID: <17513.7432.642102.868775@cse.unsw.edu.au>
References: <446916B1.8040202@wildcash.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from [10.3.1.94] (helo=sc8-sf-list2-new.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1FfnSI-0002zG-9X
	for nfs@lists.sourceforge.net; Mon, 15 May 2006 17:30:30 -0700
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1FfnSI-0003Fq-6K
	for nfs@lists.sourceforge.net; Mon, 15 May 2006 17:30:30 -0700
Received: from cantor2.suse.de ([195.135.220.15] helo=mx2.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1FfnSG-0001zx-SL
	for nfs@lists.sourceforge.net; Mon, 15 May 2006 17:30:30 -0700
To: Rudi Starcevic <tech@wildcash.com>
In-Reply-To: message from Rudi Starcevic on Tuesday May 16
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

On Tuesday May 16, tech@wildcash.com wrote:
> Hi,
> 
> I have an NFS cluster of 16 Servers and 7 Clients.
> 
> The 7 NFS clients are also running Apache web servers
> for a video-on-demand web site.
> 
> All servers are GNU/Debian Linux with 2.6.8 kernel.
> 

Servers also seem to be using the user-space nfs server.  What this
intentional?  If so, why?
If not, try install nfs-kernel-server and using that instead.  It is
likely to work better.

> 
> CPU: 0
> EIP: 0060: [<c0166a68>] not tainted
> EFlags: 00010206 (2.6.8-imp10)
> EIP is at a time_out_leases
> Process rpc.nfsd
> 
> Do you think this 'time_out_leases' is a 2.6.8 NFS kernel issues?
> 
> Would upgrading to a new kernel help this?

Given how old 2.6.8 is, and upgrade is certainly worth a try.

NeilBrown


-------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
