From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: 2.4.18: NFS_ALL patch greatly hurting UDP speed
Date: Wed, 20 Mar 2002 16:45:01 +0100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <15512.44669.95177.801025@charged.uio.no>
References: <3C88F8EE.86058BD5@sls.lcs.mit.edu>
	<shs7kollatu.fsf@charged.uio.no>
	<3C98AD4B.8244EDC0@sls.lcs.mit.edu>
Reply-To: trond.myklebust@fys.uio.no
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Received: from pat.uio.no ([129.240.130.16])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 16niH5-00087f-00
	for <nfs@lists.sourceforge.net>; Wed, 20 Mar 2002 07:45:15 -0800
To: I Lee Hetherington <ilh@sls.lcs.mit.edu>
In-Reply-To: <3C98AD4B.8244EDC0@sls.lcs.mit.edu>
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

>>>>> " " == I Lee Hetherington <I> writes:

     > Did you ever get a chance to look at the tcpdumps I sent you?
     > Given that UDP is now *100* times slower with NFS_ALL
     > vs. without, something is fishy.  We have always gotten good
     > performance with UDP in our network, even with the 1Gb/s to
     > 100Mb/s switching.  Maybe our switches have big enough buffers
     > to deal with the peaks.

     > --Lee Hetherington

Yes. I already sent you a breakdown based on those tcpdumps. Here it is
again.

Cheers,
  Trond

----

Interesting... On the 2.2.18 vanilla, the system is settling in a routine
where the client only sends 1 request at a time, and then waits for the
answer.

On 2.2.18 w/ NFS_ALL, the client attempts to send off 6 requests, but only
gets answered *very* slowly (one request at a time). Eventually (line number
113 in the tcpdump sequence) the replies start to miss fragments, and this is
where the problem starts...

My guess is that while you are able to send off 1 request at a time, the GigE
-> 100Mbit bridge is able to cache the replies. As the the number of
'simultaneous' replies being sent off by the server increases, though, the
bridge is no longer able to cache enough, and so it starts to truncate the
messages (and the NFS read requests have to time out and retry).
Another sign of this is the fact that in the NFS_ALL tcpdump, there are
assorted 'Time-to-live exceeded' ICMP messages littered around the place. The
first one comes just after the loss of fragments, and is accompanied by a 2
second delay, during which all the reads that are sent time out without
receiving a single reply...

Basically, as I said before, you are in a situation where TCP should always
be able to outperform UDP. I'm a bit surprised that this is not the case for
'vanilla' 2.2.18.

Cheers,
  Trond


_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
