From: Edward Roper <eroper@sanera.net>
Subject: Re: close() / nfs commit performance
Date: 01 Jul 2003 14:36:10 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1057095370.26307.15.camel@themachine.sanera.net>
References: <482A3FA0050D21419C269D13989C6113D069EA@lavender-fe.eng.netapp.com>
	 <1057015133.21354.44.camel@themachine.sanera.net>
	 <shshe67xeyd.fsf@charged.uio.no>
	 <1057089355.26307.11.camel@themachine.sanera.net>
Mime-Version: 1.0
Content-Type: text/plain
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from ns1.sanera.net ([208.253.254.10] helo=sentinel)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 19XSnZ-00031S-00
	for <nfs@lists.sourceforge.net>; Tue, 01 Jul 2003 14:36:25 -0700
Received: from icarus.sanera.net (icarus.sanera.net [192.168.254.11])
	by sentinel (8.12.9/8.12.8) with ESMTP id h61LaF1k000640
	for <nfs@lists.sourceforge.net>; Tue, 1 Jul 2003 14:36:15 -0700
Received: from wshield.sanera.net (wshield.sanera.net [172.16.1.100])
	by icarus.sanera.net (8.11.6/8.11.6) with SMTP id h61LaAw26104
	for <nfs@lists.sourceforge.net>; Tue, 1 Jul 2003 14:36:10 -0700
To: nfs@lists.sourceforge.net
In-Reply-To: <1057089355.26307.11.camel@themachine.sanera.net>
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

And one last number: data=journal with a ramdisk (trd) journal device
leads to only 8,782KB/Second. (via tcp nfs 500mb filesize 8192 record
size) vs. 4,924kB/Second. Quite an improvement, but still not
16,797kB/Second.

On Tue, 2003-07-01 at 12:55, Edward Roper wrote:
> Alright so rerunning iozone with the flush option which calls fsync() my
> new number on the 2GB file is: 16,797kB/second vs. the 4,924kB/second on
> the Linux server and the 31,757kB/second on the netapp. I'm still not
> understanding where the flush performance hit to the tune of
> ~12,000kB/second is coming from? I would assume that with nvram I would
> have a greater fsync() local performance than the 16,797kB/second?
> 
> On Mon, 2003-06-30 at 17:34, Trond Myklebust wrote:
> 
> > man 2 fsync
> > 
> > Cheers,
> >   Trond




-------------------------------------------------------
This SF.Net email sponsored by: Free pre-built ASP.NET sites including
Data Reports, E-commerce, Portals, and Forums are available now.
Download today and enter to win an XBOX or Visual Studio .NET.
http://aspnet.click-url.com/go/psa00100006ave/direct;at.asp_061203_01/01
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
