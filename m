From: "Kent, Ian I." <Ian.Kent@woodside.com.au>
Subject: RE: "Permission denied" on autofs mount point
Date: Thu, 21 Mar 2002 10:26:30 +0800
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <62D26CC4CB1CD3118EAA00805FBB65FA0B8B8FE3@perm01.woodside.com.au>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Cc: "'nfs@lists.sourceforge.net'" <nfs@lists.sourceforge.net>,
	"'autofs@linux.kernel.org'" <autofs@linux.kernel.org>
Received: from hydrogen.woodside.com.au ([203.48.119.98])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 16nsGt-00070P-00
	for <nfs@lists.sourceforge.net>; Wed, 20 Mar 2002 18:25:43 -0800
Received: from permsw01.woodside.com.au (neon.woodside.com.au [203.48.119.97])
	by hydrogen.woodside.com.au (Postfix) with ESMTP id C9DBA48D4
	for <nfs@lists.sourceforge.net>; Thu, 21 Mar 2002 10:18:26 +0800 (WST)
To: 'James Pearson' <james-p@moving-picture.com>
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
List-Archive: <http://www.geocrawler.com/redir-sf.php3?list=nfs>


We use our Linux machines as clients only. We have Solaris servers.
I am using all of Tronds' patches (against 2.4.6 and 2.4.17) and still have
problems over reboot with at least one of our servers. Trond's patches help
a lot.

I don't get the 'permission denied' or the messages you see in your log
(except the server not responding of course) but the automount daemon will
exit in a cowardly manner sometimes, during server reboots, leaving me
unable to recover without killing the current processing job.

I do get machine hangs fairly regularly, but that's another story.

> -----Original Message-----
> From:	James Pearson [SMTP:james-p@moving-picture.com]
> Sent:	Wednesday, March 20, 2002 10:56 PM
> To:	nfs@lists.sourceforge.net; autofs@linux.kernel.org
> Subject:	Re: "Permission denied" on autofs mount point
> 
> An update to my previous posts:
> 
> The problem re-occurred today - from /var/log/messages on a client:
> 
> Mar 20 10:35:20 client automount[465]: attempting to mount entry
> /net/server1
> Mar 20 10:35:37 client kernel: nfs: server server1 not responding, still
> trying
> Mar 20 10:38:57 client kernel: nfs: task 62879 can't get a request slot
> Mar 20 10:39:23 client kernel: nfs: server server1 OK
> Mar 20 10:39:23 client kernel: nfs: server server1 OK
> ...
> Mar 20 10:44:23 client1 automount[21355]: expired /net/server1
> 
> Accessing /net/server1 after this time gives "Permission denied" - until
> manually umount'ing.
> 
> The machine server1 crashed or was rebooted between 10:35 and 10:39.
> 
> The client is running a RedHat 2.4.7-10 based kernel - with the
> linux-2.4.7-seekdir.dif NFS client patch and a patch to ignore server
> fsid changes across reboots. 
> 
> This _seems_ to a problem with the server crashing - as other clients
> had exactly the same problem at the same time.
> 
> Would other NFS client patches improve matters?
> 
> Thanks
> 
> James Pearson
> 
> 
> James Pearson wrote:
> > 
> > Since sending my original message, I've found something on the kernel
> > list about a similar situation - see:
> > 
> >  http://www.geocrawler.com/archives/3/35/2001/12/2700/7351178/
> > 
> > I asked the original sender if he had any more info:
> > 
> > > maybe the symptom is different, but the cause is the same, i don't
> know.
> > > If you write a script, that tries to unmount, you duplicate the
> functionality
> > > of the automounter daemon to a certain degree, what might lead to the
> same
> > > problems. I think the code path in fs/autofs4/root.c line 300+ is
> problematic:
> > >
> > >
> > >         /*
> > >          * If this dentry is unhashed, then we shouldn't honour this
> > >          * lookup even if the dentry is positive.  Returning ENOENT
> here
> > >          * doesn't do the right thing for all system calls, but it
> should
> > >          * be OK for the operations we permit from an autofs.
> > >          */
> > >         if ( dentry->d_inode && d_unhashed(dentry) )
> > >                 return ERR_PTR(-ENOENT);
> > >
> > > In my opinion it can happen that between the revalidate in 286 and
> this
> > > check for 'hashedness' another thread invalidates the entry and thus
> > > the syscall fails. When i find the time, i'll try to find out and fix.
> Possible,
> > > that it fixes also your problem, but currently i can't imagine a
> > > scenario including unavailable NFS-servers, that leads to this
> permission
> > > denied error.
> > 
> > Could what is described be the problem?
> > 
> > Is there a "fix"?
> > 
> > Thanks
> > 
> > James Pearson
> > 
> > James Pearson wrote:
> > >
> > > I'm using autofs4 (autofs-4.0.0pre10) to mount a number of NFS mounts
> > > using a NIS map on machines running a RedHat based 2.4.7-10 kernel.
> > >
> > > Occasionally trying to access a mount point (that has been working
> fine)
> > > gives e.g:
> > >
> > > # cd /net/server1
> > > cd: /net/server1: Permission denied
> > >
> > > This mount point never unmounts - even with sending SIGUSR1 to
> automount
> > >
> > > The only way I can unmount the file system is by explicitly using
> umount
> > >
> > > i.e. umount /net/server1
> > >
> > > works OK and subsequent access to /net/server1 mounts the remote file
> > > system OK
> > >
> > > The remote "servers' in question tend to be other Linux workstations,
> > > that I _think_ have crashed (or been rebooted) while being mounted by
> > > the clients ...
> > >
> > > Is there anything I can do to fix this?
> > >
> > > In the meantime, I'm thinking of having a simple script that attempts
> to
> > > umount everything under the automount mount point every few minutes or
> > > so (by looking for these mounts in mtab) - is this likely to cause
> > > problems/confusion with automount?
> > >
> > > Thanks
> > >
> > > James Pearson
> > >
> > > _______________________________________________
> > > NFS maillist  -  NFS@lists.sourceforge.net
> > > https://lists.sourceforge.net/lists/listinfo/nfs

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
