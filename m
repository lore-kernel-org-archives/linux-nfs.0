From: Wendy Cheng <wcheng@redhat.com>
Subject: Re: fsid question
Date: Mon, 26 Mar 2007 17:00:36 -0400
Message-ID: <46083474.8090906@redhat.com>
References: <46082D10.1060301@cse.yorku.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: Jason Keltz <jas@cse.yorku.ca>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HVwc3-0008CH-Eb
	for nfs@lists.sourceforge.net; Mon, 26 Mar 2007 14:20:24 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HVwc5-0001vT-Cf
	for nfs@lists.sourceforge.net; Mon, 26 Mar 2007 14:20:25 -0700
In-Reply-To: <46082D10.1060301@cse.yorku.ca>
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
> Hi.
>
> I'm running a RedHat Enterprise 4 system.
>
> I have a question about the fsid option in /etc/exports that I was 
> hoping someone might be able to help with.
>
> I am working with LVM under Linux.  If I export LVM volumes via NFS, the 
> fsid is based on major/minor number.  
This statement needs correction. An NFS fsid is not based on major/minor 
numbers - it is is a 32 bit number that admin (root) can arbitrary 
choose and use to uniquely identify an NFS export. More on this in the 
following comment.
> If I then remove a logical volume 
> on the NFS server and reboot the server, the major and minor numbers for 
> the other volumes are adjusted, which of course causes problems for the 
> existing NFS exports (which either end up stale/pointing to a different 
> logical volume)!   The fsid option would fix this by allowing me to 
> specify a number independent of major/minor number.
>   
This is correct (fsid option would allow admin to identify an NFS 
export, independent of major/minor number).
> A couple of questions:
>
> 1) How do I find out the fsid of an existing export so that I can 
> "hard-code" it in the /etc/exports file?
>   
The admin (root, or whoever has access rights to /etc/exports file) can 
pick one number between 0 and 0xffffffff and add it into /etc/exports. 
It comes and goes with each "exportfs" command. This id is used to 
construct NFS filehandle that will be sent to NFS client upon requests. 
NFS client uses file handle to communicate with NFS server on which file 
they want to have access. The fsid, if specified, is part of the file 
handle that uniquely identifies an export (one entry in /etc/exports file).

So as rule of thumb, you would not want to change fsid as long as there 
are NFS clients still out there trying to access the files on the 
server. It is, however, not a permanent ID since there is no filesystem 
"on-disk" record of it.
> 2) For filesystems that are not mounted, how do I choose a number that 
> the system will not try to allocate to a different nfs export that isn't 
> using the fsid option?  Will the system check existing fsids, or it just 
> allocated the fsid based on a formula?
>   
No, NFS fsid is *not* allocated (nor generated) by system. There is no 
co-relation between the physical filesystem and NFS fsid, if the 
filesystem is not NFS exported. Note that a filesystem can be mounted 
but not NFS exported - in this case, the filesystem will not recognize 
the NFS fsid. I suspect that you confuse fsid with either filehandle or 
some specific filesystem implementation fsid (few cluster filesystems I 
know of have its own fsid - but it differs from the "NFS" fsid we 
discuss here).
> 3) What is the best way for me to generate my own fsid?
>   
It is a number picked by admin and must be between 0 and 0xFFFFFFFF.

Hopefully this makes things clear (since our cluster suites use NFS fsid 
extensively).

-- Wendy

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
