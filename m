From: Dax Kelson <dax@gurulabs.com>
Subject: Will NFSv4 be accepted?
Date: Wed, 14 Aug 2002 14:49:30 -0600 (MDT)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.LNX.4.44.0208141435210.30333-100000@mooru.gurulabs.com>
References: <Pine.SOL.4.44.0208131901270.25942-100000@rastan.gpcc.itd.umich.edu>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
    "nfs@lists.sourceforge.net" <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from mail.gurulabs.com ([208.177.141.7] ident=you)
	by usw-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17f55B-000748-00
	for <nfs@lists.sourceforge.net>; Wed, 14 Aug 2002 13:49:33 -0700
To: torvalds@transmeta.com, "Kendrick M. Smith" <kmsmith@umich.edu>
In-Reply-To: <Pine.SOL.4.44.0208131901270.25942-100000@rastan.gpcc.itd.umich.edu>
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


Linus, I'm curious if the NFSv4 patches will be accepted in the near 
future (ie, before 2.6).

I for one would REALLY like to see NFSv4 (actually, Kerberized NFSv4 is 
what I'm after).   I just finished setting up a Kerberized Solaris NFS 
environment with home directories automounted from the clients with 
strong user authentication.

Frankly, the stock (non-Kerberized) NFS security model blows.

The fact that any janitor with a laptop (or any client with a malicious
root user) can nuke all home directories from a standard NFS home
directory server bothers me greatly.

Dax Kelson
Guru Labs



-------------------------------------------------------
This sf.net email is sponsored by: Dice - The leading online job board
for high-tech professionals. Search and apply for tech jobs today!
http://seeker.dice.com/seeker.epl?rel_code=31
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
