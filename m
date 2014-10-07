Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:36017 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752368AbaJGO3f (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 7 Oct 2014 10:29:35 -0400
Date: Tue, 7 Oct 2014 10:29:34 -0400
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: Benjamin Coddington <bcodding@redhat.com>,
        "Andrew J. Romero" <romero@fnal.gov>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "Michael K. Rosier" <mrosier@fnal.gov>,
        Briant S Lawson <blawson@fnal.gov>,
        Joseph W Klemencic <jklemenc@fnal.gov>,
        Lynn A Garren <garren@fnal.gov>, Jeff Layton <jlayton@primarydata.com>
Subject: Re: Linux NFSv4 security issue: client presents wrong user's
 credentials to NFS server
Message-ID: <20141007142934.GA25677@fieldses.org>
References: <ACC0FF8A2EDF4D42AC55DCCCC7FC1E0E30845CB8@MAIL01.fnal.gov>
 <alpine.LRH.2.11.1410070849050.8059@sh-el6.eng.rdu2.redhat.com>
 <CAHQdGtRF+_yJKiWHKTmZZ1gx3Y9LsSk62EtZNjkZFPOr5u=vYw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <CAHQdGtRF+_yJKiWHKTmZZ1gx3Y9LsSk62EtZNjkZFPOr5u=vYw@mail.gmail.com>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Oct 07, 2014 at 09:36:12AM -0400, Trond Myklebust wrote:
> The problem with the request key interface is that it is completely
> broken when applied to containers, since it only runs in the global
> init namespace context. Fixing that is a non-trivial exercise; you'd
> have to not only carry a full namespace context with the RPC
> credential, but also somehow apply it to the upcall thread.

This one's really keeping me up at night.  Mainly because of the server
reboot recovery stuff.  The client v4 idmapping has this problem too,
doesn't it?

How are we going to decide if the user-helper containerization is doable
or if it's just a hopeless case?

Jeff seems optimistic about fixing it, and that'd be great, but if it's
not going to happen then we need to give up and use daemons for this
stuff.

--b.
