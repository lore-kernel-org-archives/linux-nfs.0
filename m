From: James Bottomley <James.Bottomley@steeleye.com>
Subject: Re: High Availability NFS Proposal
Date: Sun, 25 Aug 2002 23:51:22 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <200208260451.g7Q4pM325746@localhost.localdomain>
References: <bos@serpentine.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: James Bottomley <James.Bottomley@SteelEye.com>, nfs@lists.sourceforge.net,
        lmb@suse.de
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from host194.steeleye.com ([216.33.1.194] helo=pogo.mtv1.steeleye.com)
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17jBr3-0005gI-00
	for <nfs@lists.sourceforge.net>; Sun, 25 Aug 2002 21:51:57 -0700
Received: (from root@localhost)
	by pogo.mtv1.steeleye.com (8.9.3/8.9.3) id VAA30542
	for <nfs@lists.sourceforge.net>; Sun, 25 Aug 2002 21:51:56 -0700
To: "Bryan O'Sullivan" <bos@serpentine.com>
In-Reply-To: Message from "Bryan O'Sullivan" <bos@serpentine.com>
   of "25 Aug 2002 21:36:33 PDT." <1030336593.11097.11.camel@camp4.serpentine.com>
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

bos@serpentine.com said:
> What would you plan on sharing via these hooks that isn't already
> maintained in /var/lib/nfs?  Why not use dnotify to capture changes to
> those files, and push them out as clients come and go? 

Extra information for statd would pertain to virtual host, but by and large, 
the information is identical.  Dnotify won't work because in order to close 
race windows, the cluster has to be an active participant (i.e. mountd may not 
reply until the cluster confirms it has the information), it can't just wait 
on triggers.

James




-------------------------------------------------------
This sf.net email is sponsored by: OSDN - Tired of that same old
cell phone?  Get a new here for FREE!
https://www.inphonic.com/r.asp?r=sourceforge1&refcode1=vs3390
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
