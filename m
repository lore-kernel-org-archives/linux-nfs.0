From: Tom McNeal <trmcneal@attbi.com>
Subject: Re: take away nfs write permissions instantly
Date: Thu, 20 Jun 2002 09:44:39 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <3D120677.4FDBE4E3@attbi.com>
References: <3D11B0FF.8030008@psi.ch> <3D11E5AF.2050008@actusa.net> <3D11ED7D.50407@psi.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stuart Sheldon <stu@actusa.net>, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sccrmhc02.attbi.com ([204.127.202.62])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17L50A-0000xC-00
	for <nfs@lists.sourceforge.net>; Thu, 20 Jun 2002 09:41:42 -0700
To: Kapeller Rene PSI <rene.kapeller@psi.ch>
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

Hi -

Since the mount has taken place, I wouldn't expect that
modifying the export would change things, unless you 
also modified the file system on the server in order to
prevent write accesses from taking place at all.  Even then,
it wouldn't necessarily take place instantly due to caches 
on the client, in PV2.  It would probably be much faster
in PV3, since you'd see the attribute change after the
next transaction, but it still wouldn't be instantaneous.   
I don't know if there is a way to do what you want to do. 
(This is my instant reaction, so take it with the standard 
grain of salt...)

Tom 


Kapeller Rene PSI wrote:
> 
> exportfs -r did not help either!
> (Since I do not fully understand the difference between exportfs -a and
> exportfs -r, I usually do both.)
> 
> Btw, I'm using RedHat-7.3 (nfs-utils-0.3.3) on the Linux side.
> 
> Rene
> 
> Stuart Sheldon wrote:
> > Did you run exportfs -r after you changed exports?
> >
> > Stu
> >
> >
> > Kapeller Rene PSI wrote:
> >
> >> Can anyone help me on the following problem:
> >>
> >> In order to take away nfs write permissions instantly for a previously
> >> mounted
> >> nfs directory called '/data', I'm changing the export options for '/data'
> >> on the server to 'ro', while keeping the mount on the client.
> >>
> >> exportfs -io ro,sync,wdelay,no_root_squash nfsclient:/data
> >>
> >> exportfs -v
> >> /data   nfsserver(ro,wdelay,no_root_squash)
> >>
> >> Surprisingly the client can still write to /data at this point, unless
> >> I do
> >> umount/mount of /data.
> >>
> >> Is this the way it's suposed to work?
> >>
> >> Changing the nfs export options on a  SunOS 5.6 while clients have
> >> mounted
> >> a nfs path, write permissions are instantly taken away from it.
> >>
> >> share -F nfs -o ro,root=nfsclient /data
> >>
> >> In both cases I used the following nfs mount options:
> >> mount -o rw,sync,nfsvers=3,wsize=32768,rsize=32768
> >>
> >> Thanks!
> >> - Rene

--
------------------------------------------------------------
Tom McNeal       trmcneal@attbi.com     (650)906-0761 (cell) 
------------------------------------------------------------


-------------------------------------------------------
                   Bringing you mounds of caffeinated joy
                   >>>     http://thinkgeek.com/sf    <<<

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
