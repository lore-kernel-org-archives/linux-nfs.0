From: Dax Kelson <dax@gurulabs.com>
Subject: Re: Will NFSv4 be accepted?
Date: Wed, 14 Aug 2002 19:51:56 -0600 (MDT)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.LNX.4.44.0208141938350.31203-100000@mooru.gurulabs.com>
References: <1029375327.28240.35.camel@irongate.swansea.linux.org.uk>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "Kendrick M. Smith" <kmsmith@umich.edu>,
    "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
    "nfs@lists.sourceforge.net" <nfs@lists.sourceforge.net>,
     <beepy@netapp.com>,  <trond.myklebust@fys.uio.no>,
     <torvalds@transmeta.com>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from mail.gurulabs.com ([208.177.141.7] ident=you)
	by usw-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17f9nq-0001MG-00
	for <nfs@lists.sourceforge.net>; Wed, 14 Aug 2002 18:51:58 -0700
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
In-Reply-To: <1029375327.28240.35.camel@irongate.swansea.linux.org.uk>
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


Q for Linus: What's the prospect of adding crypto to the kernel?

(more below)

On 15 Aug 2002, Alan Cox wrote:

> Ok item #1 you authenticate with the server and get a cryptographic key
> for use as credentials. This solves the bad client problem. Kerberos,
> gssapi etc will do the job

Right, I do understand that Kerberized/GSS NFS is not exclusive to NFSv4.  
However, right now, there is only one way to get Kerberized NFS. The CITI
NFSv4 patches.

Those patches are, in their estimation, ready for inclusion.  NFSv3 
support is "coming down the pipeline". 

I would rather see Kerberos V5 NFS data integrity and privacy support
first (also in the pipeline).  What the current status of including crypto
in the kernel?

> Item #2 is a bug in our NFS page cache handling. Its not legal in NFS to
> assume we can share caches between processes unless they have the same
> NFS credentials for the query. 

I wasn't aware of this.

Thanks,
Dax



-------------------------------------------------------
This sf.net email is sponsored by: Dice - The leading online job board
for high-tech professionals. Search and apply for tech jobs today!
http://seeker.dice.com/seeker.epl?rel_code=31
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
