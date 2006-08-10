From: "Jesper Juhl" <jesper.juhl@gmail.com>
Subject: Re: 2.6.17.8 - do_vfs_lock: VFS is out of sync with lock
	manager!
Date: Fri, 11 Aug 2006 00:37:35 +0200
Message-ID: <9a8748490608101537y4c377fb3xcd8babbdbc29cee2@mail.gmail.com>
References: <9a8748490608080739w2e14e5ceg44a7bf0a3b475704@mail.gmail.com>
	<ketid21n1s5bn108lo7ps9t8a85db5bgs9@4ax.com>
	<9a8748490608090107j6ce7bc2cr2b74cc13b9541f39@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GBJ9s-0005yU-Cv
	for nfs@lists.sourceforge.net; Thu, 10 Aug 2006 15:37:44 -0700
Received: from nf-out-0910.google.com ([64.233.182.191])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1GBJ9q-0005e8-J6
	for nfs@lists.sourceforge.net; Thu, 10 Aug 2006 15:37:45 -0700
Received: by nf-out-0910.google.com with SMTP id a27so680842nfc
	for <nfs@lists.sourceforge.net>; Thu, 10 Aug 2006 15:37:35 -0700 (PDT)
To: "Grant Coady" <gcoady.lk@gmail.com>
In-Reply-To: <9a8748490608090107j6ce7bc2cr2b74cc13b9541f39@mail.gmail.com>
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

On 09/08/06, Jesper Juhl <jesper.juhl@gmail.com> wrote:
> On 09/08/06, Grant Coady <gcoady.lk@gmail.com> wrote:
> > On Tue, 8 Aug 2006 16:39:54 +0200, "Jesper Juhl" <jesper.juhl@gmail.com> wrote:
> >
> > >I have some webservers that have recently started reporting the
> > >following message in their logs :
> > >
> > >  do_vfs_lock: VFS is out of sync with lock manager!
> > >
> > >The serveres kernels were upgraded to 2.6.17.8 and since the upgrade
> > >the message started appearing.
> > >The servers were previously running 2.6.13.4 without experiencing this problem.
> > >Nothing has changed except the kernel.
> > >
> > >I've googled a bit and found this mail
> > >(http://lkml.org/lkml/2005/8/23/254) from Trond saying that
> > >"The above is a lockd error that states that the VFS is failing to track
> > >your NFS locks correctly".
> > >Ok, but that doesn't really help me resolve the issue. The servers are
> > >indeed running NFS and access their apache DocumentRoots from a NFS
> > >mount.
> > >
> > >Is there anything I can do to help track down this issue?
> >
> > I don't have an answer, but offer this observation: five boxen running
> > 2.6.17.8 doing six simultaneous
> >
> >   bzcat /home/share/linux-2.6/patch-2.6.18-rc4.bz2|patch -p1
> >
> > didn't burp.  The /home/share/ is an NFS export from another box running
> > 2.4.33-rc3a, me not sure if this was exercising any NFS locking as the
> > NFS source file was only opened for non-exclusive read-only.
> >
> The NFS server here is running 2.6.11.11 and doesn't seem to be
> reporting any problems. But I now have two more of my webservers (both
> running 2.6.17.8) that have started to complain about "do_vfs_lock:
> VFS is out of sync with lock manager!"
>
> I've not found a way to cause the message to be repported at will unfortunately.
>
Today 3 more of my webservers running 2.6.17.8 reported this message.
The machines all seem to be running fine still, so it doesn't seem to
be a serious problem, but it would still be nice to get it fixed ;)


-- 
Jesper Juhl <jesper.juhl@gmail.com>
Don't top-post  http://www.catb.org/~esr/jargon/html/T/top-post.html
Plain text mails only, please      http://www.expita.com/nomime.html

-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
