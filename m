From: Neil Brown <neilb@suse.de>
Subject: Re: [PATCH 0/2] mountd: clean up rmtab handling
Date: Mon, 11 Dec 2006 12:00:35 +1100
Message-ID: <17788.44467.578376.702580@cse.unsw.edu.au>
References: <1161781620.7078.50.camel@dantu.rdu.redhat.com>
	<45704A4A.6000007@poochiereds.net>
	<17779.42545.642976.873602@cse.unsw.edu.au>
	<4574392D.9080807@poochiereds.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GtZWy-0000pm-3G
	for nfs@lists.sourceforge.net; Sun, 10 Dec 2006 17:00:32 -0800
Received: from ns1.suse.de ([195.135.220.2] helo=mx1.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1GtZWy-0001kV-Vu
	for nfs@lists.sourceforge.net; Sun, 10 Dec 2006 17:00:33 -0800
To: Jeff Layton <jlayton@poochiereds.net>
In-Reply-To: message from Jeff Layton on Monday December 4
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

On Monday December 4, jlayton@poochiereds.net wrote:
> Neil Brown wrote:
> > 
> > I'm not convinced... I don't like the idea of mapping an IP address to
> > a hostname and then just working with the hostname.  Because it is
> > really IP addresses that you trust, not host names (in the case of
> > multi-homed hosts particularly).
> > 
> 
> The patch I posted doesn't do that though. Perhaps I didn't explain it 
> well enough...
> 
> All that patch does is get rid of the caching of the hostname list in 
> my_client. Currently, what happens is that we build a comma separated 
> list of "hostnames" and stuff that into my_client.m_hostname. We build 
> this comma-separated list via client_compose, which just calls 
> client_check repeatedly to see what hostnames this address matches.
> 
> The patch I posted still uses the exact same decision making process to 
> see if an address matches an nfs_client entry (client_check). It just no 
> longer does this in two stages via the comma-separated list.
> 
> The patch I posted should make no change in behavior of whether a host 
> is allowed or denied, aside from the particular case that we already 
> discussed where a cached my_client hostname list is no longer correct.

I don't agree that it makes no change.
At one level this is clear from the fact that it loses information. 
auth_unix_ip (which gets called when the kernel finds an unknown IP
address and wants a name for it) always provides a mapping from the IP
address to a hostname (As returned by the DNS) - if such a hostname is
available.  If the host is multi-homed (multiple IP addresses for the
one host), this might lose information.

Consider a situation where we have one subnet that is physically very
secure, and we export some filesystem (rw,no_root_squash) to that
subnet, and another subnet that is physically less secure and we
export the filesystem (ro,root_squash) to that subnet.

Suppose further there is some host - foo - with an interface on both
subnets.

Now attacker Alice sets up a machine on the less secure subnet and
injects packets from foo's IP address (on that subnet).  They get
routed to the fileserver which maps the IP address to "foo".
When you then call client_check, both of the exports could match, and
you might end up giving internal access to this external packets.  Not
good.

So I'm not happy with any patch that removes client_compose and
client_member in favour of client_resolve.

To the big-picture issue - you want "showmount -a" to return "the
right thing".  I don't believe there is a universal "the right thing"
as various issues are fairly poorly defined.  That is part of why I
was think of adding flags to mountd so you could choose your poison.

The two main areas of uncertainty in "showmount" output are:
 - how to identify the host - IP address or host name.  The former is
   more precise in the case of multi-homed hosts.   The latter is 
   possibly more common.
 - How current should the information be?  rmtab cannot be kept
   reliably uptodate and tends to grow - there can easily be hosts
   listed there that do not exist any more.  Conversely the kernel
   cache information is relatively short term, and there could easily 
   be clients that have the filesystem mounted but that are not 
   listed in the cache.

So: what exactly do you - or your customers - want?

My impression is that most people don't want anything as "showmount -a"
will have been returned the "interesting" information that you mention
for some years and this is the first time it has even been mentioned.

Some people might want IP addresses for precision.  Others might want
host names so that it works with current tools.
Some people might want "who has mounted this since I last manually
flushed the rmtab file".  Others might want "who has accessed this in
the last X minutes".

And if you want precise info from the kernel cache, you need to make
them bigger than they currently need to be (The 'exports' list only
need to be about the size of your /etc/exports file, but to get
precise information, it will need to be roughly the size of the number
of active clients).

So I really think that any solution to this issue needs to involve
configuration options.

I would like to see mountd work internally with IP addresses, and map
them to hostnames only as they are being returned to 'showmount' if
that is what is wanted.
I would like to see mountd usually using a minimal cache, and only
adding the extra information when it is actually requested.
I can imagine that you might even want to added timestamps to the
rmtab file which are updated when the kernel cache is updated, and the
relevant lines are ignored if older than some set time.

But we really need a precise answer to "what are the actual
requirements that someone has on 'showmount -a'??"

NeilBrown

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys - and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
