From: "Joseph L. Hood" <nfsmail@acerbus.com>
Subject: Re: problem with exports file
Date: Tue, 20 Aug 2002 14:55:01 -0400 (EDT)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.LNX.4.44.0208201453390.31931-100000@linux2>
References: <20020820134521.352272bd.ian@ihtruelsen.2y.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from staffordstudio.com ([66.92.164.68] helo=linux2.staffordstudio.com)
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17hE9H-0004a9-00
	for <nfs@lists.sourceforge.net>; Tue, 20 Aug 2002 11:54:39 -0700
Received: from localhost (jhood@localhost)
	by linux2.staffordstudio.com (8.11.6/8.11.6) with ESMTP id g7KIt1c02129
	for <nfs@lists.sourceforge.net>; Tue, 20 Aug 2002 14:55:01 -0400
To: NFS List <nfs@lists.sourceforge.net>
In-Reply-To: <20020820134521.352272bd.ian@ihtruelsen.2y.net>
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

I don't believe you can share both a directory and a sub-directory of that 
same directory at the same time.

Joe


On Tue, 20 Aug 2002, Ian Truelsen wrote:

> I am not sure what it is that I am doing wrong here, but it is driving
> me nuts.
> 
> Here is what I am trying to set up: I want some individual directories
> on the server to be available to my whole lan, but I want one machine to
> have access to the whole directory tree for administration. Here is what
> I have in my exports file:
> 
> /home/ian *.ihtruelsen.2y.net(rw,no_root_squash)
> /media *.ihtruelsen.2y.net(rw,no_root_squash)
> /home/httpd *.ihtruelsen.2y.net(rw,no_root_squash)
> / minion.ihtruelsen.2y.net(rw,no_root_squash)
> 
> This works fine for the individual directories, but the whole structure
> will not mount on the minion machine, giving me a Permission denied
> error.
> 
> Can anyone give me some idea why this won't work as imagined?
> 
> 



-------------------------------------------------------
This sf.net email is sponsored by: OSDN - Tired of that same old
cell phone?  Get a new here for FREE!
https://www.inphonic.com/r.asp?r=sourceforge1&refcode1=vs3390
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
