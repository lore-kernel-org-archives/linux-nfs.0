Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:37656 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752884AbcGMOqP (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 13 Jul 2016 10:46:15 -0400
Date: Wed, 13 Jul 2016 10:45:54 -0400
To: Trond Myklebust <trondmy@primarydata.com>
Cc: Nikolaus Rath <Nikolaus@rath.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>
Subject: Re: ELOOP from getdents
Message-ID: <20160713144554.GA9180@fieldses.org>
References: <87lh1fizyy.fsf@thinkpad.rath.org>
 <87vb0a8oyc.fsf@thinkpad.rath.org>
 <E35BAE5E-4D9B-44B4-98B3-54BA36AC895B@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
In-Reply-To: <E35BAE5E-4D9B-44B4-98B3-54BA36AC895B@primarydata.com>
From: bfields@fieldses.org (J. Bruce Fields)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Jul 12, 2016 at 11:26:00PM +0000, Trond Myklebust wrote:
> 
> > On Jul 12, 2016, at 18:35, Nikolaus Rath <Nikolaus@rath.org> wrote:
> > 
> > Hi,
> > 
> > Really no one any idea about this? 
> > 
> 
> In NFSv4, offsets 1 and 2 are reserved: https://tools.ietf.org/html/rfc7530#section-16.24

I think fuse is just getting the readdir offsets from userspace, so I
guess this is the fault of the userspace filesystem.  Though maybe the
fuse kernel driver should be doing some more sanity-checking, I don't
know.

--b.

> 
> > Adding fsdevel- to Cc, maybe someone there can help..
> > 
> > Best,
> > Nikolaus'
> > 
> > On Jul 05 2016, Nikolaus Rath <Nikolaus-BTH8mxji4b0@public.gmane.org> wrote:
> >> Hello,
> >> 
> >> I'm having trouble exporting a FUSE file system over nfs4
> >> (cf. https://bitbucket.org/nikratio/s3ql/issues/221/). If there are only
> >> a few entries in exported directory, `ls` on the NFS mountpoint fails
> >> with:
> >> 
> >> # ls -li /mnt/nfs/
> >> /bin/ls: reading directory /mnt/nfs/: Too many levels of symbolic links
> >> total 1
> >> 3 drwx------ 1 root root 0 Jul  5 11:07 lost+found/
> >> 3 drwx------ 1 root root 0 Jul  5 11:07 lost+found/
> >> 4 -rw-r--r-- 1 root root 4 Jul  5 11:07 testfile
> >> 4 -rw-r--r-- 1 root root 4 Jul  5 11:07 testfile
> >> 
> >> Running strace shows that the getdents() syscall fails with ELOOP:
> >> 
> >> stat("/mnt/nfs", {st_mode=S_IFDIR|0755, st_size=0, ...}) = 0
> >> openat(AT_FDCWD, "/mnt/nfs", O_RDONLY|O_NONBLOCK|O_DIRECTORY|O_CLOEXEC) = 3
> >> getdents(3, /* 4 entries */, 32768)     = 112
> >> getdents(3, /* 2 entries */, 32768)     = 64
> >> getdents(3, 0xf15c90, 32768)            = -1 ELOOP (Too many levels of symbolic links)
> >> open("/usr/share/locale/locale.alias", O_RDONLY|O_CLOEXEC) = 4
> >> 
> >> This happens only when using NFSv4, when mounting with vers=3 the error
> >> does not occur.
> >> 
> >> The FUSE file system receives the same requests and responds in the same
> >> way in both cases:
> >> 
> >> 2016-07-05 12:22:31.477 21519:fuse-worker-7 s3ql.fs.opendir: started with 1
> >> 2016-07-05 12:22:31.477 21519:fuse-worker-8 s3ql.fs.readdir: started with 1, 0
> >> 2016-07-05 12:22:31.478 21519:fuse-worker-8 s3ql.fs.readdir: reporting lost+found with inode 3, generation 0, nlink 1
> >> 2016-07-05 12:22:31.478 21519:fuse-worker-8 s3ql.fs.readdir: reporting testfile with inode 4, generation 0, nlink 1
> >> 2016-07-05 12:22:31.479 21519:fuse-worker-9 s3ql.fs.getattr: started with 1
> >> 2016-07-05 12:22:31.479 21519:fuse-worker-10 s3ql.fs._lookup: started with 1, b'lost+found'
> >> 2016-07-05 12:22:31.480 21519:fuse-worker-11 s3ql.fs._lookup: started with 1, b'testfile'
> >> 2016-07-05 12:22:31.481 21519:fuse-worker-12 s3ql.fs.readdir: started with 1, 2
> >> 2016-07-05 12:22:31.484 21519:fuse-worker-13 s3ql.fs.releasedir: started with 1
> >> 
> >> 
> >> The numbers refer to inodes. So FUSE first receives an opendir() request
> >> for inode 1 (the file system root / mountpoint), followed by readdir()
> >> for the same directory with offset 0. It reports two entries. It then
> >> receives another readdir for this directory with offset 2, and reports
> >> that all entries have been returned.
> >> 
> >> However, for some reason NFSv4 gets confused by this and reports 6
> >> entries to ls.
> >> 
> >> 
> >> Can anyone advise what might be happening here?
> >> 
> >> 
> >> Best,
> >> -Nikolaus
> >> 
> >> -- 
> >> GPG encrypted emails preferred. Key id: 0xD113FCAC3C4E599F
> >> Fingerprint: ED31 791B 2C5C 1613 AF38 8B8A D113 FCAC 3C4E 599F
> >> 
> >>             »Time flies like an arrow, fruit flies like a Banana.«
> >> --
> >> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> >> the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> >> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> > 
> > 
> > -- 
> > GPG encrypted emails preferred. Key id: 0xD113FCAC3C4E599F
> > Fingerprint: ED31 791B 2C5C 1613 AF38 8B8A D113 FCAC 3C4E 599F
> > 
> >             »Time flies like an arrow, fruit flies like a Banana.«
> > --
> > To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> > the body of a message to majordomo@vger.kernel.org
> > More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
