Return-Path: <SRS0=PH1c=P7=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 24582C282C5
	for <linux-nfs@archiver.kernel.org>; Wed, 23 Jan 2019 22:32:31 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id D650621855
	for <linux-nfs@archiver.kernel.org>; Wed, 23 Jan 2019 22:32:30 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (1024-bit key) header.d=hansenpartnership.com header.i=@hansenpartnership.com header.b="DAZgLczR"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727160AbfAWWc3 (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 23 Jan 2019 17:32:29 -0500
Received: from bedivere.hansenpartnership.com ([66.63.167.143]:39984 "EHLO
        bedivere.hansenpartnership.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1727136AbfAWWc3 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 23 Jan 2019 17:32:29 -0500
Received: from localhost (localhost [127.0.0.1])
        by bedivere.hansenpartnership.com (Postfix) with ESMTP id 190068EE27B;
        Wed, 23 Jan 2019 14:32:29 -0800 (PST)
Received: from bedivere.hansenpartnership.com ([127.0.0.1])
        by localhost (bedivere.hansenpartnership.com [127.0.0.1]) (amavisd-new, port 10024)
        with ESMTP id iSYkVFJs8lEZ; Wed, 23 Jan 2019 14:32:28 -0800 (PST)
Received: from [153.66.254.194] (unknown [50.35.68.20])
        (using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
        (No client certificate requested)
        by bedivere.hansenpartnership.com (Postfix) with ESMTPSA id 8870E8EE02B;
        Wed, 23 Jan 2019 14:32:28 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=simple/simple; d=hansenpartnership.com;
        s=20151216; t=1548282748;
        bh=pGeBdjYr5pi6qbUkM1GR50TFPz9OMWbpebJgbqhFQKg=;
        h=Subject:From:To:Cc:Date:In-Reply-To:References:From;
        b=DAZgLczRnurjIIVkI2GFmVlSui7yCM+I2RfHknonfHZubzBAh48r2y+gmiz1GS6n4
         4cFvZMP5X5gZMmFtgZ4zdW4RyVcY+3iZb6pp8u7kg7DmidHuXYSwmX/2AC3DLVxlWx
         /RY1Kywt1v1QURrSnALRM3ORITgAFcWhAmlwytTk=
Message-ID: <1548282747.2949.62.camel@HansenPartnership.com>
Subject: Re: [LSF/MM TOPIC] Containers and distributed filesystems
From:   James Bottomley <James.Bottomley@HansenPartnership.com>
To:     Trond Myklebust <trondmy@hammerspace.com>,
        "lsf-pc@lists.linux-foundation.org" 
        <lsf-pc@lists.linux-foundation.org>
Cc:     "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>
Date:   Wed, 23 Jan 2019 14:32:27 -0800
In-Reply-To: <28ba1a0012e84a789d2f402d292935e98266212b.camel@hammerspace.com>
References: <d110c5e1a7c452a7da9209973bf15e1e0f021c82.camel@hammerspace.com>
         <1548271299.2949.41.camel@HansenPartnership.com>
         <28ba1a0012e84a789d2f402d292935e98266212b.camel@hammerspace.com>
Content-Type: text/plain; charset="UTF-8"
X-Mailer: Evolution 3.26.6 
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Wed, 2019-01-23 at 20:50 +0000, Trond Myklebust wrote:
> On Wed, 2019-01-23 at 11:21 -0800, James Bottomley wrote:
> > On Wed, 2019-01-23 at 18:10 +0000, Trond Myklebust wrote:
> > > Hi,
> > > 
> > > I'd like to propose an LSF/MM discussion around the topic of
> > > containers and distributed filesystems.
> > > 
> > > The background is that we have a number of decisions to make
> > > around dealing with namespaces when the filesystem is
> > > distributed.
> > > 
> > > On the one hand, there is the issue of which user namespace we
> > > should be using when putting uids/gids on the wire, or when
> > > translating into alternative identities (user/group name, cifs
> > > SIDs,...). There are two main competing proposals: the first
> > > proposal is to select the user namespace of the process that
> > > mounted the distributed filesystem. The second proposal is to
> > > (continue to) use the user namespace pointed to by init_nsproxy.
> > > It seems that whichever choice we make, we probably want to
> > > ensure that all the major distributed filesystems (AFS, CIFS,
> > > NFS) have consistent handling of these situations.
> > 
> > I don't think there's much disagreement among container people:
> > most would agree the uids on the wire should match the uids in the
> > container.  If you're running your remote fs via fuse in an
> > unprivileged container, you have no access to the kuid/kgid anyway,
> > so it's the way you have to run.
> > 
> > I think the latter comes about because most of the container
> > implementations still have difficulty consuming the user namespace,
> > so most run without it (where kuid = uid) or mis-implement it,
> > which is where you might get the mismatch.  Is there an actual use
> > case where you'd want to see the kuid at the remote end, bearing in
> > mind that when user namespaces are properly set up kuid is often
> > the product of internal subuid mapping.
> 
> Wouldn't the above basically allow you to spoof root on any existing
> mounted NFS client using the unprivileged command 'unshare -U -r'?

Yes, but what are you using as security on the remote?  If it's an
assumption of coming from a privileged port, say, then that's not going
to work unprivileged anyway (and is a very 90s way of doing
security).  If it's role based credential based security then, surely,
how the client manages ids shouldn't be visible to the server, because
the server has granular credentials for each of its roles.

> Eric Biederman was the one proposing the 'match the namespace of the
> process that mounted the filesystem' approach. My main questions
> about that approach would be:
> 1) Are we guaranteed to always have a mapping between an arbitrary
> uid/gid from the user namespace in the container, to the user
> namespace of the parent orchestrator process that set up the mount?

Yes, user namespace mappings are injective, so a uid inside always maps
to one outside but not necessarily vice versa.  Each user namespace you
go through can shrink the pool of external ids it maps to.

> 2) How do we reconcile that approach with the requirement that NFSv4
> be able to convert uids/gids into stringified user/group names (which
> is usually solved using an upcall mechanism)?

How do you authenticate the stringified ids?  If you're relying on
authentication at mount time only and trusting the client to tell you
the users with no further granular authentication by id then yes, it's
always going to be a bit unsafe because anyone possessing the mount
credentials can be any id on the server.  So if you want the client to
supervise what id goes to the server then the client has to run the
mount securely and make sure handoff to the user namespace of the
container is correct and, obviously, you can't allow an unprivileged
container to manage the actual client itself.

So, I think, to give a concrete example, the container has what it
thinks of as root and bin (uid 0 and 1) at exterior uid 1000 and 1001. 
You want the handed off mount to accept a write by container bin at
exterior uid 1001 as uid 1 to the server (real bin) but deny a write by
container root (exterior uid 1000)?

> > > Another issue arises around the question of identifying
> > > containers when they are migrated. At least the NFSv4 client
> > > needs to be able to send a unique identifier that is preserved
> > > across container migration. The uts_namespace is typically
> > > insufficient for this purpose, since most containers don't bother
> > > to set a unique hostname.
> > 
> > We did have a discussion in plumbers about the container ID, but
> > I'm not sure it reached a useful conclusion for you (video, I'm
> > afraid):
> > 
> > https://linuxplumbersconf.org/event/2/contributions/215/
> 
> I have a concrete proposal for how we can do this using 'udev', and
> I'm looking for a forum in which to discuss it.

Cc'ing the container list: containers@lists.linux-foundation.org might
be a good start.

> > > Finally, there is an issue that may be unique to NFS (in which
> > > case I'd be happy to see it as a hallway discussion or a BoF
> > > session) around preserving file state across container
> > > migrations.
> > 
> > If by file state, you mean the internal kernel struct file state,
> > doesn't CRIU already do that? or do you mean some other state?
> 
> I thought CRIU was unable to deal with file locking state?

Depends what you mean by "deal with".  The lock state can be extracted
from the source and transferred to the target so it works locally
(every transferred process sees the same locking state before and
after).  However, I think on the server locks get dropped on the
transfer and reacquired so a third party can get in to acquire the lock
if that's the worry?  We probably need a CRIU person to explain this
better and what the current state of play is since my knowledge is some
years old.

James

