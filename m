Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:35894 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755694AbaIWVPX (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 23 Sep 2014 17:15:23 -0400
Message-ID: <5421E2E6.7000409@RedHat.com>
Date: Tue, 23 Sep 2014 17:15:18 -0400
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: NeilBrown <neilb@suse.de>, Simo Sorce <simo@redhat.com>,
        Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 1/2] nfs-service: Added the starting of gssproxy
References: <20140922204401.GI26763@fieldses.org> <5420911D.6080506@RedHat.com> <20140922223423.GA29932@fieldses.org> <5420B78D.6040704@RedHat.com> <20140922202655.5e308e58@willson.usersys.redhat.com> <20140923015549.GB32712@fieldses.org> <20140923120804.51dbcc2e@notabene.brown> <20140923021110.GB1409@fieldses.org> <20140923192311.GI29932@fieldses.org> <5421D55B.8040403@RedHat.com> <20140923202514.GO29932@fieldses.org>
In-Reply-To: <20140923202514.GO29932@fieldses.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On 09/23/2014 04:25 PM, J. Bruce Fields wrote:
>> I through this into my test world
> Thanks!
> 
>> > and one side effect of this patch
>> > is both rpc.gssd and rpc.svcgssd daemons are *always* started when 
>> > a key tab exists (/etc/krb5.keytab) and *all* the services (nfs-client,
>> > nfs-server, rpc-gssd, and rpc-svcgssd) are disabled, which is not 
>> > good... Those daemons don't need to be started when both sides 
>> > are disabled...  But the auth_rpcgss is loaded! ;-) 
> Weird.  I can't see how this patch on its own would have any effect on
> that.
I agree... I was surprised myself... Unfortunately I'm sure how to
debug what/how/when systemd starts things...  But I moving
the key tab out of the way stop the daemons from starting.
Moving it back in place caused the daemons to start again,
which didn't happen with the current f21 nfs-utils.

Maybe its a bug in some other unit file... 

steved.
