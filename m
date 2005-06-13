From: Neil Brown <neilb@cse.unsw.edu.au>
Subject: Re: Exportfs does not accept Knoppix /ramdisk/home
Date: Tue, 14 Jun 2005 09:28:33 +1000
Message-ID: <17070.5793.185404.226427@cse.unsw.edu.au>
References: <42AE148E.80904@mindspring.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DhyMH-0001tG-4J
	for nfs@lists.sourceforge.net; Mon, 13 Jun 2005 16:28:45 -0700
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.41)
	id 1DhyMF-00041V-Kt
	for nfs@lists.sourceforge.net; Mon, 13 Jun 2005 16:28:45 -0700
To: Larry Alkoff <labradley@mindspring.com>
In-Reply-To: message from Larry Alkoff on Monday June 13
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

On Monday June 13, labradley@mindspring.com wrote:
> 
> Can you tell me why exportfs isn't working with the home ramdisk and
> suggest any workarounds?

I assume it is actually a tmpfs rather than a regular filesystem on a
true ramdisk ? (what does 'cat /proc/mounts' show?)

A tmpfs doesn't have a stable identifier (like a device number) to use
to identify the filesystem.  You need to give it one.
Try adding
   fsid=27
to the export options for the problematic filesystem. e.g.

/ramdisk/home/knoppix   knoppix(sync,rw,no_root_squash,fsid=27)

NeilBrown



-------------------------------------------------------
This SF.Net email is sponsored by: NEC IT Guy Games.  How far can you shotput
a projector? How fast can you ride your desk chair down the office luge track?
If you want to score the big prize, get to know the little guy.  
Play to win an NEC 61" plasma display: http://www.necitguy.com/?r=20
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
