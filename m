From: Olaf Kirch <okir@suse.de>
Subject: Re: Reserving port 800 on linux NFS clients
Date: Wed, 17 Mar 2004 09:33:10 +0100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20040317083309.GA14278@suse.de>
References: <o8lf50t2d4junli54us281h0i7433pl5lr@4ax.com> <Pine.LNX.4.33L2.0403171349300.20810-100000@jeprox.qsr.com.ph>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1B3WUD-0006NB-UJ
	for nfs@lists.sourceforge.net; Wed, 17 Mar 2004 00:33:13 -0800
Received: from ns.suse.de ([195.135.220.2] helo=Cantor.suse.de)
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.30)
	id 1B3WUC-0004Fp-I2
	for nfs@lists.sourceforge.net; Wed, 17 Mar 2004 00:33:12 -0800
To: "ian sison (mailing list)" <ian.s@qsr.com.ph>
In-Reply-To: <Pine.LNX.4.33L2.0403171349300.20810-100000@jeprox.qsr.com.ph>
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

On Wed, Mar 17, 2004 at 01:50:08PM +0800, ian sison (mailing list) wrote:
> I think http://www.lowth.com/LinWiz/nfs_help.html would be helpful in
> this.

I don't think it will help, because this document covers server side
port allocation. The question was about the NFS client port allocation.

The NFS currently allocates a reserved port for the NFS client
by trying all ports from 800 downward, until it finds one it can
bind to.

There are two ways to make the client skip port 800.

 -	start your network service before mounting any NFS file
 	systems. When NFS tries to bind a reserved port, it
	will find this one is already in use and skip it

 -	if that is not possible, you need to patch net/sunrpc/xprt.c
 	and change the XPRT_MAX_RESVPORT define to e.g. 799

Olaf
-- 
Olaf Kirch     |  Stop wasting entropy - start using predictable
okir@suse.de   |  tempfile names today!
---------------+ 


-------------------------------------------------------
This SF.Net email is sponsored by: IBM Linux Tutorials
Free Linux tutorial presented by Daniel Robbins, President and CEO of
GenToo technologies. Learn everything from fundamentals to system
administration.http://ads.osdn.com/?ad_id=1470&alloc_id=3638&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
