From: "Steven N. Hirsch" <shirsch@adelphia.net>
Subject: Re: 2.4.19-pre5-ac3 NFS problems
Date: Thu, 11 Apr 2002 07:54:17 -0400 (EDT)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.LNX.4.44.0204110751100.7442-100000@atx.fast.net>
References: <Pine.LNX.4.44.0204110730460.6902-100000@atx.fast.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Neil Brown <neilb@cse.unsw.edu.au>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from smtprelay8.dc2.adelphia.net ([64.8.50.40])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 16vd2Z-0005hl-00
	for <nfs@lists.sourceforge.net>; Thu, 11 Apr 2002 04:47:00 -0700
To: nfs@lists.sourceforge.net
In-Reply-To: <Pine.LNX.4.44.0204110730460.6902-100000@atx.fast.net>
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

On Thu, 11 Apr 2002, Steven N. Hirsch wrote:

> On Mon, 8 Apr 2002, Neil Brown wrote:
> 
> > On Sunday April 7, shirsch@adelphia.net wrote:
> 
> > > I'm not sure exactly what has been integrated into Alan's pre5-ac3 kernel,
> > > but there are serious problems with NFS over TCP.  Twice in a row I've had
> > > locked processes on the client when attempting to lock a mail spool on the
> > > server.  Required reboot on both ends to clear :-(.
> > > 
> 
> > I am interest to know if  
> >   "netstat -t"
> > shows anything on the input queue for the lockd connection: quite
> > possibly the connection to port 32768.
> 
> Neil,
> 
> I finally got the chance to bang on this.  I'm not seeing anything 
> queueing on port 32768, but during the period when 'pine' hangs there 
> seems to be a large number number of requests on port 32771 server-side.  
> At no point does the backlog fall below about 160.  What should I be 
> seeing?

Following up on my own followup..  When I restart the server with 
2.4.19-pre2 + Trond's older TCP server patch (which I had been using for 
some weeks incident-free), I'm never seeing anything backed up on high 
port numbers.  With your TCP server patch, it's permanently backlogged at 
numbers which are never < 160.

Hopefully this provides a clue to underlying problem?

Steve



_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
