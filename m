From: Tom McNeal <trmcneal@attbi.com>
Subject: Re: nfs performance
Date: Thu, 01 Aug 2002 10:29:54 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <3D497012.C1A099F7@attbi.com>
References: <8D7D56C6ED3DD411998D009027DC685E0874E1E8@srv-grp-s1.segin.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sccrmhc02.attbi.com ([204.127.202.62])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17aJiD-0000W7-00
	for <nfs@lists.sourceforge.net>; Thu, 01 Aug 2002 10:26:09 -0700
To: Brasseur =?iso-8859-1?Q?Val=E9ry?= <Valery.Brasseur@atosorigin.com>
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
List-Archive: <http://www.geocrawler.com/redir-sf.php3?list=nfs>

Brasseur Valéry wrote:
> 
> how can I measure the performance of my NFS client ?
> 
> I am using linux client with Netapp filer server.
> I would like to know which is the throuput limit of the linux NFS client !
> 
> anybody got ideas ?
> thanks

I've found the best client measurement tool is IOzone, given that 
it measures varied access types (serial forward and backwards, 
random, even jumps, etc.) across various file sizes, and can put
the output into a nicely readable excel graph.  Its available at
http://www.iozone.org/

I also have IOzone packaged up in a test & measurement package that 
has a gui front end (although you still have to figure out which
of the 50+ options in IOzone you want to use).  Its at
http://sourceforge.net/projects/nfstestmatrix

Finally, take a look at the performance howto, which discusses 
various benchmarks among other things.  Its at
http://nfs.sourceforge.net/nfs-howto/performance.html

Regards -

Tom

--
------------------------------------------------------------
Tom McNeal       trmcneal@attbi.com     (650)906-0761 (cell) 
------------------------------------------------------------


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
