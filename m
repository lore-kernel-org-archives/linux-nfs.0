From: Tom McNeal <trmcneal@attbi.com>
Subject: Re: [Fwd: take away nfs write permissions instantly]
Date: Thu, 20 Jun 2002 11:11:09 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <3D121ABD.F14144F8@attbi.com>
References: <200206201741.g5KHfY121536@amunet.Central.Sun.COM>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sccrmhc03.attbi.com ([204.127.202.63])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17L6Lr-0003Hd-00
	for <nfs@lists.sourceforge.net>; Thu, 20 Jun 2002 11:08:11 -0700
To: Peter Staubach <Peter.Staubach@Sun.COM>,
 	NFS maillist <nfs@lists.sourceforge.net>
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

Here is an update on Solaris behavior from a SUN architect; 
I hadn't realized it would notice the export change and 
return errors.  I'd assume that Linux is behaving like I 
said, but it appears that it should notice.  

Tom


Peter Staubach wrote:
> 
> 
> Re-exporting a file system to remove write permission will immediately
> disable all clients from writing through that export.  The client will
> not know that the files are now read-only, but they will be.  The file
> system does not need to be remounted or anything else like that.  The
> EROFS errors will just start being returned from the server to the
> client.
> 
> When this person indicates that the client could still write data,
> I would presume that the write(2) system call appears to succeed,
> ie. doesn't return an error, but encounters the EROFS error later
> when it actually tries to write the data to the server.
> 
>                 ps

--
------------------------------------------------------------
Tom McNeal       trmcneal@attbi.com     (650)906-0761 (cell) 
------------------------------------------------------------


-------------------------------------------------------
Sponsored by:
ThinkGeek at http://www.ThinkGeek.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
