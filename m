From: Jason Holmes <jholmes@psu.edu>
Subject: Re: 2.4 vs. 2.6 nfs client performance
Date: Thu, 13 Nov 2003 16:55:52 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <3FB3FDE8.47E819FF@psu.edu>
References: <3FB27670.4C878A84@psu.edu>
			<shssmkttk34.fsf@charged.uio.no>
			<3FB29D43.A618973D@psu.edu>
			<16306.41898.291062.36209@charged.uio.no>
			<3FB2A738.3F2C90B8@psu.edu>
			<16306.49310.195265.145519@charged.uio.no>
			<3FB2DC60.FA7D3E08@psu.edu> <16306.59249.857512.354675@charged.uio.no> <3FB3924B.7450E9F7@psu.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 1AKPRR-0002GQ-00
	for <nfs@lists.sourceforge.net>; Thu, 13 Nov 2003 13:55:53 -0800
Received: from vpn-19-5.aset.psu.edu ([146.186.19.5] helo=funkmachine.cac.psu.edu)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.24)
	id 1AKPRR-0003Af-3O
	for nfs@lists.sourceforge.net; Thu, 13 Nov 2003 13:55:53 -0800
To: trond.myklebust@fys.uio.no, nfs@lists.sourceforge.net
Errors-To: nfs-admin@lists.sourceforge.net
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

Jason Holmes wrote:
> 
> Trond Myklebust wrote:
> >
> > Any hints on how I can reproduce your results?
> 
> Unfortunately Gaussian's licensing would prohibit me from passing it
> along to reproduce this.  I'll try to reproduce this with another
> program this morning and get back to you.

OK, I haven't found any other program that behaves similar to Gaussian
on this, but I did do a few more runs with 2.6.0-test9-bk17 vs 2.4.22,
one set with nfs_debug on and one set with rpc_debug on.  I haven't
analyzed the files in depth (and doing so would really be beyond me at
this point), but on a "dumb" level, the nfs files are of similar length
in terms of lines, but the RPC file for 2.6.0-test9-bk17 is much larger:

[root@fs4 log]# wc -l kern.*
  16236 kern.nfs-2.4.22
  17188 kern.nfs-2.6.0-test9-bk17
  20565 kern.rpc-2.4.22
  32684 kern.rpc-2.6.0-test9-bk17

Note that there is probably some small amount of noise in these files,
but 98% of it should be from the Gaussian runs.  I put them up at:

  http://magicbus.cac.psu.edu/nfs

if you want to look at them.  One small observation is that 2.4.22
reaches much larger values of cwnd than test9-bk17, resulting in a lot
fewer calls to functions such as xprt_cwnd_limited (1861 vs. 2715). 
Whether or not this means anything, I don't know.

Trond, if none of this helps and you really want to debug this, I can
probably give you access to two machines to do so.

Thanks,

--
Jason Holmes


-------------------------------------------------------
This SF.Net email sponsored by: ApacheCon 2003,
16-19 November in Las Vegas. Learn firsthand the latest
developments in Apache, PHP, Perl, XML, Java, MySQL,
WebDAV, and more! http://www.apachecon.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
