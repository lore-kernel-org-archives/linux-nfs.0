From: Ion Badulescu <ionut@badula.org>
Subject: Re: New error
Date: Mon, 3 Mar 2003 09:25:17 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <200303031425.h23EPHNR027991@buggy.badula.org>
References: <3E62CAC5.6070305@chrisdos.com>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from ool-4351594a.dyn.optonline.net ([67.81.89.74] helo=badula.org)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 18pqsv-0006WW-00
	for <nfs@lists.sourceforge.net>; Mon, 03 Mar 2003 06:25:41 -0800
To: Chris Dos <chris@chrisdos.com>
In-Reply-To: <3E62CAC5.6070305@chrisdos.com>
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

On Sun, 02 Mar 2003 20:23:49 -0700, Chris Dos <chris@chrisdos.com> wrote:
> I had a system crash on my main server and now that it's up, I'm 
> constantly seeing this error in /var/log/messages and on the console
> 
> "kernel: nfsd: request from insecure port (ac1e02bc:47720)!"

So who is 172.30.2.188 and why did it decide to use a non-privileged 
port upon reconnecting?

Is that box a MacOS X box by any chance? Is it mounting from your server 
using TCP? That would be a known bug in the Darwin kernel...

Ion

-- 
  It is better to keep your mouth shut and be thought a fool,
            than to open it and remove all doubt.


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
