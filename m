From: YAMAMOTO Takashi <yamamoto@valinux.co.jp>
Subject: Re: [PATCH kNFSd ] Check error status from vfs_getattr and
 i_op->fsync
Date: Tue, 13 Dec 2005 09:10:42 +0900
Message-ID: <1134432642.095526.2354.nullmailer@yamt.dyndns.org>
References: <17309.1680.482774.920851@cse.unsw.edu.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Cc: akpm@osdl.org, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1ElxlH-0004PN-NR
	for nfs@lists.sourceforge.net; Mon, 12 Dec 2005 16:11:19 -0800
Received: from fla1aai163.kng.mesh.ad.jp ([61.193.102.163] helo=yamt.dyndns.org)
	by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1ElxlG-0005p0-7p
	for nfs@lists.sourceforge.net; Mon, 12 Dec 2005 16:11:19 -0800
To: neilb@suse.de
In-Reply-To: Your message of "Mon, 12 Dec 2005 16:11:44 +1100"
	<17309.1680.482774.920851@cse.unsw.edu.au>
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

> > it reminded me of a similar diff in our local tree.  (attached)
> > it's fsync part only but more complete.
> > 
> 
> Thanks.  I've merged and revised it a bit and will submit it shortly.

thanks.

> Are there any other nfs patches in your local tree that you would like
> to share ?? ;-)

i'll send you and/or this list if suitable ones are digged up.
not today, tho. :-)

YAMAMOTO Takashi


-------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc. Do you grep through log files
for problems?  Stop!  Download the new AJAX search engine that makes
searching your log files as easy as surfing the  web.  DOWNLOAD SPLUNK!
http://ads.osdn.com/?ad_id=7637&alloc_id=16865&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
