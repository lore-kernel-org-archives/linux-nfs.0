From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: NFS on a freeswan gateway?
Date: 25 Jun 2002 01:13:36 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <shsptygs21r.fsf@charged.uio.no>
References: <20020624223641.GA16108@backlot.linas.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from pat.uio.no ([129.240.130.16])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17Md1n-00014o-00
	for <nfs@lists.sourceforge.net>; Mon, 24 Jun 2002 16:13:47 -0700
To: linas@linas.org (Linas Vepstas)
In-Reply-To: <20020624223641.GA16108@backlot.linas.org>
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

>>>>> " " == Linas Vepstas <linas@linas.org> writes:

     > Hi, I am resending a message sent to the freeswan mailing list.
     > As explained below, the default IP source address used in nfs
     > mount requests is sometimes 'not appropriate' for certain
     > packet-filtering/freeswan setups.

     > I'd like to patch that part of the nfs/rpc client so that it
     > uses an IP source address that is routing-wise 'closer' to the
     > nfs server.  But I have damned little experience with the nfs
     > kernel code (or nfs internals), and thus would like an opinion,
     > or commnts, or, best yet, a pointer to a pre-existing patch.

Both the client and the server use the standard IP socket layer
code. There is no magic... IOW if ordinary sendmsg()/recvmsg() of UDP
packets over the ipsec0 interface works (and the resulting address in
the struct msghdr is correct) then NFS should work fine.

If, however, you are trying to use NAT or masquerading or something
like that on the FreeSWAM gateways in order to translate 'internal
addresses' into 'external addresses', then you are screwed: NAT is not
an appropriate protocol for UDP services.

Cheers,
  Trond


-------------------------------------------------------
Sponsored by:
ThinkGeek at http://www.ThinkGeek.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
