From: Jeff Layton <jlayton@redhat.com>
Subject: Re: [PATCH 0/2] mountd: clean up rmtab handling
Date: Sun, 10 Dec 2006 22:40:36 -0500
Message-ID: <457CD334.6080700@redhat.com>
References: <1161781620.7078.50.camel@dantu.rdu.redhat.com>	<45704A4A.6000007@poochiereds.net>	<17779.42545.642976.873602@cse.unsw.edu.au>	<4574392D.9080807@poochiereds.net>
	<17788.44467.578376.702580@cse.unsw.edu.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Gtc1z-0007Dm-Fd
	for nfs@lists.sourceforge.net; Sun, 10 Dec 2006 19:40:43 -0800
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1Gtc20-0002Sg-IP
	for nfs@lists.sourceforge.net; Sun, 10 Dec 2006 19:40:45 -0800
To: Neil Brown <neilb@suse.de>
In-Reply-To: <17788.44467.578376.702580@cse.unsw.edu.au>
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
 > I don't agree that it makes no change.
 > At one level this is clear from the fact that it loses information.
 > auth_unix_ip (which gets called when the kernel finds an unknown IP
 > address and wants a name for it) always provides a mapping from the IP
 > address to a hostname (As returned by the DNS) - if such a hostname is
 > available.  If the host is multi-homed (multiple IP addresses for the
 > one host), this might lose information.
 >
 > Consider a situation where we have one subnet that is physically very
 > secure, and we export some filesystem (rw,no_root_squash) to that
 > subnet, and another subnet that is physically less secure and we
 > export the filesystem (ro,root_squash) to that subnet.
 >
 > Suppose further there is some host - foo - with an interface on both
 > subnets.
 >
 > Now attacker Alice sets up a machine on the less secure subnet and
 > injects packets from foo's IP address (on that subnet).  They get
 > routed to the fileserver which maps the IP address to "foo".
 > When you then call client_check, both of the exports could match, and
 > you might end up giving internal access to this external packets.  Not
 > good.
 >
 > So I'm not happy with any patch that removes client_compose and
 > client_member in favour of client_resolve.
 >

Here's where I'm confused. I don't see how the patch I proposed loses any
information:

In the old method, we get an IP address and we build a list of client
hostnames (in no particular order), using repeated calls to the client_check
function. We then roll through the list of exports and make repeated
calls to client_member to compare the m_client of the export against the
list. If it doesn't match, we go to the next export.

With my patch, we don't bother building a list, and simply call client_check
repeatedly within the loop to do the comparison. This seems to me to be
functionally equivalent. Since the list is built solely on the result of
client_check calls, and the order there doesn't seem to matter, then I don't
see what information that it could carry that we don't get by just calling
client_check directly.

So I don't see how the patch I proposed would leave us any more vulnerable to
the situation you describe than what's already in place. The patch I proposed
*does* remove one vulnerability as well. The situation where my_client has
a list of hostnames that are no longer valid due to DNS or netgroup changes.

 > To the big-picture issue - you want "showmount -a" to return "the
 > right thing".  I don't believe there is a universal "the right thing"
 > as various issues are fairly poorly defined.  That is part of why I
 > was think of adding flags to mountd so you could choose your poison.
 >
 > The two main areas of uncertainty in "showmount" output are:
 >  - how to identify the host - IP address or host name.  The former is
 >    more precise in the case of multi-homed hosts.   The latter is
 >    possibly more common.

Very true. Perhaps IP addresses would be better overall. It's certainly
preferable to the current situation where "hostnames" can look like:

*,foo.example.com,192.168.10.0/255.255.255.0

Probably having it command line switchable is reasonable as well, but it
seems like if people *don't* choose to have it report IP addresses, then it
should give actual, resolvable, hostnames and not the comma-separated lists
that we get now.

 >  - How current should the information be?  rmtab cannot be kept
 >    reliably uptodate and tends to grow - there can easily be hosts
 >    listed there that do not exist any more.  Conversely the kernel
 >    cache information is relatively short term, and there could easily
 >    be clients that have the filesystem mounted but that are not
 >    listed in the cache.
 >
 > So: what exactly do you - or your customers - want?
 >
 > My impression is that most people don't want anything as "showmount -a"
 > will have been returned the "interesting" information that you mention
 > for some years and this is the first time it has even been mentioned.
 >

The problem reports I have so far have really to do with the fact that
the info returned by showmount -a doesn't really reflect anything
comprehensible. The lack of reports is probably more reflective of the fact
that rather few people bother to run showmount -a since it is traditionally
unreliable (and not just on Linux). I'm sure, though, that once we get over
the hurdle of having output that matches what's in the manpage, we'll start
getting problem reports about what the info actually represents.

In my opinion, it would be ideal to have it list all active mounts. Now comes
the question -- what constitutes an "active" mount? We really don't have a
reliable way to track that, since a host can go idle and not send out any
packets for a long time, and clients can spontaneously reboot and not remount
the filesystem. The design of NFS makes this very difficult to reconcile.

As you said, neither the rmtab or the kernel cache is an ideal place to pull
this info. So, my inclincation is to stick with the rmtab, and simply have it
track what we know is trackable -- mount and unmount calls into mountd. I
think having false positives is preferable to possibly having some mounts
that are not reflected at all because they have gone idle.

Either way, a manpage update is probably also in order to outline the folly
of depending on showmount -a :-).

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
