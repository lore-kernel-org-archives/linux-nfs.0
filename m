From: Olaf Kirch <okir@suse.de>
Subject: Re: Improving unfsd scalability
Date: Thu, 30 Nov 2006 11:22:38 +0100
Message-ID: <20061130102238.GA11918@suse.de>
References: <9c8209a10611292254s79849a6ci11fe10341017ae7e@mail.gmail.com>
	<Pine.LNX.4.64.0611301056440.15692@maggie.lkpg.cendio.se>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Murali Bashyam <mbcoder@gmail.com>, nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Gpj3y-0007EZ-CU
	for nfs@lists.sourceforge.net; Thu, 30 Nov 2006 02:22:42 -0800
Received: from mx1.suse.de ([195.135.220.2])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1Gpj3z-0000FQ-FZ
	for nfs@lists.sourceforge.net; Thu, 30 Nov 2006 02:22:43 -0800
To: Peter Astrand <astrand@cendio.se>
In-Reply-To: <Pine.LNX.4.64.0611301056440.15692@maggie.lkpg.cendio.se>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

On Thu, Nov 30, 2006 at 11:00:25AM +0100, Peter Astrand wrote:
> > Has anyone attempted to speedup concurrently handling many client NFS
> > requests in unfsd? Any experience regarding multi-threading or running
> > multiple processes within unfsd? Any do's and don'ts?
> 
> This is an interesting topic. I guess it depends a lot on which RPC 
> library you are using. The "normal" ONC RPC implementation, found in glibc 
> for example, is as far as I know not thread safe. This might be a problem. 
> Correct me if I'm wrong.

unfsd was able to run several process in parallel since I think 1998. Note
it's multi-process not multithread, so it's a tad inefficient - but I
haven't heard of any problems in that area.  unfsd was running on some
machines in the Suse R&D network as late as a few months ago, with 8
processes in parallel.

Olaf
-- 
Walks like a duck. Quacks like a duck. Must be a chicken.

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys - and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
