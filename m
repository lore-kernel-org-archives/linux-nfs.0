From: Paul Clements <paul.clements@steeleye.com>
Subject: Re: Re: [PATCH / RFC] nfs-utils: High Availability NFS
Date: Mon, 06 Sep 2004 11:42:18 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <413C855A.3000104@steeleye.com>
References: <4124DB86.9060505@steeleye.com>	<16677.22269.988036.787320@cse.unsw.edu.au>	<412E1C10.5020703@steeleye.com>	<16692.8187.411591.69640@cse.unsw.edu.au>	<4134A6AD.1060502@steeleye.com>	<16693.4161.921397.480506@cse.unsw.edu.au>	<413546B1.4080306@steeleye.com> <16699.51390.633644.1498@cse.unsw.edu.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1C4Ldf-00016m-2U
	for nfs@lists.sourceforge.net; Mon, 06 Sep 2004 08:42:39 -0700
Received: from stat16.steeleye.com ([209.192.50.48] helo=fenric.sc.steeleye.com)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.34)
	id 1C4Ldd-0007i1-HM
	for nfs@lists.sourceforge.net; Mon, 06 Sep 2004 08:42:38 -0700
To: Neil Brown <neilb@cse.unsw.edu.au>
In-Reply-To: <16699.51390.633644.1498@cse.unsw.edu.au>
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

Neil Brown wrote:

> Ok, I have made these changes, committed them, and tags them with
> nfs-utils-1-0-6-post3.

Thanks Neil. I'll take a look tomorrow.

> I'm not sure if I mentioned, but I change the SIGHUP handling so that
> instead of doing the work in the signal handler, I set a flag and do
> the work in the main look (svc_run).  This avoids some races.

That sounds fine.

--
Paul


-------------------------------------------------------
This SF.Net email is sponsored by BEA Weblogic Workshop
FREE Java Enterprise J2EE developer tools!
Get your free copy of BEA WebLogic Workshop 8.1 today.
http://ads.osdn.com/?ad_id=5047&alloc_id=10808&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
