From: Tom McNeal <trmcneal@attbi.com>
Subject: Re: kernel version problem
Date: Fri, 15 Mar 2002 07:55:07 -0800
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <3C92195B.BE165F9E@attbi.com>
References: <DAV20GvQ3C3unebhJHa0000ed31@hotmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Received: from rwcrmhc53.attbi.com ([204.127.198.39])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 16lu20-0005CN-00
	for <nfs@lists.sourceforge.net>; Fri, 15 Mar 2002 07:54:12 -0800
To: Tina Arora <tinaarora@hotmail.com>
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

2.2.16 is an adequate base to start from, but if you're able
to make bigger changes, and want the best nfs platform for 
2.2, then go to 2.2.19.

For 2.2.16, Go to http://nfs.sourceforge.net/ and follow the 
link to the download page (containing both the nfs-utils tar 
balls and the kernel patches).

You need to apply the kernel-nfs-dhiggen_merge-3.0.tar.gz
download to 2.2.16.

Apply the latest nfs utils download (nfs-utils-0.3.3.tar.gz)

Both have readme files; they'll give you the requirements and
tell you what to do.

Tom McNeal


> Tina Arora wrote:
> 
> hi,
> nfs.soureforge.net talks of kernel version atleast 2.2.18 to use nfs version 3
> .My system shows
> "Red Hat Linux release 7.0(Guinness)
>  Kernel 2.2.16-22 on i686"
> Nebody ne clues what this -22 means and also will i be able to use nfs (3) on
> this system of mine..
> thanx
> Tina

--
------------------------------------------------------------
Tom McNeal       trmcneal@attbi.com     (650)906-0761 (cell) 
------------------------------------------------------------

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
