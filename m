From: raven@themaw.net
Subject: Re: umount() and NFS races in 2.4.26
Date: Sun, 11 Jul 2004 03:25:34 +0800 (WST)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.LNX.4.58.0407110323480.20439@donald.themaw.net>
References: <20040708180709.GA7704@timesink.dyndns.org>
 <Pine.LNX.4.58.0407101419210.1378@donald.themaw.net> <20040710181912.GA800@timesink.dyndns.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: autofs mailing list <autofs@linux.kernel.org>, nfs@lists.sourceforge.net,
   Kernel Mailing List <linux-kernel@vger.kernel.org>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BjNfm-0006zm-GB
	for nfs@lists.sourceforge.net; Sat, 10 Jul 2004 12:38:10 -0700
Received: from wombat.indigo.net.au ([202.0.185.19])
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.34)
	id 1BjNfl-0003si-R3
	for nfs@lists.sourceforge.net; Sat, 10 Jul 2004 12:38:10 -0700
To: Thomas Moestl <moestl@ibr.cs.tu-bs.de>
In-Reply-To: <20040710181912.GA800@timesink.dyndns.org>
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

On Sat, 10 Jul 2004, Thomas Moestl wrote:

> Hello,
> 
> On Sat, 2004/07/10 at 14:57:46 +0800, raven@themaw.net wrote:
> > > Hi,
> > > 
> > > after deploying an SMP machine at work, we started to experience Oopses
> > > in file-system related code relatively frequently. Investigation
> > > revealed that they were caused by references using junk pointers from
> > > freed super blocks via dangling inodes from unmounted file systems;
> > > Oopses would always be preceded by the warning
> > >   VFS: Busy inodes after unmount. Self-destruct in 5 seconds.  Have a nice day...
> > > on an unmount (unmount activity is high on this machine due to heavy use
> > > of the automounter). The predecessor to this machine, a UP system with
> > > otherwise almost identical configuration, did never encounter such
> > > problems, so I went looking for possible SMP races.
> > 
> > This has been reported many times by users of autofs, especially people 
> > with a ot of mount/umount activity.
> > 
> > As James pointed out my latest autofs4 patch resolved the issue for him.
> > However, on the NFS list Greg Banks pointed out that this may be hiding a
> > problem that exists in NFS. So it would be good if the NFS folk could 
> > investigate this further.
> > 
> > Never the less I'm sure there is a race in waitq.c of autofs4 in 
> > 2.4 that seems to cause this problem. This is one of the things 
> > addressed by my patch.
> 
> The system in question still uses autofs3. While I believe that the
> waitq race is also present there (it could probably cause directory
> lookups to hang, if I understand it correctly), I do not think that
> any autofs3 code could cause exactly those symptoms that I have
> observed. For that, it would have to obtain dentries of the file
> systems that it has mounted, but the old code never does that.

All autofs has to do is not delete a directory before exiting for this 
error to occur.

Ian



-------------------------------------------------------
This SF.Net email sponsored by Black Hat Briefings & Training.
Attend Black Hat Briefings & Training, Las Vegas July 24-29 - 
digital self defense, top technical experts, no vendor pitches, 
unmatched networking opportunities. Visit www.blackhat.com
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
