From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: Stale File handles keep coming back
Date: Sat, 30 Apr 2005 12:29:38 -0400
Message-ID: <1114878578.14213.6.camel@lade.trondhjem.org>
References: <1114463253.2487.73.camel@localhost.localdomain>
	 <17006.13241.129839.558300@cse.unsw.edu.au>
	 <1114554149.4470.5.camel@localhost.localdomain>
	 <17006.64544.860436.620665@cse.unsw.edu.au>
	 <4271DBB3.3090402@bio.ifi.lmu.de>
	 <1114783702.10086.25.camel@lade.trondhjem.org>
	 <427384DE.6050208@bio.ifi.lmu.de>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Neil Brown <neilb@cse.unsw.edu.au>,
	Kris Vassallo <kris@linuxcertified.com>, nfs@lists.sourceforge.net,
	Olaf Kirch <okir@suse.de>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DRuqs-0007jz-Ow
	for nfs@lists.sourceforge.net; Sat, 30 Apr 2005 09:29:58 -0700
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1DRuqr-0007o4-7h
	for nfs@lists.sourceforge.net; Sat, 30 Apr 2005 09:29:58 -0700
To: Frank Steiner <fsteiner-mail@bio.ifi.lmu.de>
In-Reply-To: <427384DE.6050208@bio.ifi.lmu.de>
Sender: nfs-admin@lists.sourceforge.net
Errors-To: nfs-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

On lau , 2005-04-30 at 15:15 +0200, Frank Steiner wrote:

> reiserfs v3 on both servers (PC and pSeries).

Is the superblock in reiserfs 3.6 format? What
does /proc/fs/reiserfs/<partition>/version say?

If the format is older than 3.6, then you should convert it if you want
to export it through NFS. To do so, you can use the "-oconv" option when
mounting the filesystem (see the reiserfs section in the mount manpage).

Cheers,
  Trond



-------------------------------------------------------
This SF.Net email is sponsored by: NEC IT Guy Games.
Get your fingers limbered up and give it your best shot. 4 great events, 4
opportunities to win big! Highest score wins.NEC IT Guy Games. Play to
win an NEC 61 plasma display. Visit http://www.necitguy.com/?r=20
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
