From: Martin Siegert <siegert@sfu.ca>
Subject: limit on filesystem size?
Date: Thu, 1 Aug 2002 12:53:09 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20020801195309.GA26793@stikine.ucs.sfu.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from rm-rstar.sfu.ca ([142.58.120.21])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17aM0e-0002bC-00
	for <nfs@lists.sourceforge.net>; Thu, 01 Aug 2002 12:53:20 -0700
Received: from stikine.ucs.sfu.ca (stikine.ucs.sfu.ca [142.58.1.216])
	by rm-rstar.sfu.ca (8.12.3/8.12.3/SFU-6.0H) with ESMTP id g71JrAmC013384
	for <nfs@lists.sourceforge.net>; Thu, 1 Aug 2002 12:53:10 -0700 (PDT)
Received: (from siegert@localhost)
	by stikine.ucs.sfu.ca (8.11.6/8.9.2/SFU-5.0C) id g71Jr9o26804
	for nfs@lists.sourceforge.net; Thu, 1 Aug 2002 12:53:09 -0700
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
List-Archive: <http://www.geocrawler.com/redir-sf.php3?list=nfs>

Hello,

we are in the planning process for the setup of a large (~ 100 TB) NFS
server. My understanding is that there is a limit of 2TB for filesystem
sizes for local (!) filesystems under Linux (at least for ext2/ext3;
I am not sure about xfs).

My question really is: is there a limit for the filesystem size that
a Linux NFS client (2.4.18 or the upcoming 2.4.19 kernel) can mount
from a (possibly non-Linux) NFS server?
E.g., can I mount a 20TB filesystem under Linux?

(I've asked this question on the beowulf mailing list and the answer was
no. Now I ask the experts - hoping for a different answer :-)

Thanks a lot for your help!

Cheers,
Martin

========================================================================
Martin Siegert
Academic Computing Services                        phone: (604) 291-4691
Simon Fraser University                            fax:   (604) 291-4242
Burnaby, British Columbia                          email: siegert@sfu.ca
Canada  V5A 1S6
========================================================================


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
