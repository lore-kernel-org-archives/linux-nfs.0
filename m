From: "Steven N. Hirsch" <shirsch@adelphia.net>
Subject: Re: 2.4.19-pre5-ac3 NFS problems
Date: Thu, 11 Apr 2002 07:38:12 -0400 (EDT)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.LNX.4.44.0204110730460.6902-100000@atx.fast.net>
References: <15537.631.242570.416618@notabene.cse.unsw.edu.au>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from smtprelay6.dc2.adelphia.net ([64.8.50.38])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 16vcn0-0002W6-00
	for <nfs@lists.sourceforge.net>; Thu, 11 Apr 2002 04:30:54 -0700
To: Neil Brown <neilb@cse.unsw.edu.au>
In-Reply-To: <15537.631.242570.416618@notabene.cse.unsw.edu.au>
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

On Mon, 8 Apr 2002, Neil Brown wrote:

> On Sunday April 7, shirsch@adelphia.net wrote:

> > I'm not sure exactly what has been integrated into Alan's pre5-ac3 kernel,
> > but there are serious problems with NFS over TCP.  Twice in a row I've had
> > locked processes on the client when attempting to lock a mail spool on the
> > server.  Required reboot on both ends to clear :-(.
> > 

> I am interest to know if  
>   "netstat -t"
> shows anything on the input queue for the lockd connection: quite
> possibly the connection to port 32768.

Neil,

I finally got the chance to bang on this.  I'm not seeing anything 
queueing on port 32768, but during the period when 'pine' hangs there 
seems to be a large number number of requests on port 32771 server-side.  
At no point does the backlog fall below about 160.  What should I be 
seeing?

The problem is triggered 100% of the time when I try to open a secondary 
mail folder on the server.  It looks like a zero-length lock file is being 
created, but the process simply hangs at that point.  My incoming folder 
is on the client and there are never any problems with that.

Another point: There is very little (to zero) activity on the network at 
the time of the hangs.

> The only change that I can imagine might cause  the client to hang is
> the flow control that I added to the RPC layer: It won't accept a
> request unless it is sure there will be room on the output queue for
> the response.
> For lockd, it makes extremely large estimates for the response size (I
> was a bit lazy) which shouldn't be a problem except that it might slow
> down lock requests if there are lots and lots of them, but maybe it
> is.
> 
> Would you be able to try a patch that makes more realistic estimates
> of lockd response sizes?

Sure, fire away.  This is all with NFSv3 over tcp.

Steve



_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
