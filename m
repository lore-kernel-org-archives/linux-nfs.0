From: Bill Davidsen <davidsen@tmr.com>
Subject: Re: Locking patches (generic & nfs)
Date: Thu, 25 Jul 2002 08:43:34 -0400 (EDT)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <35289.7680867047$1027602450@news.gmane.org>
References: <20020719101950.A15819@suse.de>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: linux-kernel@vger.kernel.org, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from tmr-02.dsl.thebiz.net ([216.238.38.204] helo=gatekeeper.tmr.com)
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17Xi4x-0001oj-00
	for <nfs@lists.sourceforge.net>; Thu, 25 Jul 2002 05:50:51 -0700
To: Olaf Kirch <okir@suse.de>
In-Reply-To: <20020719101950.A15819@suse.de>
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

On Fri, 19 Jul 2002, Olaf Kirch wrote:

> I've been investigating an NFS locking problem a customer
> of SuSE has had between an OpenServer machine (oh boy)
> acting as the NFS client and a Linux box acting as the server.
> 
> In the process of debugging this, I came across a number of
> bugs in the 2.4.18 kernel.

When NFSv4 gets in the new kernel I invite you to put your eyeballs on
that! Good catch!

Clearly not a lot of users go through this code or it would have shown up
sooner.

-- 
bill davidsen <davidsen@tmr.com>
  CTO, TMR Associates, Inc
Doing interesting things with little computers since 1979.



-------------------------------------------------------
This sf.net email is sponsored by: Jabber - The world's fastest growing 
real-time communications platform! Don't just IM. Build it in! 
http://www.jabber.com/osdn/xim
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
