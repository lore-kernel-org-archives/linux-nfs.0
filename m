From: Neil Brown <neilb@cse.unsw.edu.au>
Subject: Re: /etc/eports and CNAME
Date: Wed, 3 Dec 2003 20:25:45 +1100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <16333.44057.333496.901470@notabene.cse.unsw.edu.au>
References: <3FCD9E24.8020404@gsi.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux NFS Mailing List <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.24)
	id 1ARTGj-0000NJ-RI
	for nfs@lists.sourceforge.net; Wed, 03 Dec 2003 01:26:01 -0800
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-mx2.sourceforge.net with smtp (Exim 4.24)
	id 1ARTGj-0003BH-Cx
	for nfs@lists.sourceforge.net; Wed, 03 Dec 2003 01:26:01 -0800
Received: From notabene ([129.94.211.194] == dulcimer.orchestra.cse.unsw.EDU.AU)
	(for <C.Huhn@gsi.de>) (for <nfs@lists.sourceforge.net>) By note With
	Smtp ; Wed, 3 Dec 2003 20:25:49 +1100
To: Christopher Huhn <C.Huhn@gsi.de>
In-Reply-To: message from Christopher Huhn on Wednesday December 3
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

On Wednesday December 3, C.Huhn@gsi.de wrote:
> Hi,
> 
> I have a quite silly question:
> 
> I have a host with a DNS A record "realname" and an alias (CNAME) "xyz0123".
> 
> A /etc/exports like:
> 
> /mountpoint   xyz*
> 
> does not export to "realname" by default.
> 
> Is there a possibility to get this working?

No.

When mountd gets a from this host to be allowed to mount the
filesystem, all mountd has to go on is the IP address.   There  is no
way for it to map the IP address to the name 'xyz0123' so it cannot
possibly know that 'xyz*' is a valid match.

NeilBrown


-------------------------------------------------------
This SF.net email is sponsored by: SF.net Giveback Program.
Does SourceForge.net help you be more productive?  Does it
help you create better code?  SHARE THE LOVE, and help us help
YOU!  Click Here: http://sourceforge.net/donate/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
