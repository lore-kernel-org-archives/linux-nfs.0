From: Neil Brown <neilb@suse.de>
Subject: Re: Mounting DVDs via NFS problem
Date: Mon, 23 Jan 2006 13:54:34 +1100
Message-ID: <17364.17770.366712.686773@cse.unsw.edu.au>
References: <43D3C685.9040804@biased.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1F0rqy-0001KM-0z
	for nfs@lists.sourceforge.net; Sun, 22 Jan 2006 18:54:48 -0800
Received: from ns1.suse.de ([195.135.220.2] helo=mx1.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1F0rqw-0001dT-Re
	for nfs@lists.sourceforge.net; Sun, 22 Jan 2006 18:54:48 -0800
To: Piers Kittel <debian@biased.org>
In-Reply-To: message from Piers Kittel on Sunday January 22
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

On Sunday January 22, debian@biased.org wrote:
> Hello all,
> 
> Am trying to mount a DVD drive via NFS and am having problems.  For
> note, 192.168.1.2 (hostname - destiny) is the client and 192.168.1.15
> (hostname - mythtv) is the server.
> 
> I have this in my /etc/exports:
> 
> /media/cdrom0 192.168.1.2(ro,sync)
> 
> and 192.168.1.2 is in the /etc/hosts.allow.
> 
> If the DVD is not mounted, it works perfectly fine:
> 
> destiny:/mnt# mount mythtv:/media/cdrom0 /mnt/mythtv
> destiny:/mnt# df
> Filesystem           1K-blocks      Used Available Use% Mounted on
> <snip>
> mythtv:/media/cdrom0   1829192   1547128    184472  90% /mnt/mythtv
> destiny:/mnt#
> 
> If I unmount the above, and then mount the DVD on mythtv:
> 
> mythtv:/home/piers# mount /cdrom
> mythtv:/home/piers#
> 
> and try again on destiny, I get:
> 
> destiny:/# mount mythtv:/media/cdrom0 /mnt/mythtv
> mount: mythtv:/media/cdrom0 failed, reason given by server: Permission
> denied
> destiny:/#
> 
...
> 
> I'm hoping you guys can tell me what I'm doing wrong here?

You need to run 'exportfs -a' again after mounting the dvd.....
OR maybe you need to unexport before mounting, and re-export after
mounting.  I don't remember the exact details.

If you use 2.6, nfs-utils 1.0.6 or later, and have the 'nfsd'
filesytem mounted on /proc/fs/nfsd:
  mount -t nfsd nfsd /proc/fs/nfsd

then this would work more smoothly, not requiring any re-export.

NeilBrown


-------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc. Do you grep through log files
for problems?  Stop!  Download the new AJAX search engine that makes
searching your log files as easy as surfing the  web.  DOWNLOAD SPLUNK!
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=103432&bid=230486&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
