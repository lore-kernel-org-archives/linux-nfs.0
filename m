From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: Will NFSv4 be accepted?
Date: 15 Aug 2002 00:17:10 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <46032.4423075237$1029364238@news.gmane.org>
References: <Pine.LNX.4.44.0208141435210.30333-100000@mooru.gurulabs.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: torvalds@transmeta.com,  "Kendrick M. Smith" <kmsmith@umich.edu>,
	  "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	  "nfs@lists.sourceforge.net" <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from pat.uio.no ([129.240.130.16])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17f6SA-0000Zs-00
	for <nfs@lists.sourceforge.net>; Wed, 14 Aug 2002 15:17:23 -0700
To: Dax Kelson <dax@gurulabs.com>
In-Reply-To: <Pine.LNX.4.44.0208141435210.30333-100000@mooru.gurulabs.com>
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

>>>>> " " == Dax Kelson <dax@gurulabs.com> writes:

     > I for one would REALLY like to see NFSv4 (actually, Kerberized
     > NFSv4 is what I'm after).  I just finished setting up a
     > Kerberized Solaris NFS environment with home directories
     > automounted from the clients with strong user authentication.

     > Frankly, the stock (non-Kerberized) NFS security model blows.

Note: The RPCSEC_GSS (and accompanying kerberos) stuff is completely
independent of NFSv4. It is still in the process of being finalized,
but when it is, it will apply to NFSv2/v3 as well as v4.

RPCSEC_GSS is not an argument for NFSv4...

Cheers,
  Trond


-------------------------------------------------------
This sf.net email is sponsored by: Dice - The leading online job board
for high-tech professionals. Search and apply for tech jobs today!
http://seeker.dice.com/seeker.epl?rel_code=31
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
