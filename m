From: Marc Schmitt <mschmitt@inf.ethz.ch>
Subject: Re: nfs_statfs: statfs error = 116
Date: 18 Sep 2003 21:31:45 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1063913505.1552.30.camel@localhost>
References: <3F698142.6070404@inf.ethz.ch> <3F69B7FB.1050505@RedHat.com>
	 <200309182124.08706.bernd-schubert@web.de>
Mime-Version: 1.0
Content-Type: text/plain
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 1A04Zq-00069o-00
	for <nfs@lists.sourceforge.net>; Thu, 18 Sep 2003 12:36:30 -0700
Received: from mxout.hispeed.ch ([62.2.95.247] helo=smtp.hispeed.ch)
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.22)
	id 1A04Zm-0003Qx-VO
	for nfs@lists.sourceforge.net; Thu, 18 Sep 2003 12:36:27 -0700
To: Bernd Schubert <bernd-schubert@web.de>
In-Reply-To: <200309182124.08706.bernd-schubert@web.de>
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

On Thu, 2003-09-18 at 21:24, Bernd Schubert wrote:
> > > - Is there a way to get the client working again w/o having to reboot
> > > (or kill all the users processes and umount the home if that's
> > > possible)? I tried restarting rpc.statd on the client but that did not
> > > help.
> >
> > not really... :(
> >
> 
> Mounting the directory again should help. IHMO not a nice solution but it 
> always worked on our systems.

Do you mean 'mount -o remount /home/user'?
I've tried that, it didn't work.

Greetz
   Marc



-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
