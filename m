From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: A Question about the 2.4.21 Pathconf patch
Date: 29 Apr 2003 18:22:17 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <shs4r4h5l52.fsf@charged.uio.no>
References: <3EAE956E.9080205@RedHat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from pat.uio.no ([129.240.130.16])
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19AXs7-0004Br-00
	for <nfs@lists.sourceforge.net>; Tue, 29 Apr 2003 09:22:23 -0700
To: Steve Dickson <SteveD@RedHat.com>
In-Reply-To: <3EAE956E.9080205@RedHat.com>
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

>>>>> " " == Steve Dickson <SteveD@RedHat.com> writes:

     > but doesn't it make sense to use it with v3 or am I missing
     > something here.  I would think that if the server sent some
     > numbers that the client couldn't handle,

     > the client would simple fail the mount...

Why would we want to succeed in that case? If the server operates with
some screwed up set of parameters that we are incapable of supporting,
surely the best thing to do is to fail immediately?

Note: Most of the functionality of NFSPROC3_FSINFO *is* in fact in v2,
but it is either part of NFSPROC_STATFS, or (shudder) has been tacked
onto the mount protocol.

Cheers,
  Trond


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
