From: Neil Brown <neilb@suse.de>
Subject: Re: [Cluster-devel] [PATCH 0/4 Revised] NLM - lock failover
Date: Thu, 19 Apr 2007 17:04:29 +1000
Message-ID: <17959.5245.635902.823441@notabene.brown>
References: <46156F3F.3070606@redhat.com>
	<4625204D.1030509@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: cluster-devel@redhat.com, nfs@lists.sourceforge.net
To: Wendy Cheng <wcheng@redhat.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HeQhR-0005bj-0v
	for nfs@lists.sourceforge.net; Thu, 19 Apr 2007 00:05:01 -0700
Received: from ns2.suse.de ([195.135.220.15] helo=mx2.suse.de)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HeQhS-0007y8-UO
	for nfs@lists.sourceforge.net; Thu, 19 Apr 2007 00:05:03 -0700
In-Reply-To: message from Wendy Cheng on Tuesday April 17
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

On Tuesday April 17, wcheng@redhat.com wrote:
> 
> In short, my vote is taking this (NLM) patch set and let people try it 
> out while we switch our gear to look into other NFS V3 failover issues 
> (nfsd in particular). Neil ?

I agree with Christoph in that we should do it properly.
That doesn't mean that we need a complete solution.  But we do want to
make sure to avoid any design decisions that we might not want to be
stuck with.  Sometimes that's unavoidable, but let's try a little
harder for the moment.

One thing that has been bothering me is that sometimes the
"filesystem" (in the guise of an fsid) is used to talk to the kernel
about failover issues (when flushing locks or restarting the grace
period) and sometimes the local network address is used (when talking
with statd). 

I would rather use a single identifier.  In my previous email I was
leaning towards using the filesystem as the single identifier.  Today
I'm leaning the other way - to using the local network address.

It works like this:

  We have a module parameter for lockd something like
  "virtual_server".
  If that is set to 0, none of the following changes are effective.
  If it is set to 1:

   The destination address for any lockd request becomes part of the
   key to find the nsm_handle.
   The my_name field in SM_MON requests and SM_UNMON requests is set
   to a textual representation of that destination address.
   The reply to SM_MON (currently completely ignored by all versions
   of Linux) has an extra value which indicates how many more seconds
   of grace period there is to go.  This can be stuffed into res_stat
   maybe.
   Places where we currently check 'nlmsvc_grace_period', get moved to
   *after* the nlmsvc_retrieve_args call, and the grace_period value
   is extracted from host->nsm.

  This is the full extent of the kernel changes.

  To remove old locks, we arrange for the callbacks registered with
  statd for the relevant clients to be called.
  To set the grace period, we make sure statd knows about it and it
  will return the relevant information to lockd.
  To notify clients of the need to reclaim locks, we simple use the
  information stored by statd, which contains the local network
  address.

The only aspect of this that gives me any cause for concern is
overloading the return value for SM_MON.  Possibly it might be cleaner
to define an SM_MON2 with different args or whatever.
As this interface is entirely local to the one machine, and as it can
quite easily be kept back-compatible, I think the concept is fine.

Statd would need to pass the my_name field to the ha callout rather
than replacing it with "127.0.0.1", but other than that I don't think
any changes are needed to statd (though I haven't thought through that
fully yet).

Comments?

NeilBrown

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
