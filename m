From: Steve Dickson <SteveD@redhat.com>
Subject: Re: NFS client fcntl locks going missing on FC6
Date: Sat, 24 Feb 2007 12:19:39 -0500
Message-ID: <45E073AB.2040005@RedHat.com>
References: <Pine.LNX.4.58.0702232223170.24593@vega3.dur.ac.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: M A Young <m.a.young@durham.ac.uk>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HL0Yq-0008DY-D0
	for nfs@lists.sourceforge.net; Sat, 24 Feb 2007 09:19:52 -0800
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HL0Ys-00014z-5w
	for nfs@lists.sourceforge.net; Sat, 24 Feb 2007 09:19:54 -0800
In-Reply-To: <Pine.LNX.4.58.0702232223170.24593@vega3.dur.ac.uk>
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

M A Young wrote:
> We have been having problems of files getting mysteriously locked on a
> linux NFS client to a Netapp NFS server (most recently with the
> kernel-2.6.19-1.2911.fc6 package, and ONTAP 7.0.5), and after some
> investigation it seems that the problem is that the linux box is getting a
> lock but not recording it, with the result that the lock is never removed
> from the NetApp server. I reported this in RedHat's bugzilla
> https://bugzilla.redhat.com/bugzilla/show_bug.cgi?id=229469
> and haven't heard anything from them, but it is possible that it is more
> general than just a RedHat issue.
In the future, when opening bugs like this (bugs against
the kernel) please make sure you added steved@redhat.com
to the cc list. Otherwise the bug will end up in bug
purgatory for a while until gets assigned correctly...

> I have found a way to reproduce the locks being left on the server which
> seems to occur when an attempt to lock a file is cancelled and a second
> attempt to lock the file immediately afterwards succeeds, which results in
> the server locking the file but not the client, and thus the lock never
> being removed from the server.
> My test program to reproduce the bug is attached to the RedHat bug report
> at https://bugzilla.redhat.com/bugzilla/attachment.cgi?id=148693 which can
> be done by running the program twice concurrently from an NFS mount.
> Is this a known bug and is it easy to fix?
Way back when... we had a customer using our 2.4 kernel that was
able to "lose" locks by using some goofy java script...
By lose locks I mean,  the server would grant the lock,
but the lock was never locally recored due to some obscure
failure (like a conflicting locks ) . The failure was never
noted, so an unlock was never sent... thus leaving an lost lock
on the server.

We thought we fixed this by making the client send an unlock when
this obscure failure happen, but his goofy java script was still
able to lose locks but much less infrequently (once every few months)...
The ultimately the fix was using the above kernel patch and having
the script to an unlock() (ignoring the return status) and then
doing the lock... (Can you say hack! :-\ )


Looking at the 2.6.20 kernel, it appears some precautions were
taken for this race since the lock is checked locally for any
conflicts (i.e. do_vfs_lock() is called with fl_flags & FL_ACCESS),
but there still might be an problem since if the second call to
do_vfs_lock() (the one that actually records the lock in the VFS)
fails, a unlock is *not* sent back to the server....
Although  this error condition will be noted with the
following syslog message:
     "nlmclnt_lock: VFS is out of sync with lock manager!"

So are you seeing this type of message in /var/log/messages?

steved.

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
