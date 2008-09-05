From: Neil Brown <neilb@suse.de>
Subject: Re: RESTRICTED_STATD
Date: Fri, 5 Sep 2008 11:26:55 +1000
Message-ID: <18624.35551.98462.115701@notabene.brown>
References: <6972A199-D332-4E74-9D47-70EC2CA381FE@oracle.com>
	<48B5332B.2040800@RedHat.com>
	<76bd70e30808270714p4342c8c3k8d1b98763cc95aef@mail.gmail.com>
	<EB4BA6CC-B023-49DC-9FE6-BD478DA5CB9F@oracle.com>
	<3400963b9465552abb83ecefede125bc.squirrel@neil.brown.name>
	<EB1B1F05-65DA-4A18-80F6-13DE4FCB387C@oracle.com>
	<18623.31268.970805.5694@notabene.brown>
	<0B107F2C-ED5A-4098-B59D-FF24CEA2C44B@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Steve Dickson <steved@redhat.com>, Olaf Kirch <okir@suse.de>,
	Linux NFS Mailing List <linux-nfs@vger.kernel.org>
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:38382 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754122AbYIEB1L (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 4 Sep 2008 21:27:11 -0400
In-Reply-To: message from Chuck Lever on Thursday September 4
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


Hi Chuck,

On Thursday September 4, chuck.lever@oracle.com wrote:
> >
> > The IP address of that the SM_NOTIFY came from is the most reliable
> > thing we have to identify which host just rebooted.  We use that to
> > find a 'dns_name' when we first MONitor a host, and use that name for
> > the file stored in /var/lib/nfs/sm.  We then match the source of
> > SM_NOTIFY against those file names.
> 
> Honestly, I would have thought exactly the opposite is true.  How  
> would that work with multi-homed peers?  Or with peers that might get  
> their IP addresses via DHCP?

The DNS is used specifically to deal with multi-homed peers.  We used
to just store IP addesses and match on IP addresses.  But that doesn't
work with multi-homed hosts.
The fully qualified DNS name is the closest thing we have to a
reliable unique host identifier, so that is what we use.


Clients that use DHCP might be a problem if it isn't hooked in to the
DNS properly.  I don't think there is any really good general solution
to that problem.  I certainly would trust the monname reported by such
a client.

The problem here is that STATMON is over-engineered and
under-specified.  You cannot implement it "correctly".  The best we
can do is to do our best.  And I think that means using DNS names as
the primary key.  It is at least a well understood primary key.

> 
> Is there any guidance in the Open Group standard on how to match  
> SM_NOTIFY requests to SM_MON?  I had thought it was "use the mon_name,  
> Luke".

I don't know what the Open Group standards say.  My vague memory is
"not very much" but I could be wrong.  However I think that "always
use the mon_name" doesn't actually work in practice, so it doesn't
really matter if it is a standard or not.

> 
> And normally I would take that approach.  In this case, folks want  
> real IPv6 support yesterday...

The cynic in me wonders if this is just so they can tick the box, or
if there is a real use case that demands it.  Hopefully it is the
latter.  :-)

NeilBrown
