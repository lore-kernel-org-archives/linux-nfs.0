From: "Steven N. Hirsch" <shirsch@adelphia.net>
Subject: Re: 2.4.19-pre5-ac3 NFS problems
Date: Mon, 8 Apr 2002 07:12:03 -0400 (EDT)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.LNX.4.44.0204080708000.3713-100000@atx.fast.net>
References: <15537.631.242570.416618@notabene.cse.unsw.edu.au>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: nfs@lists.sourceforge.net
Received: from smtprelay7.dc2.adelphia.net ([64.8.50.39])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 16uWx3-00030J-00
	for <nfs@lists.sourceforge.net>; Mon, 08 Apr 2002 04:04:45 -0700
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
> > All,
> > 
> > I'm not sure exactly what has been integrated into Alan's pre5-ac3 kernel,
> > but there are serious problems with NFS over TCP.  Twice in a row I've had
> > locked processes on the client when attempting to lock a mail spool on the
> > server.  Required reboot on both ends to clear :-(.
> > 
> > FWIW, I had been running for almost a month prior with 2.4.19-pre2 + 
> > Trond's 2.4.18_NFS_ALL using NFS over TCP and saw no problems.  I moved to 
> > the new kernel ONLY on the server.  After reverting back, all seems stable 
> > again.
> > 
> > What is the current status of the various 2.4.x patches floating around?  
> 
> 2.4.19-pre5-ac3 has my TCP (and SMP) patches that are in 2.5, but
> aren't ready for 2.4.real yet as they haven't had enough
> testing... thanks for doing some testing.
> 
> How repeatable is the problem?  Simple locking seems to work for me,
> so presumably it is some particular combination or load..

It seems fairly easy to trip.  I was able to hang it two or three times in 
a row by simply attempting to open a non-default mail folder with pine.  
Pine relies (I think) on trickery with lock files, rather than flock().

> Are you in a position you get it to fail again, or would that be
> inconvenient?

No problem.  I'll try to make some time this evening for testing.

> I am interest to know if  
>   "netstat -t"
> shows anything on the input queue for the lockd connection: quite
> possibly the connection to port 32768.
> 
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
> 
> Are you using NFSv2 or NFSv3?

This was with v3 mounts.  Also, client was 2.4.19-pre2 + Tronds 2.4.18 
NFS_ALL patch.  The _server_ was using ac3.

Steve


_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
