From: Stephan Koledin <skoledin@neolinear.com>
Subject: Re: NFS lockups with 2.4.18
Date: Fri, 26 Sep 2003 11:47:49 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <3F745FA5.5010907@neolinear.com>
References: <3F71CB8A.3090208@neolinear.com> <3F7347FF.2000403@neolinear.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 1A2viG-00008q-00
	for <nfs@lists.sourceforge.net>; Fri, 26 Sep 2003 09:45:00 -0700
Received: from panoramix.vasoftware.com
	([198.186.202.147] helo=externalmx.vasoftware.com ident=mail)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.22)
	id 1A2viF-0005Ab-G9
	for nfs@lists.sourceforge.net; Fri, 26 Sep 2003 09:44:59 -0700
Received: from n5.neolinear.com ([208.20.218.5]:57391 helo=flood.neolinear.com)
	by externalmx.vasoftware.com with esmtp (Exim 4.22 #1 (Debian))
	id 1A2us1-00082o-Gn
	for <nfs@lists.sourceforge.net>; Fri, 26 Sep 2003 08:51:01 -0700
Received: from rain ([192.9.200.77])
	by flood.neolinear.com with esmtp (Exim 3.35 #1 (Debian))
	id 1A2uow-0006eA-00
	for <nfs@lists.sourceforge.net>; Fri, 26 Sep 2003 11:47:50 -0400
To: nfs@lists.sourceforge.net
In-Reply-To: <3F7347FF.2000403@neolinear.com>
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

Some more observations on this issue...

I've noticed that lockd appears to be the culprit. It is the first 
process to get stuck in a 'D' state. Eventually, all the nfsd processes 
follow it, apparently one at a time.

I think I've narrowed the cause down to some questionable SETLK calls 
from Solaris 8 clients. The suspect 3rd party app is a bit complex, 
however, so still trying to isolate the exact triggering sequence of events.

In the process of trying to dig up some clues, I ran into a similar 
problem reported on the lkml (http://lkml.org/lkml/2003/1/29/59). From 
private correspondence with the submitter, he is still encountering 
problems, and continues to experiment with the 2.4.2x series and NFS 
patches in hope of relief. It may not be the exact same problem, but it 
is very similar.

If anyone has any ideas about this problem, please let me know. I 
certainly don't mind trying a more recent kernel, but hate to just dive 
in blindly hoping for a fix that may not be there... Any debugging 
suggestions?

Thanks.
-Stephan

-- 
Stephan B Koledin
Network Systems Developer
http://neolinear.com/



-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
