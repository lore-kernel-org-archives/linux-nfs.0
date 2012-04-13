Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:17264 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756593Ab2DMXAj (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 13 Apr 2012 19:00:39 -0400
Date: Fri, 13 Apr 2012 19:00:24 -0400
From: Jeff Layton <jlayton@redhat.com>
To: Peter Staubach <pstaubach@exagrid.com>
Cc: Steve Dickson <SteveD@redhat.com>, Malahal Naineni <malahal@us.ibm.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "miklos@szeredi.hu" <miklos@szeredi.hu>,
        "viro@ZenIV.linux.org.uk" <viro@ZenIV.linux.org.uk>,
        "hch@infradead.org" <hch@infradead.org>,
        "michael.brantley@deshaw.com" <michael.brantley@deshaw.com>
Subject: Re: [PATCH RFC] vfs: make fstatat retry on ESTALE errors from
 getattr call
Message-ID: <20120413190024.5095f9b1@tlielax.poochiereds.net>
In-Reply-To: <2F609A9B-B44B-4CEA-BF35-D6BEDA729363@exagrid.com>
References: <1334316311-22331-1-git-send-email-jlayton@redhat.com>
	<20120413150518.GA1987@us.ibm.com>
	<20120413114236.0e557e01@tlielax.poochiereds.net>
	<4F884F32.7010402@RedHat.com>
	<2F609A9B-B44B-4CEA-BF35-D6BEDA729363@exagrid.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 13 Apr 2012 13:34:51 -0400
Peter Staubach <pstaubach@exagrid.com> wrote:

> I still think that returning ESTALE to the application is just exposing a short coming in the implementation.  From a path based system like stat(), the application should see either ENOENT or some sort valid return.
> 

Agreed, but I'm willing to live with a solution that addresses most of
these situations, even if we can't fix them all. If retrying
indefinitely may be a problem for other filesystems then we can't
just ignore that...

> I also look at the looping from the other side.  While possible, of course, I'd like to see someone construct a situation where it really happens.  By this, I don't mean a thought experiment, but a real running situation.
> 
> We already have evidence, in the form of the Solaris NFS client, that infinite looping does not happen in nature.
> 

I'm fairly certainly that looping indefinitely would be just fine for
NFS. My main concern is those FUSE fs' that Miklos alluded to when he
reviewed your earlier set.

He said that some can return ESTALE indefinitely, and they don't
necessarily respect signals. If limiting the number of retries helps
prevent problems with those, then that's still better than the current
situation.

-- 
Jeff Layton <jlayton@redhat.com>
