From: Bernd Schubert <bernd-schubert@web.de>
Subject: Re: nfs_statfs: statfs error = 116
Date: Thu, 18 Sep 2003 21:24:08 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <200309182124.08706.bernd-schubert@web.de>
References: <3F698142.6070404@inf.ethz.ch> <3F69B7FB.1050505@RedHat.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 1A04ON-00004w-00
	for <nfs@lists.sourceforge.net>; Thu, 18 Sep 2003 12:24:39 -0700
Received: from smtp03.web.de ([217.72.192.158] helo=smtp.web.de)
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.22)
	id 1A04OK-0004Pd-4h
	for nfs@lists.sourceforge.net; Thu, 18 Sep 2003 12:24:36 -0700
To: Steve Dickson <SteveD@redhat.com>,
 Marc Schmitt <mschmitt@inf.ethz.ch>
In-Reply-To: <3F69B7FB.1050505@RedHat.com>
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

> > - Is there a way to get the client working again w/o having to reboot
> > (or kill all the users processes and umount the home if that's
> > possible)? I tried restarting rpc.statd on the client but that did not
> > help.
>
> not really... :(
>

Mounting the directory again should help. IHMO not a nice solution but it 
always worked on our systems.

Cheers,
	Bernd



-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
