From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: Permission denied
Date: Mon, 20 Feb 2006 09:31:39 -0500
Message-ID: <1140445899.7863.16.camel@lade.trondhjem.org>
References: <20060207123448.pqv165xvwosgk0g8@linux-smb.molly>
	 <20060220112535.GA10567@janus>
	 <20060220131637.iqam5s8yb4o8co44@linux-smb.molly>
Mime-Version: 1.0
Content-Type: text/plain
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1FBC53-0004NT-CM
	for nfs@lists.sourceforge.net; Mon, 20 Feb 2006 06:32:01 -0800
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1FBC4x-0004Bx-OX
	for nfs@lists.sourceforge.net; Mon, 20 Feb 2006 06:32:01 -0800
To: Daniel Bramkamp <bramkamp@team-datentechnik.de>
In-Reply-To: <20060220131637.iqam5s8yb4o8co44@linux-smb.molly>
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

On Mon, 2006-02-20 at 13:16 +0100, Daniel Bramkamp wrote:
> Quoting Frank van Maarseveen <frankvm@frankvm.com>:
> 
> > On Tue, Feb 07, 2006 at 12:34:48PM +0100, Daniel Bramkamp wrote:
> >> Hi list,
> >>
> >> I am experiencing some issues with a NFS server running on Linux Kernel
> >> 2.4.26 with nfs-utils-1.0.6 installed. Basically it works great,
> >> however, sometimes access to files and directories stored on the server
> >> is denied for a certain user account. I am not sure if it affects other
> >> users as well - only heard complaints from that particular user so far.
> >
> > A bit late but.. is that user a member of more than 16 groups?
> 
> Hi,
> 
> yesterday I reinstalled the server. The server is now running Gentoo 
> instead of Slackware. The installed software is up to date now. Kernel 
> is 2.6.14, nfs-utils is still 1.0.6, it seems 1.0.8 is currently a 
> realease candidate. Half an hour ago I got a call from the user - the 
> problem still exists. The user is a member of 13 groups. I really hoped 
> the update would solve the problem since I have no idea how to fix this.

You have to look at the client machine too.

Is the user still limited to 13 groups on the client, and do the
numerical uid/gid values match on the client and server?

Cheers,
  Trond



-------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc. Do you grep through log files
for problems?  Stop!  Download the new AJAX search engine that makes
searching your log files as easy as surfing the  web.  DOWNLOAD SPLUNK!
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=103432&bid=230486&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
