From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: Tracking rpc errors 'svc: unknown version (0)'
Date: 17 Jul 2002 17:09:24 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <shsr8i2tmqj.fsf@charged.uio.no>
References: <78B78720E680564CB7302950FA6CCF17D302EB@james.fs.apu.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from mons.uio.no ([129.240.130.14])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17UqQp-0006cP-00
	for <nfs@lists.sourceforge.net>; Wed, 17 Jul 2002 08:09:35 -0700
To: "Jarod Beekman" <JBeekman@apu.edu>
In-Reply-To: <78B78720E680564CB7302950FA6CCF17D302EB@james.fs.apu.edu>
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

>>>>> " " == Jarod Beekman <JBeekman@apu.edu> writes:

     > I upgraded our nfs server from 2.4.9-34 Redhat 7.2 to 2.4.18-5
     > Redhat
     > 7.3 and I am now seeing 'svc: unknown version (0)' errors.
     > Poking around on the list and the net tells me that this is a
     > reflection of an unrecognized rpc request.  Is this correct,
     > and if so is there a way to track down the source and nature of
     > the request?  Thanks for your help.

'ethereal' should be able to help you out here.
Just look for a null 'version' field in the RPC header: that should
tell you who and what the offender is.

If I were to hazard a guess, though, I'd expect that you will find
this is a NULL RPC request (i.e. the procedure number is '0') which is
often used in order to probe for whether or not an RPC server is up.

Cheers,
  Trond


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
