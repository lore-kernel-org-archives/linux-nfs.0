From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: Stale File handles keep coming back
Date: Fri, 29 Apr 2005 10:08:22 -0400
Message-ID: <1114783702.10086.25.camel@lade.trondhjem.org>
References: <1114463253.2487.73.camel@localhost.localdomain>
	 <17006.13241.129839.558300@cse.unsw.edu.au>
	 <1114554149.4470.5.camel@localhost.localdomain>
	 <17006.64544.860436.620665@cse.unsw.edu.au>
	 <4271DBB3.3090402@bio.ifi.lmu.de>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Neil Brown <neilb@cse.unsw.edu.au>,
	Kris Vassallo <kris@linuxcertified.com>, nfs@lists.sourceforge.net,
	Olaf Kirch <okir@suse.de>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DRWAh-0003fH-UM
	for nfs@lists.sourceforge.net; Fri, 29 Apr 2005 07:08:47 -0700
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1DRWAf-0004R8-6C
	for nfs@lists.sourceforge.net; Fri, 29 Apr 2005 07:08:47 -0700
To: Frank Steiner <fsteiner-mail@bio.ifi.lmu.de>
In-Reply-To: <4271DBB3.3090402@bio.ifi.lmu.de>
Sender: nfs-admin@lists.sourceforge.net
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

fr den 29.04.2005 Klokka 09:01 (+0200) skreiv Frank Steiner:

> Our users have exactly the same symptoms, either on their homes
> or on directories mounted from the pSeries. It happens when
> they e.g. have an xterm with a shell and chdir to a directory,
> do sth. in there, and then leave the shell untouched for say 30
> minutes. After this time, they do a "ls" and get
> 
> ls: .: Stale NFS file handle
> 
> Calling "cd .." and then "cd <former_directory>", the ls works
> again.

Which filesystem is this?

Cheers,
  Trond

-- 
Trond Myklebust <trond.myklebust@fys.uio.no>



-------------------------------------------------------
SF.Net email is sponsored by: Tell us your software development plans!
Take this survey and enter to win a one-year sub to SourceForge.net
Plus IDC's 2005 look-ahead and a copy of this survey
Click here to start!  http://www.idcswdc.com/cgi-bin/survey?id=105hix
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
