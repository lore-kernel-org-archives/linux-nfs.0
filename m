From: "Kendrick M. Smith" <kmsmith@umich.edu>
Subject: REPOST: nfsv4 patches
Date: Wed, 14 Aug 2002 16:35:28 -0400 (EDT)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <10814.8428299048$1029357675@news.gmane.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from donkeykong.gpcc.itd.umich.edu ([141.211.2.163])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17f4rd-0002xg-00
	for <nfs@lists.sourceforge.net>; Wed, 14 Aug 2002 13:35:33 -0700
To: linux-kernel@vger.kernel.org, <nfs@lists.sourceforge.net>
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


Due to a boneheaded mistake in a script I wrote, I accidently
posted NFSv4 patches against 2.5.28 yesterday instead of 2.5.31!

Therefore, with my tail between my legs, I'm reposting the
patchset, against 2.5.31 this time.

Since I have to repost, I went ahead and implemented two
changes suggested by Christoph Hellwig:
 - reorder patchset: put changes to fs/Config.in last
 - remove noisy printk from nfsd_svc()

Instructions for running NFSv4 can still be found at
  www.citi.umich.edu/projects/nfsv4/patches-2.5

Sorry for the inconvenience,
 Kendrick



-------------------------------------------------------
This sf.net email is sponsored by: Dice - The leading online job board
for high-tech professionals. Search and apply for tech jobs today!
http://seeker.dice.com/seeker.epl?rel_code=31
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
