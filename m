From: "Kent, Ian I." <Ian.Kent@woodside.com.au>
Subject: RE: Re: [autofs] Server/client mismatch over status of a mo
	unt ...
Date: Wed, 19 Feb 2003 14:06:49 +0800
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <62D26CC4CB1CD3118EAA00805FBB65FA0B8B930D@perm01.woodside.com.au>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Cc: trond.myklebust@fys.uio.no
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from hydrogen.woodside.com.au ([203.48.119.98])
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18lNLG-0002E2-00
	for <nfs@lists.sourceforge.net>; Tue, 18 Feb 2003 22:04:26 -0800
Received: from perapp03.woodside.com.au (neon.woodside.com.au [203.48.119.97])
	by hydrogen.woodside.com.au (Postfix) with ESMTP id C77C8AA0A
	for <nfs@lists.sourceforge.net>; Wed, 19 Feb 2003 14:03:05 +0800 (WST)
To: 'James Pearson' <james-p@moving-picture.com>,
	nfs@lists.sourceforge.net, autofs@linux.kernel.org
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


What kernel version are you running?

It appears that the NFS client is a little broken in 2.4.18 and 2.4.20 that
we are aware of.

Here are a couple of paragraphs from a mail I received this morning:

Begin quote ...

So, seems that the kernels from 2.4.18 onwards introduced a problem with the
NFS code. Symptoms are that 'stat' type operations fail on directories above
a certain size. I can 'ls' in my home directory, but not 'ls -l' . If I cd
to a smaller directory, then I can 'ls' and 'ls -l'. I can cd to a very big
directory and 'ls' still seems to work.

I tried various combinations of NFS 2, NFS 3, UDP and TCP and different read
and write sizes, all to no avail. There is definitely a problem. The symptom
that was driving me nuts was that every time I tried to look up a man page,
or typed a command wrong, my shell went off into never-never land while it
stumbled off down MANPATH and PATH's. Something about directory operations
ain't right.

End quote.

2.4.17 works fine, with or without Tronds' patches.

So anyone have any ideas?

--
Ian Kent					Ph: (08) 9348 6967
Unix Infrastructure				email:
ian.kent@woodside.com.au <mailto:ian.kent@woodside.com.au> 
Woodside Energy Ltd.
Perth, Western Australia

	-----Original Message-----
	From:	James Pearson [SMTP:james-p@moving-picture.com]
	Sent:	Wednesday, February 19, 2003 12:57 AM
	To:	nfs@lists.sourceforge.net; autofs@linux.kernel.org
	Cc:	trond.myklebust@fys.uio.no
	Subject:	Re: [NFS] Re: [autofs] Server/client mismatch over
status of a mount ...

	I've been looking into the umount code a bit more, trying to work
out
	what's going on - however it appears that as rpc.mountd on the
server is
	contacted before the umount, then the entry in /var/lib/nfs/rmtab on
the
	server for the client mount is removed regardless of the success of
the
	umount system call ...

	This means that if you attempt a umount of an NFS file system, but
get
	an error like 'device is busy', then if the server reboots, the
client
	gets 'permission denied' on the NFS file system mount point ... 

	Surely this can't be right?

	Fortunately, as autofs doesn't appear to attempt a umount until the
	mount point is 'free', then you shouldn't have this problem - unless
you
	manually umount the mount point, or something goes wrong...

	The man page for rpc.mountd states:

	    The rmtab File
	       For  every  mount  request  received  from  an NFS client,
	       rpc.mountd adds an entry to the /var/state/nfs/rmtab file.
	       When  receiving an unmount request, that entry is removed.
	       user level part of the NFS service.

	       However, this file is mostly ornamental. One,  the  client
	       can  continue  to  use  the file handle even after calling
	       rpc.mountd 's UMOUNT  procedure.  And  two,  if  a  client
	       reboots  without notifying rpc.mountd , a stale entry will
	       remain in rmtab.

	which appears to suggest that having 'stale' entries in rmtab is not
a
	problem, which seems to suggest that dropping the RPC umount call
	wouldn't cause any adverse effects - and also stop the 'permission
	denied' my problem ...

	James Pearson
	 

	James Pearson wrote:
	> 
	> What would be the side effects of dropping the RPC call? I guess
the
	> rpc.mountd on the server will never get a umount request - will
this
	> cause problems with the client autofs repeatedly
mounting/umounting file
	> systems from the server?
	> 
	> With my particular problem, there was nothing in the system log on
the
	> client to indicate the the NFS filesystem couldn't be umounted -
i.e.
	> under what circumstances could umount think it's OK to umount, but
the
	> actual umount fails - if I try to umount an NFS filesystem that
has open
	> resources, it get a 'device is busy' error.
	> 
	> Thanks
	> 
	> James Pearson
	> 
	> Trond Myklebust wrote:
	> >
	> > >>>>> " " == James Pearson <james-p@moving-picture.com> writes:
	> >
	> >      > So, is there a possible workround?  Thanks
	> >
	> > Workaround: drop the entire RPC call. Failing that, you have a
choice
	> > of races...
	> >
	> > A real fix would involve teaching the knfsd kernel processes to
do
	> > upcalls to userland in order to find out if a client is
authorized or
	> > not. This is feasible in 2.5.x, but not in 2.4.x (as the latter
lacks
	> > the machinery for doing upcalls to userland).
	> >
	> > Cheers,
	> >   Trond
	> >
	> > -------------------------------------------------------
	> > This sf.net email is sponsored by:ThinkGeek
	> > Welcome to geek heaven.
	> > http://thinkgeek.com/sf
	> > _______________________________________________
	> > NFS maillist  -  NFS@lists.sourceforge.net
	> > https://lists.sourceforge.net/lists/listinfo/nfs
	> _______________________________________________
	> autofs mailing list
	> autofs@linux.kernel.org
	> http://linux.kernel.org/mailman/listinfo/autofs
	_______________________________________________
	autofs mailing list
	autofs@linux.kernel.org
	http://linux.kernel.org/mailman/listinfo/autofs


	-- 
	This email was received from the Internet. If this email is
unsolicited, non-business related, inappropriate or spam, please forward it
to spamfilter@woodside.com.au. Please do not reply or unsubscribe to spam as
this may confirm your email address to the spammer.


-------------------------------------------------------
This SF.net email is sponsored by: SlickEdit Inc. Develop an edge.
The most comprehensive and flexible code editor you can use.
Code faster. C/C++, C#, Java, HTML, XML, many more. FREE 30-Day Trial.
www.slickedit.com/sourceforge
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
