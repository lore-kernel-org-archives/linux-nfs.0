From: "Steven N. Hirsch" <shirsch@adelphia.net>
Subject: Re: 2.4.19-pre5-ac3 NFS problems
Date: Fri, 12 Apr 2002 07:50:06 -0400 (EDT)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.LNX.4.44.0204120741490.14953-100000@atx.fast.net>
References: <15542.19652.743976.342481@notabene.cse.unsw.edu.au>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from smtprelay9.dc2.adelphia.net ([64.8.50.53])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 16vzS7-0003us-00
	for <nfs@lists.sourceforge.net>; Fri, 12 Apr 2002 04:42:51 -0700
To: Neil Brown <neilb@cse.unsw.edu.au>
In-Reply-To: <15542.19652.743976.342481@notabene.cse.unsw.edu.au>
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

On Fri, 12 Apr 2002, Neil Brown wrote:

> On Thursday April 11, shirsch@adelphia.net wrote:
> > 
> > Neil,
> > 
> > I finally got the chance to bang on this.  I'm not seeing anything 
> > queueing on port 32768, but during the period when 'pine' hangs there 
> > seems to be a large number number of requests on port 32771 server-side.  
> > At no point does the backlog fall below about 160.  What should I be 
> > seeing?
> 
> I'm perplexed...
> Is 32771 a local port or a remote port on the server?

It's the local port on the server.  The foreign end point is the client
with the hung 'pine' instance, port 799, 800, whatever.  All I can say is
to reiterate: whatever is going on between client:800 and server:32771
looks different on a correctly-operating NFSv3 TCP connection - it always
shows up as zero.  In the broken case, it never falls below 160 and
typically is up at 240.

> What I would expect you do see on the server if you do 
>        netstat -t
> is something like:
> Active Internet connections (w/o servers)
> Proto Recv-Q Send-Q Local Address           Foreign Address         State
> tcp        0      0 elfman.orchestra.c:2049 dulcimer.orchestra.:800 ESTABLISHED
> 
> The local address is "2049".
> The remote address could be anything.  My 2.4 Linux clients seem to
> choose 800, but anything is reasonable.
> 
> I would expect the see the Recv-Q and Send-Q jump around a lot when IO
> is happening, but settle to zero whenever it is quiet.

That's why I flagged the '160' minimum value as being suspicious.

> If the connection that you are looking at is the NFS connection
> (i.e. the other end is 2049) then the fact that it never gets below
> 160 suggests that I've got my accounting wrong somewhere. 
> The simplest option would be that sk_reserved goes negative, but I
> cannot see what would cause that...

It's definitely NOT the NFS connection.  I can see that as well, and it 
shows as zero.

Let me know what other information I can get for you?

Steve



_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
