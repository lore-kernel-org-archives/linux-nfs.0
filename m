From: James Pearson <james-p@moving-picture.com>
Subject: Re: "Permission denied" on autofs mount point
Date: Fri, 15 Mar 2002 13:34:57 +0000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <3C91F881.CD5594A7@moving-picture.com>
References: <3C9098C4.56E187EF@moving-picture.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Received: from mpc-26.sohonet.co.uk ([193.203.82.251] helo=moving-picture.com)
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 16lrrR-0004Kt-00
	for <nfs@lists.sourceforge.net>; Fri, 15 Mar 2002 05:35:09 -0800
To: nfs@lists.sourceforge.net, autofs@linux.kernel.org
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

Since sending my original message, I've found something on the kernel
list about a similar situation - see:

 http://www.geocrawler.com/archives/3/35/2001/12/2700/7351178/

I asked the original sender if he had any more info:

> maybe the symptom is different, but the cause is the same, i don't know.
> If you write a script, that tries to unmount, you duplicate the functionality
> of the automounter daemon to a certain degree, what might lead to the same
> problems. I think the code path in fs/autofs4/root.c line 300+ is problematic:
> 
> 
>         /*
>          * If this dentry is unhashed, then we shouldn't honour this
>          * lookup even if the dentry is positive.  Returning ENOENT here
>          * doesn't do the right thing for all system calls, but it should
>          * be OK for the operations we permit from an autofs.
>          */
>         if ( dentry->d_inode && d_unhashed(dentry) )
>                 return ERR_PTR(-ENOENT);
> 
> In my opinion it can happen that between the revalidate in 286 and this
> check for 'hashedness' another thread invalidates the entry and thus
> the syscall fails. When i find the time, i'll try to find out and fix. Possible,
> that it fixes also your problem, but currently i can't imagine a
> scenario including unavailable NFS-servers, that leads to this permission
> denied error.

Could what is described be the problem?

Is there a "fix"?

Thanks

James Pearson


James Pearson wrote:
> 
> I'm using autofs4 (autofs-4.0.0pre10) to mount a number of NFS mounts
> using a NIS map on machines running a RedHat based 2.4.7-10 kernel.
> 
> Occasionally trying to access a mount point (that has been working fine)
> gives e.g:
> 
> # cd /net/server1
> cd: /net/server1: Permission denied
> 
> This mount point never unmounts - even with sending SIGUSR1 to automount
> 
> The only way I can unmount the file system is by explicitly using umount
> 
> i.e. umount /net/server1
> 
> works OK and subsequent access to /net/server1 mounts the remote file
> system OK
> 
> The remote "servers' in question tend to be other Linux workstations,
> that I _think_ have crashed (or been rebooted) while being mounted by
> the clients ...
> 
> Is there anything I can do to fix this?
> 
> In the meantime, I'm thinking of having a simple script that attempts to
> umount everything under the automount mount point every few minutes or
> so (by looking for these mounts in mtab) - is this likely to cause
> problems/confusion with automount?
> 
> Thanks
> 
> James Pearson
> 
> _______________________________________________
> NFS maillist  -  NFS@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/nfs

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
