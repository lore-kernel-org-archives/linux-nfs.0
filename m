From: Neil Brown <neilb@cse.unsw.edu.au>
Subject: Re: NFS Performance issues
Date: Wed, 11 May 2005 16:14:24 +1000
Message-ID: <17025.41664.754710.970555@cse.unsw.edu.au>
References: <BEA6E6AA.11AD0%jblock@mrsc.ucsf.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DVkUp-0005wS-Cv
	for nfs@lists.sourceforge.net; Tue, 10 May 2005 23:15:03 -0700
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.59] ident=root)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.41)
	id 1DVkUK-0002mB-Hr
	for nfs@lists.sourceforge.net; Tue, 10 May 2005 23:15:03 -0700
To: Jeff Block <jblock@mrsc.ucsf.edu>
In-Reply-To: message from Jeff Block on Tuesday May 10
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

On Tuesday May 10, jblock@mrsc.ucsf.edu wrote:
> 
> We've tried moving the journaling from RAID devices onto another internal
> disk.  This helped a little, but not much.
> 

Are you using ext3?
Have you tried the "data=journal" mount option.  It speeds up NFS
writes a lot.

NeilBrown


-------------------------------------------------------
This SF.Net email is sponsored by Oracle Space Sweepstakes
Want to be the first software developer in space?
Enter now for the Oracle Space Sweepstakes!
http://ads.osdn.com/?ad_id=7393&alloc_id=16281&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
