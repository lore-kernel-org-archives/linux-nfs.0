Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from out1-smtp.messagingengine.com ([66.111.4.25]:48297 "EHLO
        out1-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S965113AbdEXJQ7 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 24 May 2017 05:16:59 -0400
Message-ID: <1495617409.2538.1.camel@themaw.net>
Subject: Re: [RFC][PATCH 0/9] Make containers kernel objects
From: Ian Kent <raven@themaw.net>
To: "Eric W. Biederman" <ebiederm@xmission.com>,
        David Howells <dhowells@redhat.com>
Cc: James Bottomley <James.Bottomley@HansenPartnership.com>,
        mszeredi@redhat.com, linux-nfs@vger.kernel.org, jlayton@redhat.com,
        Linux Containers <containers@lists.linux-foundation.org>,
        linux-kernel@vger.kernel.org, cgroups@vger.kernel.org,
        linux-fsdevel@vger.kernel.org, trondmy@primarydata.com,
        viro@zeniv.linux.org.uk
Date: Wed, 24 May 2017 17:16:49 +0800
In-Reply-To: <87k256ek3e.fsf@xmission.com>
References: <1495554267.27369.9.camel@HansenPartnership.com>
         <87zie3mxkc.fsf@xmission.com>
         <f167feeb-e653-12e3-eec8-24162f7f7c07@suse.de>
         <149547014649.10599.12025037906646164347.stgit@warthog.procyon.org.uk>
         <1495472039.2757.19.camel@HansenPartnership.com>
         <2446.1495551216@warthog.procyon.org.uk>
         <2961.1495552481@warthog.procyon.org.uk> <87bmqjmwl5.fsf@xmission.com>
         <3860.1495557363@warthog.procyon.org.uk> <87k256ek3e.fsf@xmission.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 2017-05-24 at 03:26 -0500, Eric W. Biederman wrote:
> 
> So far no one has even bothered to seriously try the one solution that
> is guaranteed to work because it takes a lot of changes to kernel code.
> I believe the last effort snagged on what a pain it is to refactor the
> user mode helper infrastructure.

Yes, that's mostly true in my case although I wouldn't say I haven't looked at
it seriously but equally I haven't got anything towards it yet either, sorry.

I'm likely going to revisit this based on a couple of approaches.

One is just what you describe and I had already been looking at this some time
ago. It seems to me that adding a work queue type that starts and retains a
process until the work queue is destroyed (similar to the way the work queue sub
system starts a fail over thread for use under resource exhaustion) would be a
sensible way to do it.

This doesn't mean I think it's a good idea for reasons I've outlined in the past
but the approach does warrant the effort to work out if it can be used without
problems.

And there's also the request key infrastructure which, as it is now, gets in the
road of verifying results, *sigh*.

Ian
