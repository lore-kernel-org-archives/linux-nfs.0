From: Neil Brown <neilb@cse.unsw.edu.au>
Subject: Re: fh_verify
Date: Tue, 3 Sep 2002 12:23:11 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <15732.7439.949607.498380@notabene.cse.unsw.edu.au>
References: <003901c252d9$d92bea70$9300a8c0@gridlock>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "nfs" <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.28])
	by usw-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17m3Lh-000728-00
	for <nfs@lists.sourceforge.net>; Mon, 02 Sep 2002 19:23:25 -0700
Received: From
	notabene.cse.unsw.edu.au ([129.94.233.85] == wireless-085.wireless.cse.unsw.EDU.AU)
	(for <nlafferty@pennswoods.net>) (for <nfs@lists.sourceforge.net>) By
	tone With Smtp ; Tue, 3 Sep 2002 12:23:12 +1000
To: "Nicholas Lafferty" <nlafferty@pennswoods.net>
In-Reply-To: message from Nicholas Lafferty on Monday September 2
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

On Monday September 2, nlafferty@pennswoods.net wrote:
> I have recently set up a lan with three New Internet Computers booting off
> the network as outlined in the article (
> http://www.dnalounge.com/backstage/src/kiosk ) . After many atempts I have
> finally gotten ALMOST a booting client.
> I have been alternating testing with SysVinit and Busybox's init. If I use
> the normal init I get errors on the NFS server about fh_verify: /etc/shadow
> permission failure. As soon as inittab is read. I get the same errors when I
> run sulogin. If I rename the inittab out of the way I can only boot in
> single mode.
> 
> If I use busybox it will boot. But I can not start X and I get the same
> errors.
> 
> Any clue? Any help would be great.

Sounds like you need the
   no_root_squash
in you /etc/exports.  You definately need this for exporting a root
filesystem.

NeilBrown


-------------------------------------------------------
This sf.net email is sponsored by: OSDN - Tired of that same old
cell phone?  Get a new here for FREE!
https://www.inphonic.com/r.asp?r=sourceforge1&refcode1=vs3390
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
