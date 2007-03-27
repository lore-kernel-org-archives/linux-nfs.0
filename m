From: Jason Keltz <jas@cse.yorku.ca>
Subject: Re: fsid question
Date: Tue, 27 Mar 2007 09:29:37 -0400
Message-ID: <46091C41.6070908@cse.yorku.ca>
References: <46082D10.1060301@cse.yorku.ca> <46083474.8090906@redhat.com>
	<46091325.6050403@cse.yorku.ca>
	<46091498.6030706@moving-picture.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: James Pearson <james-p@moving-picture.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HWBk3-0002Am-2w
	for nfs@lists.sourceforge.net; Tue, 27 Mar 2007 06:29:39 -0700
Received: from bronze.cs.yorku.ca ([130.63.90.34])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1HWBk3-0000sP-5K
	for nfs@lists.sourceforge.net; Tue, 27 Mar 2007 06:29:41 -0700
In-Reply-To: <46091498.6030706@moving-picture.com>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

On 03/27/07 08:56, James Pearson wrote:
> Jason Keltz wrote:
>> The problem is that right now, I have several hundred clients who have 
>> mounted the exported filesystems via NFS where I did not specify an 
>> explicit fsid in the NFS sever /etc/exports file.   In order to start 
>> using the fsid option, I need to know the existing fsids so that I can 
>> hard-code those into /etc/exports.  This way, if the server is 
>> rebooted, the clients will not be affected.  I could then choose fsids 
>> for NEW nfs exported filesystems and hard-code those fsids into 
>> /etc/exports.  Is there a Linux command, or an entry in /proc on the 
>> file server that will let me know the existing fsids?
> 
> I believe you can add a fsid to /etc/exports and re-export the file 
> systems - existing mounts will not be affected. New mounts will pick up 
> the new fsid. The existing mounts will also pick up the new fsid the 
> next time they remount the file system.
> 
> I've certainly done this in the past and had no problems.
> 
> James Pearson

Hi James.

Thanks for your message.

I'm not sure that I understand this though.  If the system is generating 
an fsid for NFS exports in the absence of a user-specified fsid, then 
changing the fsid and re-exporting the filesystem *should* essentially 
confuse the client? How does one choose an fsid that is not already in 
use on the system? I imagine there must be some way to list the 
currently used fsids for exported filesystems.

Jas.

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
