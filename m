From: Neil Brown <neilb@cse.unsw.edu.au>
Subject: Re: 2.4.19-pre5-ac3 NFS problems
Date: Fri, 12 Apr 2002 12:56:04 +1000 (EST)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <15542.19652.743976.342481@notabene.cse.unsw.edu.au>
References: <15537.631.242570.416618@notabene.cse.unsw.edu.au>
	<Pine.LNX.4.44.0204110730460.6902-100000@atx.fast.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.28])
	by usw-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 16vrBO-0000xt-00
	for <nfs@lists.sourceforge.net>; Thu, 11 Apr 2002 19:53:02 -0700
Received: From notabene ([129.94.242.45] == bartok.orchestra.cse.unsw.EDU.AU)
	(for <shirsch@adelphia.net>) (for <nfs@lists.sourceforge.net>) By
	tone With Smtp ; Fri, 12 Apr 2002 12:52:48 +1000
To: "Steven N. Hirsch" <shirsch@adelphia.net>
In-Reply-To: message from Steven N. Hirsch on Thursday April 11
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

On Thursday April 11, shirsch@adelphia.net wrote:
> 
> Neil,
> 
> I finally got the chance to bang on this.  I'm not seeing anything 
> queueing on port 32768, but during the period when 'pine' hangs there 
> seems to be a large number number of requests on port 32771 server-side.  
> At no point does the backlog fall below about 160.  What should I be 
> seeing?

I'm perplexed...
Is 32771 a local port or a remote port on the server?

What I would expect you do see on the server if you do 
       netstat -t
is something like:
Active Internet connections (w/o servers)
Proto Recv-Q Send-Q Local Address           Foreign Address         State
tcp        0      0 elfman.orchestra.c:2049 dulcimer.orchestra.:800 ESTABLISHED

The local address is "2049".
The remote address could be anything.  My 2.4 Linux clients seem to
choose 800, but anything is reasonable.

I would expect the see the Recv-Q and Send-Q jump around a lot when IO
is happening, but settle to zero whenever it is quiet.

If the connection that you are looking at is the NFS connection
(i.e. the other end is 2049) then the fact that it never gets below
160 suggests that I've got my accounting wrong somewhere. 
The simplest option would be that sk_reserved goes negative, but I
cannot see what would cause that...

NeilBrown

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
