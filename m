From: Bernd Schubert <bernd-schubert@web.de>
Subject: Re: nfs_statfs: statfs error = 116
Date: Thu, 18 Sep 2003 21:49:02 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <200309182149.02062.bernd-schubert@web.de>
References: <3F698142.6070404@inf.ethz.ch> <200309182124.08706.bernd-schubert@web.de> <1063913505.1552.30.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 1A04mE-0002VC-00
	for <nfs@lists.sourceforge.net>; Thu, 18 Sep 2003 12:49:18 -0700
Received: from smtp02.web.de ([217.72.192.151] helo=smtp.web.de)
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.22)
	id 1A04mD-0002aP-IQ
	for nfs@lists.sourceforge.net; Thu, 18 Sep 2003 12:49:18 -0700
To: Marc Schmitt <mschmitt@inf.ethz.ch>
In-Reply-To: <1063913505.1552.30.camel@localhost>
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

On Thursday 18 September 2003 21:31, Marc Schmitt wrote:
> On Thu, 2003-09-18 at 21:24, Bernd Schubert wrote:
> > > > - Is there a way to get the client working again w/o having to reboot
> > > > (or kill all the users processes and umount the home if that's
> > > > possible)? I tried restarting rpc.statd on the client but that did
> > > > not help.
> > >
> > > not really... :(
> >
> > Mounting the directory again should help. IHMO not a nice solution but it
> > always worked on our systems.
>
> Do you mean 'mount -o remount /home/user'?
> I've tried that, it didn't work.
>

No, no, I simply mean:

mount -t nfs server:export_dir   target_dir 

so just 'overmounting' the already mounted directory.

Hope it helps,
Bernd



-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
