From: raven@themaw.net
Subject: Re: nfsd: too may open TCP sockets
Date: Sat, 13 Nov 2004 14:20:02 +0800 (WST)
Message-ID: <Pine.LNX.4.58.0411131418310.9059@donald.themaw.net>
References: <20041111151127.GN13905@fi.muni.cz>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: nfs@lists.sourceforge.net, unix@fi.muni.cz
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CSrOF-0006zy-4o
	for nfs@lists.sourceforge.net; Fri, 12 Nov 2004 22:28:03 -0800
Received: from wombat.indigo.net.au ([202.0.185.19])
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.41)
	id 1CSrOC-00086b-WF
	for nfs@lists.sourceforge.net; Fri, 12 Nov 2004 22:28:03 -0800
To: Jan Kasprzak <kas@fi.muni.cz>
In-Reply-To: <20041111151127.GN13905@fi.muni.cz>
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

On Thu, 11 Nov 2004, Jan Kasprzak wrote:

> 	Hi all,
> 
> I've got the following on my server (after migrating home directories
> of ~2200 users and serving ~200 clients from it):
> 
> nfsd: too many open TCP sockets, consider increasing the number of nfsd threads
> 
> We have increased nfsd threads to 50, then 100, and now I am at 200:
> 
> # ps ax|grep -c nfsd
> 202
> 
> The server has load avg <1, so maybe it should be possible to increase
> a per-thread descriptor count or something like that. How can I do this?
> I think it is an overkill to have 200 nfsd threads on a machine with
> only 4 CPUs and ~10 RAID volumes.

I don't agree. I think 200 is quite a reasonable number of nfsd(s).

Ian



-------------------------------------------------------
This SF.Net email is sponsored by: InterSystems CACHE
FREE OODBMS DOWNLOAD - A multidimensional database that combines
robust object and relational technologies, making it a perfect match
for Java, C++,COM, XML, ODBC and JDBC. www.intersystems.com/match8
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
