Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:37048 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751358AbaIXPXh (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 24 Sep 2014 11:23:37 -0400
Date: Wed, 24 Sep 2014 11:23:33 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Steve Dickson <SteveD@redhat.com>
Cc: NeilBrown <neilb@suse.de>, Simo Sorce <simo@redhat.com>,
        Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 1/2] nfs-service: Added the starting of gssproxy
Message-ID: <20140924152333.GB3365@fieldses.org>
References: <5420B78D.6040704@RedHat.com>
 <20140922202655.5e308e58@willson.usersys.redhat.com>
 <20140923015549.GB32712@fieldses.org>
 <20140923120804.51dbcc2e@notabene.brown>
 <20140923021110.GB1409@fieldses.org>
 <20140923192311.GI29932@fieldses.org>
 <5421D55B.8040403@RedHat.com>
 <20140923202514.GO29932@fieldses.org>
 <5421E2E6.7000409@RedHat.com>
 <5422DE24.9050608@RedHat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <5422DE24.9050608@RedHat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Sep 24, 2014 at 11:07:16AM -0400, Steve Dickson wrote:
> On 09/23/2014 05:15 PM, Steve Dickson wrote:
> > 
> > On 09/23/2014 04:25 PM, J. Bruce Fields wrote:
> >>> I through this into my test world
> >> Thanks!
> >>
> >>>> and one side effect of this patch
> >>>> is both rpc.gssd and rpc.svcgssd daemons are *always* started when 
> >>>> a key tab exists (/etc/krb5.keytab) and *all* the services (nfs-client,
> >>>> nfs-server, rpc-gssd, and rpc-svcgssd) are disabled, which is not 
> >>>> good... Those daemons don't need to be started when both sides 
> >>>> are disabled...  But the auth_rpcgss is loaded! ;-) 
> >> Weird.  I can't see how this patch on its own would have any effect on
> >> that.
> It turns out I must have had the nfs-client.target enabled... 
> 
> I just realize 'systemctl disable nfs-client' does not fail, 
> but it does not do anything either. :-( I would think 
> it should fail with some type of "unit not found", but it
> does not... 

Huh, yes, that seems kind of unhelpful.

	# systemctl disable dighdfdij
	# echo $?
	0

--b.
