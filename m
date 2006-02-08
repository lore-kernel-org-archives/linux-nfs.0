From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: Performance improvement.
Date: Wed, 08 Feb 2006 09:43:19 -0500
Message-ID: <1139409799.7863.28.camel@lade.trondhjem.org>
References: <43E9A428.2030606@totalflood.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: NFS List <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1F6qXe-0001td-Jz
	for nfs@lists.sourceforge.net; Wed, 08 Feb 2006 06:43:34 -0800
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1F6qXd-0001rO-7O
	for nfs@lists.sourceforge.net; Wed, 08 Feb 2006 06:43:34 -0800
To: Stephen Carville <stephen@totalflood.com>
In-Reply-To: <43E9A428.2030606@totalflood.com>
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

On Tue, 2006-02-07 at 23:56 -0800, Stephen Carville wrote:
> Maybe my expectations are too high but...
> 
> I have an NFS server (amazon) running FC3 and two clients (tigris and 
> euphrates) running Redhat ES-3.4 and ES-3.0 respectively.   I am writing 
> the nightly rman backups of the oracle databases running tigris and 
> euphrates to a large RAID on amazon.  The machines are connected via a 
> private network thru a Dell Power Connect 2716 switch.  After some 
> tuning, Iperf shows consistent transfer rates of 950 Mbps to 980 Mbps 
> for both TCP and UDP.
> 
> Euphrates (ES 3.0) will only work with nfs2 and, even with 8K packets, 
> only produices about 1.5 MB/s (12 Mbps).  By comparison, tigris (ES 3.4) 
> handles V3 with 32K datagrams and produces about 12 MB/s (96 Mbps). 
> Still only a fraction of what the network can handle but much better 
> than the other box.
> 
> I've tuned the network and I'm using the largest blocksize I can.  What 
> else can I do to improve performance?


http://nfs.sourceforge.net/nfs-howto/performance.html

Cheers,
  Trond



-------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc. Do you grep through log files
for problems?  Stop!  Download the new AJAX search engine that makes
searching your log files as easy as surfing the  web.  DOWNLOAD SPLUNK!
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=103432&bid=230486&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
