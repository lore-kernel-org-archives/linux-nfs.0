From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: can't get request slot, write timeout
Date: 12 Aug 2002 20:31:28 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <shseld4nd33.fsf@charged.uio.no>
References: <200208121444.g7CEiLB09220@serf0.cs.usyd.edu.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from pat.uio.no ([129.240.130.16])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17eJyb-000735-00
	for <nfs@lists.sourceforge.net>; Mon, 12 Aug 2002 11:31:38 -0700
To: bruce@it.usyd.edu.au (Bruce Janson)
In-Reply-To: <200208121444.g7CEiLB09220@serf0.cs.usyd.edu.au>
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

>>>>> " " == Bruce Janson <bruce@it.usyd.edu.au> writes:

     > The surprising thing about this error condition (which has been
     > reported on this list for a number of years now) is that under
     > such conditions the Linux NFS client code fails so
     > spectacularly.  Rather than performance degrading gracefully as
     > one might expect from a congested network (or a flaky NIC or a
     > marginal cable or a slow receiver or a client kernel RAM
     > shortage or ...) the kernel instead emits one or more

     >   can't get a request slot

     > messages and the affected transactions freeze for extended
     > periods (hours!).

If you know of a cure-all solution, feel free to send me patches...

Cheers,
  Trond


-------------------------------------------------------
This sf.net email is sponsored by: Dice - The leading online job board
for high-tech professionals. Search and apply for tech jobs today!
http://seeker.dice.com/seeker.epl?rel_code=31
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
