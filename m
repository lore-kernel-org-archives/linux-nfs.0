Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:35082 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751455Ab2JHMTX (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 8 Oct 2012 08:19:23 -0400
Date: Mon, 8 Oct 2012 08:19:20 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: NeilBrown <neilb@suse.de>
Cc: "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
        NFS <linux-nfs@vger.kernel.org>
Subject: Re: Inconsistency when mounting a directory that 'world' cannot
 access.
Message-ID: <20121008121920.GA25231@fieldses.org>
References: <20121001154309.GD18400@fieldses.org>
 <20121002123810.15bd1ee2@notabene.brown>
 <20121002143334.GA1435@fieldses.org>
 <20121003134629.72557522@notabene.brown>
 <20121003151349.GD14313@fieldses.org>
 <4FA345DA4F4AE44899BD2B03EEEC2FA909001D77@SACEXCMBX04-PRD.hq.netapp.com>
 <20121003162728.GE14313@fieldses.org>
 <20121004084659.38632320@notabene.brown>
 <20121004160739.GA4693@fieldses.org>
 <20121008170304.37dc6ae9@notabene.brown>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20121008170304.37dc6ae9@notabene.brown>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Oct 08, 2012 at 05:03:04PM +1100, NeilBrown wrote:
> On Thu, 4 Oct 2012 12:07:39 -0400 "J. Bruce Fields" <bfields@fieldses.org>
> wrote:
> > It's not the nfsd behavior that bothers me--there's nothing we can do
> > about the fact that access by filehandle can bypass directory
> > permissions.
> > 
> > What bothers is that mountd will apparently allow anyone to do a lookup
> > anywhere in an exported filesystem.
> 
> Not anyone - it requires a privileged source port from a known host.
> So it is only "anyone who can get 'root'".

As you know, that's not necessarily a good asumption.  And if somebody's
using sec=krb5, they're explicitly saying that they don't trust that
assumption.

> > Getting all the id->name mappings for a 100-entry directory is going to
> > require a 100 serialized upcalls to idmapd (and then possibly ldap), and
> > by default it looks like the idmapd cache will go cold after 10
> > minutes....  Not hard to imagine that could be a problem.
> > 
> > Running multiple idmapd process would be easy and might help?  Though
> > not if the client's just giving us the getattrs one at a time.
> > 
> > Or maybe the problem's somewhere else entirely, but that's a real bug if
> > we aren't giving good performance on /home.
> 
> I did some experimenting..
> On both 'client' and 'server':
>   for i in `seq 2000 3000`; do echo u$i:x:$i:1000::/nohome:/bin/false; done
> >> /etc/passwd
> 
> On server in suitable directory
> 
>   for i in `seq 2000 3000`; do mkdir $i ; chown u$i $i ; done
> 
> Mount that directory onto the client with NFSv3 and "time ls -l" takes a
> little under 4 seconds.
> Mount with NFSv4 and it takes about the same.  However:

OK, that's interesting.  I wonder what the problem is, then?  I can't
think of what else would make /home different.

> drwxr-xr-x 2 4294967294 root 4096 Oct  8 16:19 2974
> drwxr-xr-x 2 4294967294 root 4096 Oct  8 16:19 2975
> drwxr-xr-x 2 4294967294 root 4096 Oct  8 16:19 2976
> drwxr-xr-x 2 4294967294 root 4096 Oct  8 16:19 2977
> drwxr-xr-x 2 4294967294 root 4096 Oct  8 16:19 2978
> drwxr-xr-x 2 u2979      root 4096 Oct  8 16:19 2979
> drwxr-xr-x 2 u2980      root 4096 Oct  8 16:19 2980
> drwxr-xr-x 2 4294967294 root 4096 Oct  8 16:19 2981
> drwxr-xr-x 2 4294967294 root 4096 Oct  8 16:19 2982
> drwxr-xr-x 2 4294967294 root 4096 Oct  8 16:19 2983
> drwxr-xr-x 2 4294967294 root 4096 Oct  8 16:19 2984
> drwxr-xr-x 2 4294967294 root 4096 Oct  8 16:19 2985
> drwxr-xr-x 2 4294967294 root 4096 Oct  8 16:19 2986
> ....

Oops.

> tcpdump shows the server is returning the write stuff, but something if going
> wrong on the client.  I've tried unmounting/remounting and killing/restarting
> rpc.idmapd.
> I had some config problems previously .. is there any chance that these
> unknown entries are in a cache?  Any easy way to view or flush the cache?

Not that I know of.

What client version is this, and is it using the new (nfsidmap) or old
(idmapd) idmapper?

--b.
