From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: Re: Re: Will NFSv4 be accepted?
Date: 15 Aug 2002 02:10:29 +0100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <36912.9300503575$1029374067@news.gmane.org>
References: <200208142234.g7EMYvQ21700@tooting-fe.eng>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Trond Myklebust <trond.myklebust@fys.uio.no>, dax@gurulabs.com,
   Linus
	Torvalds <torvalds@transmeta.com>, kmsmith@umich.edu,
   linux-kernel@vger.kernel.org, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from pc2-cwma1-5-cust12.swa.cable.ntl.com ([80.5.121.12] helo=irongate.swansea.linux.org.uk)
	by usw-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 17f9Bi-0006BG-00
	for <nfs@lists.sourceforge.net>; Wed, 14 Aug 2002 18:12:35 -0700
To: Brian Pawlowski <beepy@netapp.com>
In-Reply-To: <200208142234.g7EMYvQ21700@tooting-fe.eng>
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

On Wed, 2002-08-14 at 23:34, Brian Pawlowski wrote:
> But ACL support over the wire is an argument for V4 - and fine grained
> authorization coupled to strong authentication makes for a flexible 
> security package.

ACL works in NFSv2 and nicely in NFSv3 - again the problems Linux has
are the client failing to respect basic NFS rules of operation.



-------------------------------------------------------
This sf.net email is sponsored by: Dice - The leading online job board
for high-tech professionals. Search and apply for tech jobs today!
http://seeker.dice.com/seeker.epl?rel_code=31
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
