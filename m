From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: Re: Will NFSv4 be accepted?
Date: Thu, 15 Aug 2002 16:19:24 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <8774.09114405072$1029421271@news.gmane.org>
References: <shs8z39dr15.fsf@charged.uio.no>
	<200208142234.g7EMYvQ21700@tooting-fe.eng>
	<20020815062332.GB9122@umich.edu>
Reply-To: trond.myklebust@fys.uio.no
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Brian Pawlowski <beepy@netapp.com>,
    dax@gurulabs.com,
    torvalds@transmeta.com,
    kmsmith@umich.edu,
    linux-kernel@vger.kernel.org,
    nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from pat.uio.no ([129.240.130.16])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17fLTP-0004s2-00
	for <nfs@lists.sourceforge.net>; Thu, 15 Aug 2002 07:19:39 -0700
To: marius@citi.umich.edu
In-Reply-To: <20020815062332.GB9122@umich.edu>
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

>>>>> " " == marius aamodt eriksen <marius@umich.edu> writes:

     > and let's not forget such things as getting rid of the
     > representation of users as UIDs over the wire, as well as
     > delegations (i.e. better caching == better performance), named
     > (extended) attributes support, soon-to-come interoperability
     > with a vast array of operating systems, etc. etc.

Right. I wasn't saying that NFSv4 doesn't have anything going for
it. Just that Kerberos isn't the killer argument: it can easily be
integrated with earlier versions of NFS (and in fact Andy and I had
the basic Linux version running on NFSv3 in February *before* it was
tested for NFSv4).

IMHO the main argument for NFSv4 is the improved support for WANs.

Cheers,
  Trond


-------------------------------------------------------
This sf.net email is sponsored by: OSDN - Tired of that same old
cell phone?  Get a new here for FREE!
https://www.inphonic.com/r.asp?r=sourceforge1&refcode1=vs3390
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
