From: Greg Banks <gnb@melbourne.sgi.com>
Subject: Re: PATCH [NFSd] NFSv3/TCP
Date: Fri, 07 May 2004 18:11:00 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <409B4494.5253316B@melbourne.sgi.com>
References: <Pine.LNX.4.44.0405070949160.5549-100000@picard.science-computing.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Neil Brown <neilb@cse.unsw.edu.au>, linux-kernel@vger.kernel.org,
        Linux NFS Mailing List <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BM0Rv-0007zT-6w
	for nfs@lists.sourceforge.net; Fri, 07 May 2004 01:11:15 -0700
Received: from mtvcafw.sgi.com ([192.48.171.6] helo=omx2.sgi.com)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.30)
	id 1BM0Ru-0001PC-UX
	for nfs@lists.sourceforge.net; Fri, 07 May 2004 01:11:14 -0700
To: Oliver Tennert <tennert@science-computing.de>
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

Oliver Tennert wrote:
> 
> As it does not any changes for say a i386 architecture, 

Yes, by design.

> I cannot see why
> after that my lockups should go away.

I don't claim any such thing,  I was just resending a patch (which is of no
use to you) that Neil mentioned had been lost in the shuffle.

> Are lockups no known problem at all? Am I the only one experiencing them?
> They _definitely_ went away for me with NFSSVC_MAXBLKSIZE equal 32k, even
> under high IO pressure.

Sure, I believe you, I just have no idea what your problem is.

As a general statement of no particular import, I note that going to 32K
has a number of other side effects other than the obvious.  For streaming
reads and writes the call rate goes down by a factor of 4 so you may be
not exercising some race condition.  Also there may be different code paths
through READDIR and READDIR+ code.

Now if you had some kind of kernel debugger and could post some more
information, like process list and kernel stack traces from the hang,
someone (not me) may be able to figure out the real problem that you've
hidden by going to 32K.

Greg.
-- 
Greg Banks, R&D Software Engineer, SGI Australian Software Group.
I don't speak for SGI.


-------------------------------------------------------
This SF.Net email is sponsored by Sleepycat Software
Learn developer strategies Cisco, Motorola, Ericsson & Lucent use to deliver
higher performing products faster, at low TCO.
http://www.sleepycat.com/telcomwpreg.php?From=osdnemail3
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
