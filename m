From: Ion Badulescu <ionut@badula.org>
Subject: Re: 2.4.20 TCP server + solaris client performance
Date: Wed, 19 Feb 2003 09:07:13 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <200302191407.h1JE7DbU026781@buggy.badula.org>
References: <Pine.GSO.4.40.0302191211380.29315-100000@bodoni>
Cc: nfs@lists.sourceforge.net, Neil Brown <neilb@cse.unsw.edu.au>,
   Eric Whiting <ewhiting@amis.com>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from ool-4351594a.dyn.optonline.net ([67.81.89.74] helo=badula.org)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 18lUsr-0007uY-00
	for <nfs@lists.sourceforge.net>; Wed, 19 Feb 2003 06:07:37 -0800
To: Fabrizio Nesti <nesti@medialab.sissa.it>
In-Reply-To: <Pine.GSO.4.40.0302191211380.29315-100000@bodoni>
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

On Wed, 19 Feb 2003 12:30:06 +0100 (MET), Fabrizio Nesti <nesti@medialab.sissa.it> wrote:

> Also it is strange that a standard out-of-the-box RH8.0 on that big server
> does perform so bad. Knowing this in advance, we wouldn't have chosen
> linux for serving... :(

Is RH8.0 using nfs-utils 1.0 or newer? If so, then the default server
export options have changed and the filesystem is now exported "sync",
instead of "async".

The other thing to remember is that "cto" (close-to-open) consistency, 
which is enabled by default on the client, forces the client to do a 
fsync on any file it closes, which leads to rather poor performance when 
opening and closing lots of small files. Which is precisely what tar is 
doing...

So, try exporting the filesystem "async" if you can tolerate data loss
in case of a server crash, and try mounting the filesystem with "nocto"  
if you don't need inter-client consistency (and if you do then locking
the files with fcntl() is a much better solution anyway).

Ion

-- 
  It is better to keep your mouth shut and be thought a fool,
            than to open it and remove all doubt.


-------------------------------------------------------
This SF.net email is sponsored by: SlickEdit Inc. Develop an edge.
The most comprehensive and flexible code editor you can use.
Code faster. C/C++, C#, Java, HTML, XML, many more. FREE 30-Day Trial.
www.slickedit.com/sourceforge
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
