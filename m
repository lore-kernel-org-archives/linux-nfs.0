From: Bernd Schubert <bernd-schubert@web.de>
Subject: Re: NFS problems..
Date: Tue, 3 Sep 2002 21:29:50 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <200209032129.50237.bernd-schubert@web.de>
References: <6330918750.20020903180110@tnonline.net> <200209032058.50830.bernd-schubert@web.de> <17742334796.20020903211126@tnonline.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from relay2.uni-heidelberg.de ([129.206.210.211])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17mJN4-0005oO-00
	for <nfs@lists.sourceforge.net>; Tue, 03 Sep 2002 12:29:54 -0700
Received: from ix.urz.uni-heidelberg.de (mail.urz.uni-heidelberg.de [129.206.119.234])
	by relay2.uni-heidelberg.de (8.12.4/8.12.4) with ESMTP id g83JTp8N004720
	for <nfs@lists.sourceforge.net>; Tue, 3 Sep 2002 21:29:51 +0200 (MET DST)
Received: from euklid (bernd@euklid.pci.uni-heidelberg.de [129.206.21.104])
	by ix.urz.uni-heidelberg.de (8.8.8/8.8.8) with ESMTP id VAA20486
	for <nfs@lists.sourceforge.net>; Tue, 3 Sep 2002 21:29:50 +0200
To: nfs@lists.sourceforge.net
In-Reply-To: <17742334796.20020903211126@tnonline.net>
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

On Tuesday 03 September 2002 21:11, Anders Widman wrote:
> > On Tuesday 03 September 2002 18:33, Anders Widman wrote:
> >> > Hi,
> >> >
> >> > I'm afraid exporting subfolders of an already exported directory
> >> > doesn't work, and so it doesn't when you try to export vice versa.
> >>
> >> I  read  that  also.. but only exporting / (root) doesn't work either.
> >> That is my real problem.
> >>
> >> //Anders
> >
> > Ah, now I understand.
> >
> >> /                192.168.0.100(rw,no_root_squash,insecure)
> >
> > Is '/' perhaps already an imported directory?
>
> What  do  you  mean by "imported directory".. This is my FSTAB file on
> the server:

I meant imported e.g. via nfs.

>
> /dev/hde2       /                      reiserfs defaults        1 1
> /dev/hde1       /boot                  ext3     defaults        1 2
> none            /dev/pts               devpts   gid=5,mode=620  0 0
> none            /proc                  proc     defaults        0 0
> none            /dev/shm               tmpfs    defaults        0 0
> /dev/hde3       swap                   swap     defaults        0 0
>

Hmm, very strange, I can reproduce your error message on our clients, where / 
is imported via nfs, but the server exports its / and I can't get this 
message there.

Sorry but now I'm out of ideas.




-------------------------------------------------------
This sf.net email is sponsored by: OSDN - Tired of that same old
cell phone?  Get a new here for FREE!
https://www.inphonic.com/r.asp?r=sourceforge1&refcode1=vs3390
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
