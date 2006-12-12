From: Neil Brown <neilb@suse.de>
Subject: Re: [PATCH 0/2] mountd: clean up rmtab handling
Date: Tue, 12 Dec 2006 12:07:49 +1100
Message-ID: <17790.229.867008.833159@cse.unsw.edu.au>
References: <1161781620.7078.50.camel@dantu.rdu.redhat.com>
	<45704A4A.6000007@poochiereds.net>
	<17779.42545.642976.873602@cse.unsw.edu.au>
	<4574392D.9080807@poochiereds.net>
	<17788.44467.578376.702580@cse.unsw.edu.au>
	<457CD334.6080700@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Gtw7c-00084E-11
	for nfs@lists.sourceforge.net; Mon, 11 Dec 2006 17:07:52 -0800
Received: from ns2.suse.de ([195.135.220.15] helo=mx2.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1Gtw7a-0005fA-RL
	for nfs@lists.sourceforge.net; Mon, 11 Dec 2006 17:07:53 -0800
To: Jeff Layton <jlayton@redhat.com>
In-Reply-To: message from Jeff Layton on Sunday December 10
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

On Sunday December 10, jlayton@redhat.com wrote:
> Neil Brown wrote:
>  > So I'm not happy with any patch that removes client_compose and
>  > client_member in favour of client_resolve.
>  >
> 
> Here's where I'm confused. I don't see how the patch I proposed loses any
> information:
> 
> In the old method, we get an IP address and we build a list of client
> hostnames (in no particular order), using repeated calls to the client_check
> function. We then roll through the list of exports and make repeated
> calls to client_member to compare the m_client of the export against the
> list. If it doesn't match, we go to the next export.
> 
> With my patch, we don't bother building a list, and simply call client_check
> repeatedly within the loop to do the comparison. This seems to me to be
> functionally equivalent. Since the list is built solely on the result of
> client_check calls, and the order there doesn't seem to matter, then I don't
> see what information that it could carry that we don't get by just calling
> client_check directly.

Suppose your /etc/exports contains:
 
/baz   192.168.1.0/24(rw,no_root_squash)
/baz   192.168.2.0/24(ro,root_squash)

and your host 'foo' has two IP addresses: 192.168.1.10 and
192.168.2.10.

Suppose a request comes from 192.168.2.10 to access a file in /baz.

Old code:
  Kernel asks for "192.168.2.10".
  This goes to auth_unix_ip (in cache.c) which calls client_compose on
  that address.  client_compose will return 192.168.2.0/24 so kernel
  is told
          192.168.2.10 -> 192.168.2.0/24

  Then kernel asks "how can 192.168.2.0/24 access /baz".
  This goes to nfsd_export which checks each export and the first (and
  only) one that matches is 192.168.2.0/24 so it answers
  "ro,root_squash" as you would hope.

New code:
  Kernel asks for "192.168.2.10"
  This goes to auth_unix_ip which calls client_resolve which calls
  get_reliable_hostbyaddr which returns "foo".  So kernel is told
     192.168.2.10 -> foo

  Then kernel asks "how can foo access /baz".
  This goes to nfsd_export which calls gethostbyname on 'foo' getting
  { "foo", 192.168.1.10, 192.168.2.10} and then calls client_check
  against each export.  If the order is unchanged from the
  /etc/exports file, the first match will be
          /baz 192.168.1.0/24(rw,no_root_squash)

  so that will be returned to the kernel.  Not what you would hope.

Does that make sense?


> 
> So I don't see how the patch I proposed would leave us any more vulnerable to
> the situation you describe than what's already in place. The patch I proposed
> *does* remove one vulnerability as well. The situation where my_client has
> a list of hostnames that are no longer valid due to DNS or netgroup changes.

I agree that the my_client caching needs to be fixed.

> 
> As you said, neither the rmtab or the kernel cache is an ideal place to pull
> this info. So, my inclincation is to stick with the rmtab, and simply have it
> track what we know is trackable -- mount and unmount calls into mountd. I
> think having false positives is preferable to possibly having some mounts
> that are not reflected at all because they have gone idle.

Ok, how about this as a way forward.

 1/ remove that 'my_client' caching.
 2/ Remove the updates of rmtab on client upcalls and simply do rmtab
    updates with hostname (from get_reliable_hostbyaddr) and path name
    from MOUNT or UMOUNT requests
 3/ Add -I flag which:
      passes IP address rather than client_compose name to kernel and
      adds rmtab entries on kernel upcalls.  It also hard-removes
      rmtab entries on 'UMOUNT' and flush the kernel cache so that the
      next access for that host/path causes an upcall.
 4/ Add a -? flag (haven't chosen a letter yet) which:
      implies -I, but when asked for a 'DUMP', it calls gethosytbyname
      on each IP address to ge a hostname.

Then the default would be vaguely usable, and more precise information
would be available (at a cost).
  
> 
> Either way, a manpage update is probably also in order to outline the folly
> of depending on showmount -a :-).

Yes, I would happily accept a patch making such a change.

NeilBrown

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys - and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
