From: Jeff Layton <jlayton@poochiereds.net>
Subject: Re: [PATCH 0/2] mountd: clean up rmtab handling
Date: Mon, 04 Dec 2006 10:05:17 -0500
Message-ID: <4574392D.9080807@poochiereds.net>
References: <1161781620.7078.50.camel@dantu.rdu.redhat.com>	<45704A4A.6000007@poochiereds.net>
	<17779.42545.642976.873602@cse.unsw.edu.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GrFO2-0005M0-4K
	for nfs@lists.sourceforge.net; Mon, 04 Dec 2006 07:05:42 -0800
Received: from ms-smtp-02.southeast.rr.com ([24.25.9.101])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1GrFO3-00032O-5t
	for nfs@lists.sourceforge.net; Mon, 04 Dec 2006 07:05:43 -0800
To: Neil Brown <neilb@suse.de>
In-Reply-To: <17779.42545.642976.873602@cse.unsw.edu.au>
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

Neil Brown wrote:
> 
> I'm not convinced... I don't like the idea of mapping an IP address to
> a hostname and then just working with the hostname.  Because it is
> really IP addresses that you trust, not host names (in the case of
> multi-homed hosts particularly).
> 

The patch I posted doesn't do that though. Perhaps I didn't explain it 
well enough...

All that patch does is get rid of the caching of the hostname list in 
my_client. Currently, what happens is that we build a comma separated 
list of "hostnames" and stuff that into my_client.m_hostname. We build 
this comma-separated list via client_compose, which just calls 
client_check repeatedly to see what hostnames this address matches.

The patch I posted still uses the exact same decision making process to 
see if an address matches an nfs_client entry (client_check). It just no 
longer does this in two stages via the comma-separated list.

The patch I posted should make no change in behavior of whether a host 
is allowed or denied, aside from the particular case that we already 
discussed where a cached my_client hostname list is no longer correct.

All that said, I'm OK with pulling this info out of the kernel caches 
instead. I'll have a look over the latest patch that you sent and see if 
it does what we need.

Thanks,
Jeff

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys - and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
