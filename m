Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-out2.uio.no ([129.240.10.58]:59333 "EHLO mail-out2.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753359Ab2DNBO5 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 13 Apr 2012 21:14:57 -0400
Message-ID: <1334365079.25130.21.camel@lade.trondhjem.org>
Subject: Re: [PATCH RFC] vfs: make fstatat retry on ESTALE errors from
 getattr call
From: Trond Myklebust <trond.myklebust@fys.uio.no>
To: Peter Staubach <pstaubach@exagrid.com>
Cc: Steve Dickson <SteveD@redhat.com>, Jeff Layton <jlayton@redhat.com>,
        Malahal Naineni <malahal@us.ibm.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "miklos@szeredi.hu" <miklos@szeredi.hu>,
        "viro@ZenIV.linux.org.uk" <viro@ZenIV.linux.org.uk>,
        "hch@infradead.org" <hch@infradead.org>,
        "michael.brantley@deshaw.com" <michael.brantley@deshaw.com>
Date: Fri, 13 Apr 2012 20:57:59 -0400
In-Reply-To: <2F609A9B-B44B-4CEA-BF35-D6BEDA729363@exagrid.com>
References: <1334316311-22331-1-git-send-email-jlayton@redhat.com>
	 <20120413150518.GA1987@us.ibm.com>
	 <20120413114236.0e557e01@tlielax.poochiereds.net>
	 <4F884F32.7010402@RedHat.com>
	 <2F609A9B-B44B-4CEA-BF35-D6BEDA729363@exagrid.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 2012-04-13 at 13:34 -0400, Peter Staubach wrote:
> I still think that returning ESTALE to the application is just exposing a short coming in the implementation.  From a path based system like stat(), the application should see either ENOENT or some sort valid return.
> 
> I also look at the looping from the other side.  While possible, of course, I'd like to see someone construct a situation where it really happens.  By this, I don't mean a thought experiment, but a real running situation.
> 
> We already have evidence, in the form of the Solaris NFS client, that infinite looping does not happen in nature.

Could we turn that statistic around? Has the Solaris client ever seen a
loop of more than, say, 5 or 6 retries?

I'm just trying to limit the scope of the problem...

Cheers
  Trond

