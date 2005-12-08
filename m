From: Neil Brown <neilb@suse.de>
Subject: Re: blocked remote subdirectories
Date: Thu, 8 Dec 2005 16:19:27 +1100
Message-ID: <17303.49759.151786.204513@cse.unsw.edu.au>
References: <E1EkBVL-0003Ee-9s@mail.sourceforge.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1EkEBu-0008Ku-QE
	for nfs@lists.sourceforge.net; Wed, 07 Dec 2005 21:19:38 -0800
Received: from mx2.suse.de ([195.135.220.15])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1EkEBt-0000oV-CU
	for nfs@lists.sourceforge.net; Wed, 07 Dec 2005 21:19:38 -0800
To: <info@tradebit.com>
In-Reply-To: message from Tradebit Service on Thursday December 8
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

On Thursday December 8, info@tradebit.com wrote:
> hi everybody,
> 
> for a few days now i run a new setup
> with NFS on RHEL4 (kmountd nfs-utils 1.0.6) and
> from our storage I serve a few hundred thousand
> files of all sizes to 3 other servers.
> 
> now, in these (around 14) days, I had 5 incidents of
> blocked subdirectories on the server from different clients.
> 
> 2 times the directory "came back" after a few minutes 
> (have seen that mail too late) and in the 3 other cases,
> it did not (maybe I was too fast).
> 
> for the time the dir is blocked, the failure looks
> like a rights mismanagement, but nothing changed it just
> denies access for minutes/hours.
> 
> the directories were deep in the dir tree, but random as
> it seems.
> 
> does anyone know, how to prevent that in the future?
> what could be the cause of these voodoo incidents?
> 
> any help appreciated,

Are you running a redhat kernel earlier than about April2005, and ext3
as the filesystem, and directory indexing enabled on the filesystem.

If so, you have hit a known bug.
Either turn off directory indexing (tune2fs) or upgrade your kernel.

NeilBrown


-------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc. Do you grep through log files
for problems?  Stop!  Download the new AJAX search engine that makes
searching your log files as easy as surfing the  web.  DOWNLOAD SPLUNK!
http://ads.osdn.com/?ad_id=7637&alloc_id=16865&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
