From: Neil Brown <neilb@cse.unsw.edu.au>
Subject: Re: nfs over TCP stable?
Date: Wed, 7 May 2003 15:10:43 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <16056.38227.737438.560424@notabene.cse.unsw.edu.au>
References: <3EB44527.6090005@wanadoo.es>
	<3EB64B13.2080401@RedHat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.28] ident=root)
	by sc8-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19DHCZ-00010l-00
	for <nfs@lists.sourceforge.net>; Tue, 06 May 2003 22:10:47 -0700
Received: From
	notabene.cse.unsw.edu.au ([129.94.211.194] == dulcimer.orchestra.cse.unsw.EDU.AU)
	(for <SteveD@redhat.com>) (for <nfs@lists.sourceforge.net>) By tone
	With Smtp ; Wed, 7 May 2003 15:10:41 +1000
To: Steve Dickson <SteveD@redhat.com>
In-Reply-To: message from Steve Dickson on Monday May 5
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

On Monday May 5, SteveD@redhat.com wrote:
> The client works fairly well due to the simple fact
> a number of people are using it in production today.
> 
> The server seems to have issues around flow control. When
> a server is unable to send back replies due to an EGAIN error,
> it resets the connection; Clearly, IMHO, not the correct way
> to hand this error.
> 
> It has been suggested to me, I and think I agree, that the
> I/O processing of the NFS server should be broken up into
> to threads. A RX and TX thread. With the idea being when the
> TX thread starts to get backed up, it turns off the RX thread
> (i.e. stops it from receiving) which in turn will flow-control
> sending client. This should allow the TX thread to be able
> to catch up...

Well... there are lots of threads, and each one will either be
receiving or transmitting (or working) at any time.  So maybe we
already have that.

Also, the reception of new requests is blocked when there is more than
some set amount of replies pending to be sent.

However the total size of reply buffers is scaled by the number of
nfsd threads that are run, and possibly this gets set too large so the
server runs out of kmallocable memory.
And what do you do when you have accepted a request, processed it, and
now cannot send a reply.
If you block, and every other thread blocks, you get a deadlock and
no-one ever releases their memory and nothing happens.

You really have to drop the request and it is only  fair when you do
that to also drop the tcp connection.

So maybe the problem is that the transmit buffers should be smaller so
the flow control hits earlier.
Currently every TCP connection has a big enough buffer that every
thread can be responding to a request at the same time.  Maybe that
should be scaled back when there are more active connections.
Or maybe whenever a connection is closed do to flow control problems,
we reduce the size of buffers by half, and then slowly increase them
while everything is fine ... or maybe some other heuristic.


> 
> The duel io threads might also be handy if NFSD decide
> to use AIO....

I cannot see how AIO would really help NFSD.  Having lots of threads
each doing one thing at a time seems to work quite well inside the
kernel.

But I'm willing to be educated.

NeilBrown


-------------------------------------------------------
Enterprise Linux Forum Conference & Expo, June 4-6, 2003, Santa Clara
The only event dedicated to issues related to Linux enterprise solutions
www.enterpriselinuxforum.com

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
