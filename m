From: Sven Geggus <sven-im-usenet@gegg.us>
Subject: Re: Performance tuning of diskless clients
Date: Fri, 31 Jan 2003 16:29:24 +0000 (UTC)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <b1e894$qe7$1@benzin.geggus.net>
References: <b1dvh5$n8p$1@benzin.geggus.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from benzin.geggus.net ([213.146.112.23] ident=foobar)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 18ee39-0001uz-00
	for <nfs@lists.sourceforge.net>; Fri, 31 Jan 2003 08:29:55 -0800
Received: from news by benzin.geggus.net with local  (Exchange M$)
	id 18ee2e-00072n-00
	for <nfs@lists.sourceforge.net>; Fri, 31 Jan 2003 17:29:24 +0100
To: nfs@lists.sourceforge.net
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

Sven Geggus <sven@gegg.us> wrote:

> At the Moment Server and client are both running vanilla Kernel 2.4.20 on
> Debian woody.

Obviously this Information was not enough, as somebody told me by private
Mail. 

I already tried tuning the /proc/sys/net/core/*mem_* setting and rsize/wsize
Values which does not seem to have an influence of the slow Startup times of
Bigger Applications.

I didn't try to set this sizes bigger than 8192 though, because this is not
possible without patching the Kernel.

BTW, my question is also aboutv possible Kernel-patches I should probably
use.

Sven

-- 
"And I'm right.  I'm always right, but in this case I'm just a bit more
right than I usually am." (Linus Torvalds, Sunday Aug 27, 2000)

/me is giggls@ircnet, http://sven.gegg.us/ on the Web


-------------------------------------------------------
This SF.NET email is sponsored by:
SourceForge Enterprise Edition + IBM + LinuxWorld = Something 2 See!
http://www.vasoftware.com
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
