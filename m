From: gKurra <kurrag1@yahoo.com>
Subject: Re: knfsd re-export (source modification)
Date: Wed, 8 Oct 2003 11:55:37 -0700 (PDT)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20031008185537.95905.qmail@web20507.mail.yahoo.com>
References: <20031006193150.2557.qmail@web20504.mail.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 1A7JTG-0000lM-00
	for <nfs@lists.sourceforge.net>; Wed, 08 Oct 2003 11:55:38 -0700
Received: from web20507.mail.yahoo.com ([216.136.226.142])
	by sc8-sf-mx1.sourceforge.net with smtp (Exim 4.22)
	id 1A7JTF-0004za-Na
	for nfs@lists.sourceforge.net; Wed, 08 Oct 2003 11:55:37 -0700
To: nfs@lists.sourceforge.net
In-Reply-To: <20031006193150.2557.qmail@web20504.mail.yahoo.com>
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
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>



I tried the re-export described below by removing the
FS_REQUIRES_DEV check in nfsd, and providing
fictitious device numbers from a hash of the
mountpoint name, generating inode numbers from the
fileid in nfs client,  etc. (parts of which are
already done in some fashion by VFS)

(I'm using the 2.4.20-6 kernel that comes with RH9.
nfs-utils 1.0.6.)

It works for small tests - creating and deleting
directories and files, writing small files. But when I
try to run anything more serious such as the
Connectathon test suite, it causes a Kernel OOPS such
as:

NFS: commit (9/1176589 4096@0)
<1>Unable to handle kernel NULL pointer dereference at
virtual address 00000009
printing eip:c015359b
*pde = 00000000
Oops: 0000
nfsd nfs lockd sunrpc parport_pc lp parport autofs
8139too mii ipt_REJECT iptable_filter ip_tables sg
sr_mod ide-scsi scsi_mod ide-cd cdrom ohci1394
ieee1394 

EIP is at fput [kernel] 0x1b (2.4.20-6smp)


Does anyone have an idea why this happens? Any idea
where the problem could be? I'm trying to understand
why this should be so complicated. 


goutham



--- gKurra <kurrag1@yahoo.com> wrote:
> 
> hello,
> 
> i have some questions on re-exporting nfs mounts.
> 
> is there a logical reason why re-exporting is not
> done
> (apart from security considerations)?
> 
> i'm considering modifying the knfsd source to remove
> the FS_REQUIRES_DEV check, or give an option to
> re-export.
> 
> is there a logical fallacy to re-exporting? i'm not
> concerned about security as this will be between
> trusted machines/users.
> 
> apart from the FS_REQUIRES_DEV check, i can think of
> the following possible changes i'd need to make:
> 
> 1. i_generation number handling
> 2. providing a stable device number from, say, the
> mountpoint name.
> 
> is there anything else i'd need to take care of?
> what
> about inode handling?
> 
> thank you for any discussion and answers that come
> out
> of this.
> 
> -gk
> 
> 
> __________________________________
> Do you Yahoo!?
> The New Yahoo! Shopping - with improved product
> search
> http://shopping.yahoo.com
> 
> 
>
-------------------------------------------------------
> This sf.net email is sponsored by:ThinkGeek
> Welcome to geek heaven.
> http://thinkgeek.com/sf
> _______________________________________________
> NFS maillist  -  NFS@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/nfs


__________________________________
Do you Yahoo!?
The New Yahoo! Shopping - with improved product search
http://shopping.yahoo.com


-------------------------------------------------------
This SF.net email is sponsored by: SF.net Giveback Program.
SourceForge.net hosts over 70,000 Open Source Projects.
See the people who have HELPED US provide better services:
Click here: http://sourceforge.net/supporters.php
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
