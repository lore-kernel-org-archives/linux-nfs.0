From: miah <jjohnson@sunrise-linux.com>
Subject: Re: nfstrace
Date: Fri, 10 May 2002 05:56:36 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20020510055636.A44499@server.sunrise-linux.com>
References: <DAV590tWXPP1jYSGnwq0000ab79@hotmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from [198.78.66.27] (helo=server.sunrise-linux.com)
	by usw-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 1769wt-0008GE-00
	for <nfs@lists.sourceforge.net>; Fri, 10 May 2002 05:56:40 -0700
Received: (from miah@localhost)
	by server.sunrise-linux.com (8.11.6/8.11.6) id g4ACuaO49336
	for nfs@lists.sourceforge.net; Fri, 10 May 2002 05:56:36 -0700 (PDT)
	(envelope-from miah)
To: nfs@lists.sourceforge.net
In-Reply-To: <DAV590tWXPP1jYSGnwq0000ab79@hotmail.com>; from tinaarora@hotmail.com on Fri, May 10, 2002 at 11:02:16AM +0530
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

Then nfstrace isn't on your system, or is not in your PATH, try:

find / -name nfstrace -print

or:

locate nfstrace

-miah

On Fri, May 10, 2002 at 11:02:16AM +0530, Tina Arora wrote:
> hello friends 
> nfstrace command is not working on my server..
> whenever I issue it on linux 7.1 i get the error
> bash: nfstrace : command not found 
> Please help
> 

_______________________________________________________________

Have big pipes? SourceForge.net is looking for download mirrors. We supply
the hardware. You get the recognition. Email Us: bandwidth@sourceforge.net
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
