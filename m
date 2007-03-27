From: Wendy Cheng <wcheng@redhat.com>
Subject: Re: fsid question
Date: Tue, 27 Mar 2007 10:52:50 -0400
Message-ID: <46092FC2.2080901@redhat.com>
References: <46082D10.1060301@cse.yorku.ca>
	<46083474.8090906@redhat.com>	<46091325.6050403@cse.yorku.ca>	<46091498.6030706@moving-picture.com>
	<46091C41.6070908@cse.yorku.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: James Pearson <james-p@moving-picture.com>,
	nfs@lists.sourceforge.net
To: Jason Keltz <jas@cse.yorku.ca>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HWDLf-0004iX-9L
	for nfs@lists.sourceforge.net; Tue, 27 Mar 2007 08:12:35 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HWDLf-0000yx-Nt
	for nfs@lists.sourceforge.net; Tue, 27 Mar 2007 08:12:37 -0700
In-Reply-To: <46091C41.6070908@cse.yorku.ca>
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
> .........................................If the system is generating 
> an fsid for NFS exports in the absence of a user-specified fsid, then 
> changing the fsid and re-exporting the filesystem *should* essentially 
> confuse the client? How does one choose an fsid that is not already in 
> use on the system? I imagine there must be some way to list the 
> currently used fsids for exported filesystems.
>   

I think I see where the confusion comes from. To understand this, let's 
start with a thing called NFS "file handle".

When an NFS client request file access, server packages few info into a 
max 64 bytes identifier called "file handle" that is sent back to 
client. Depending on the version of Linux OS you have, it may consist of 
file inode number, directory inode number, export device major and minor 
number, or the admin-specified "fsid", etc. If the /etc/exports doesn't 
specify an "fsid", then the major and minor numbers of the exported 
device are used. Each file handle has a field called "fsid-type" to tell 
whether this file handle uses admin-specified "fsid" or device 
major-minor number.

In your case, the current FileHandle sent to NFS clients uses device 
major and minor numbers. You can safely pick *any* number you like as 
the fsid and re-exports the entries (say by doing an "exportfs -a" 
command). Any *new* NFS client requests will get a new FileHandle that 
uses the specified "fsid". However, the *existing" FileHandle(s) any NFS 
client still keeps and uses will have the "old" way - that is the device 
major-minor pair. The server knows how to interpret them (based on the 
type specified in the "fsid-type" field of the file handle).

This implies the following:

1. If server for whatever reason gets rebooted and somehow the device 
major-minor number gets altered, the client that keeps the "old" file 
handle will get a "stale file handle" error. Some of the NFS clients 
will re-do lookup to obtain the correct FileHandle(s). Some of them will 
simply fail. There is really not much you can do as a system administrator.
2. You want to keep the "fsid" same (and unique) for obvious reasons 
after you export them.
3. Any 32 bit integer can be used (say, 1, 2, 3, etc - no need to use 
hex number).

-- Wendy

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
