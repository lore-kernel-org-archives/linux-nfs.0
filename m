From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: Re: Will NFSv4 be accepted?
Date: 15 Aug 2002 02:09:47 +0100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <21654.7858472497$1029374038@news.gmane.org>
References: <Pine.LNX.4.44.0208141435210.30333-100000@mooru.gurulabs.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Linus Torvalds <torvalds@transmeta.com>,
   "Kendrick M. Smith"
	 <kmsmith@umich.edu>,
   "linux-kernel@vger.kernel.org"
	 <linux-kernel@vger.kernel.org>,
   "nfs@lists.sourceforge.net"
	 <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from pc2-cwma1-5-cust12.swa.cable.ntl.com ([80.5.121.12] helo=irongate.swansea.linux.org.uk)
	by usw-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 17f9Aw-00061u-00
	for <nfs@lists.sourceforge.net>; Wed, 14 Aug 2002 18:11:46 -0700
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

On Wed, 2002-08-14 at 21:49, Dax Kelson wrote:
> The fact that any janitor with a laptop (or any client with a malicious
> root user) can nuke all home directories from a standard NFS home
> directory server bothers me greatly.

Thats not an NFS2 or NFS3 issue, thats an implementation matter. A
proper NFS credential system prevents that from occurring. You also have
to fix some bogon assumptions in our NFS client too I grant. 

Alan (who is rapidly becoming an intermezzo freak instead)


-------------------------------------------------------
This sf.net email is sponsored by: Dice - The leading online job board
for high-tech professionals. Search and apply for tech jobs today!
http://seeker.dice.com/seeker.epl?rel_code=31
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
