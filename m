From: Olaf Kirch <okir@suse.de>
Subject: Re: Kernel freezes on "exportfs -a"
Date: Wed, 17 Nov 2004 10:28:28 +0100
Message-ID: <20041117092828.GA1492@suse.de>
References: <20041116112237.GQ20889@urmel.freenet-ag.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CUMZP-0004j4-KG
	for nfs@lists.sourceforge.net; Wed, 17 Nov 2004 01:57:47 -0800
Received: from cantor.suse.de ([195.135.220.2])
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.41)
	id 1CUMZO-0004E7-Pr
	for nfs@lists.sourceforge.net; Wed, 17 Nov 2004 01:57:47 -0800
To: Marian Eichholz <marian.eichholz@freenet-ag.de>
In-Reply-To: <20041116112237.GQ20889@urmel.freenet-ag.de>
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

On Tue, Nov 16, 2004 at 12:22:37PM +0100, Marian Eichholz wrote:
> Hello all, hi Neil, hi Olaf,
> 
> we recently found a strange bug in the recent 2.6 kernels
> that freezes the whole kernel (down to even no response to
> the Magic SysRq keys). And in fact sticks us to the 2.4
> series we want to get rid of :)

Did you try enabling the NMI watchdog so you get a backtrace
of where it hangs?

Olaf
-- 
Olaf Kirch     | Things that make Monday morning interesting, #1:
okir@suse.de   |        "I want to use NFS over AX25, can you help me?"
---------------+ 


-------------------------------------------------------
This SF.Net email is sponsored by: InterSystems CACHE
FREE OODBMS DOWNLOAD - A multidimensional database that combines
robust object and relational technologies, making it a perfect match
for Java, C++,COM, XML, ODBC and JDBC. www.intersystems.com/match8
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
