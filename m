Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:33366 "EHLO
	mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754855AbcGHOXL (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 8 Jul 2016 10:23:11 -0400
Date: Fri, 8 Jul 2016 16:23:08 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Jeff Layton <jlayton@redhat.com>
Cc: Seth Forshee <seth.forshee@canonical.com>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org,
        Tycho Andersen <tycho.andersen@canonical.com>
Subject: Re: Hang due to nfs letting tasks freeze with locked inodes
Message-ID: <20160708142308.GA20133@dhcp22.suse.cz>
References: <20160706174655.GD45215@ubuntu-hedt>
 <1467842838.2908.45.camel@redhat.com>
 <20160708122224.GA20200@dhcp22.suse.cz>
 <1467982314.13822.5.camel@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1467982314.13822.5.camel@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri 08-07-16 08:51:54, Jeff Layton wrote:
> On Fri, 2016-07-08 at 14:22 +0200, Michal Hocko wrote:
[...]
> > Apart from alternative Dave was mentioning in other email, what is the
> > point to use freezable wait from this path in the first place?
> > 
> > nfs4_handle_exception does nfs4_wait_clnt_recover from the same path and
> > that does wait_on_bit_action with TASK_KILLABLE so we are waiting in two
> > different modes from the same path AFAICS. There do not seem to be other
> > callers of nfs4_delay outside of nfs4_handle_exception. Sounds like
> > something is not quite right here to me. If the nfs4_delay did regular
> > wait then the freezing would fail as well but at least it would be clear
> > who is the culrprit rather than having an indirect dependency.
> 
> The codepaths involved there are a lot more complex than that
> unfortunately.
> 
> nfs4_delay is the function that we use to handle the case where the
> server returns NFS4ERR_DELAY. Basically telling us that it's too busy
> right now or has some transient error and the client should retry after
> a small, sliding delay.
> 
> That codepath could probably be made more freezer-safe. The typical
> case however, is that we've sent a call and just haven't gotten a
> reply. That's the trickier one to handle.

Why using a regular non-freezable wait would be a problem?
-- 
Michal Hocko
SUSE Labs
