From: James Pearson <james-p@moving-picture.com>
Subject: Re: fsid question
Date: Tue, 27 Mar 2007 13:56:56 +0100
Message-ID: <46091498.6030706@moving-picture.com>
References: <46082D10.1060301@cse.yorku.ca> <46083474.8090906@redhat.com>
	<46091325.6050403@cse.yorku.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: Jason Keltz <jas@cse.yorku.ca>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HWBER-0007Hu-54
	for nfs@lists.sourceforge.net; Tue, 27 Mar 2007 05:56:59 -0700
Received: from mpc-26.sohonet.co.uk ([193.203.82.251] helo=moving-picture.com)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HWBES-0000uY-17
	for nfs@lists.sourceforge.net; Tue, 27 Mar 2007 05:57:01 -0700
In-Reply-To: <46091325.6050403@cse.yorku.ca>
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

Jason Keltz wrote:
> Hi Wendy,
> 
> Thanks for your response..
> 
> A few more comments...
> 
> On 03/26/07 17:00, Wendy Cheng wrote:
> 
>>Jason Keltz wrote:
>>
>>>1) How do I find out the fsid of an existing export so that I can 
>>>"hard-code" it in the /etc/exports file?
>>>  
>>
>>The admin (root, or whoever has access rights to /etc/exports file) can 
>>pick one number between 0 and 0xffffffff and add it into /etc/exports. 
>>It comes and goes with each "exportfs" command. This id is used to 
>>construct NFS filehandle that will be sent to NFS client upon requests. 
>>NFS client uses file handle to communicate with NFS server on which file 
>>they want to have access. The fsid, if specified, is part of the file 
>>handle that uniquely identifies an export (one entry in /etc/exports file).
>>
>>So as rule of thumb, you would not want to change fsid as long as there 
>>are NFS clients still out there trying to access the files on the 
>>server. It is, however, not a permanent ID since there is no filesystem 
>>"on-disk" record of it.
> 
> 
> The problem is that right now, I have several hundred clients who have 
> mounted the exported filesystems via NFS where I did not specify an 
> explicit fsid in the NFS sever /etc/exports file.   In order to start 
> using the fsid option, I need to know the existing fsids so that I can 
> hard-code those into /etc/exports.  This way, if the server is rebooted, 
> the clients will not be affected.  I could then choose fsids for NEW nfs 
> exported filesystems and hard-code those fsids into /etc/exports.  Is 
> there a Linux command, or an entry in /proc on the file server that will 
> let me know the existing fsids?

I believe you can add a fsid to /etc/exports and re-export the file 
systems - existing mounts will not be affected. New mounts will pick up 
the new fsid. The existing mounts will also pick up the new fsid the 
next time they remount the file system.

I've certainly done this in the past and had no problems.

James Pearson

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
