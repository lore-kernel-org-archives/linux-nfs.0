From: Michael Haverkamp <mhaverkamp@kcp.com>
Subject: Re: NFSv3, 2.6, ext3 and dir_index
Date: Thu, 20 Jan 2005 13:26:21 -0600
Message-ID: <41F005DD.3060401@kcp.com>
References: <20050120163806.GA25243@melchior.yamamaya.is-a-geek.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Crhwv-00040j-0M
	for nfs@lists.sourceforge.net; Thu, 20 Jan 2005 11:26:33 -0800
Received: from mailhost2.os.kcp.com ([198.124.201.32])
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.41)
	id 1Crhwu-0002OU-Gu
	for nfs@lists.sourceforge.net; Thu, 20 Jan 2005 11:26:32 -0800
To: nfs@lists.sf.net
In-Reply-To: <20050120163806.GA25243@melchior.yamamaya.is-a-geek.org>
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

I have had the same problem with LVM2 and reiserfs using kernel 2.6.9. 
Whenever I have a large IO load on the server, these error crop up.  I 
copy everything on /space (/dev/hda5) to /space_bak (/dev/hdc5) using cp 
-a and that always makes the problem happen for me.  I have not tried 
removing LVM2 yet, so I don't know if that is a contributor.

I don't think that this problem is limited to ext3 and dir_index.

Tobias Diedrich wrote:
> Hi,
> 
> I recently switched from a local homedir to a NFS mounted homedir
> and noticed some strange things:
> 
> I have a Cronjob that goes over my mp3 directory and after the
> switch find would print "foo/bar/blubb: No such file or directory"
> for a few (approx. 2-3 out of 1928) directories, but not always the same
> ones.  Also, my mp3 player program would sometimes stop short in the
> middle of a song and skip to the next one, because it got ENOENT on
> a read of an open file.
> 
> Now first I thought it might just be a problem with my Kernel
> version or one of the patches I'm using and upgraded to a more
> recent one (currently 2.6.10-ac8-nfsacl on the client and
> 2.6.10-ac8-imq-nfsacl on the server, I also had the same problem
> without the nfsacl patches).
> 
> Then I read an older thread about trouble with ext3/dir_index and
> NFS in older 2.6 versions and tried disabling dir_index (Which was
> enabled on all my ext3 filesystems).  With that the problem
> vanished.
> 
> Are there any known problems with dir_index and NFS, or is this
> maybe a new bug?
> 
> Getting a tcpdump of the client<->server traffic proved difficult,
> because it is a quite sporadic bug and reproducing it would involve
> quite a lot of NFS traffic.  I could reliably trigger this with my
> CD/DVD burning script, which generates md5sums for each file and
> puts them both into the file MD5SUMS in the current directory, as
> well as into another file in my Homedir (But the files being
> md5summed also live on another NFS export, so there is a _lot_ of
> traffic).
> 
> I _do_ have a traffic capture of ls returning "No such file or
> directory" on the current directory, then cding up a level, down into the
> directory again and then a working ls.
> 
> Client fstab entry:
> nukunuku:/mnt/space1/ranma /home/ranma nfs hard,intr,bg,udp,rsize=4096,wsize=4096 0 0
> 
> /proc/mounts entry:
> nukunuku:/mnt/space1/ranma /home/ranma nfs rw,v3,rsize=4096,wsize=4096,hard,intr,udp,lock,addr=nukunuku 0 0
> 
> Server export file:
> / melchior.yamamaya.is-a-geek.org(sync,rw,no_root_squash)
> /mnt/space1 melchior.yamamaya.is-a-geek.org(sync,rw,no_root_squash)
> /mnt/space2 melchior.yamamaya.is-a-geek.org(sync,rw,no_root_squash)
> /mnt/space3 melchior.yamamaya.is-a-geek.org(sync,rw,no_root_squash)
> 

-- 
Michael Haverkamp


-------------------------------------------------------
This SF.Net email is sponsored by: IntelliVIEW -- Interactive Reporting
Tool for open source databases. Create drag-&-drop reports. Save time
by over 75%! Publish reports on the web. Export to DOC, XLS, RTF, etc.
Download a FREE copy at http://www.intelliview.com/go/osdn_nl
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
