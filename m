From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: Re: Will NFSv4 be accepted?
Date: 15 Aug 2002 02:35:27 +0100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <17552.9484441087$1029375532@news.gmane.org>
References: <Pine.LNX.4.44.0208141926030.31203-100000@mooru.gurulabs.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: "Kendrick M. Smith" <kmsmith@umich.edu>,
   "linux-kernel@vger.kernel.org"
	 <linux-kernel@vger.kernel.org>,
   "nfs@lists.sourceforge.net"
	 <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from pc2-cwma1-5-cust12.swa.cable.ntl.com ([80.5.121.12] helo=irongate.swansea.linux.org.uk)
	by usw-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 17f9Zi-0005Vp-00
	for <nfs@lists.sourceforge.net>; Wed, 14 Aug 2002 18:37:22 -0700
To: Dax Kelson <dax@gurulabs.com>
In-Reply-To: <Pine.LNX.4.44.0208141926030.31203-100000@mooru.gurulabs.com>
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

On Thu, 2002-08-15 at 02:27, Dax Kelson wrote:
> On 15 Aug 2002, Alan Cox wrote:
> 
> > Thats not an NFS2 or NFS3 issue, thats an implementation matter. A
> > proper NFS credential system prevents that from occurring. You also have
> > to fix some bogon assumptions in our NFS client too I grant. 
> 
> Please, do tell.

Ok item #1 you authenticate with the server and get a cryptographic key
for use as credentials. This solves the bad client problem. Kerberos,
gssapi etc will do the job

Item #2 is a bug in our NFS page cache handling. Its not legal in NFS to
assume we can share caches between processes unless they have the same
NFS credentials for the query. The most we can do (and should do) is
that when we think we can reuse a cache entry we issue an NFS ACCESS
check for NFSv3 or for NFSv2 we write it back to the server if dirty
then issue a read for the new credential set.




-------------------------------------------------------
This sf.net email is sponsored by: Dice - The leading online job board
for high-tech professionals. Search and apply for tech jobs today!
http://seeker.dice.com/seeker.epl?rel_code=31
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
