Return-Path: <SRS0=LIrp=S3=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1FEBFC4321A
	for <linux-nfs@archiver.kernel.org>; Thu, 25 Apr 2019 20:01:02 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 3653620878
	for <linux-nfs@archiver.kernel.org>; Thu, 25 Apr 2019 20:01:02 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1730582AbfDYUBB (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 25 Apr 2019 16:01:01 -0400
Received: from fieldses.org ([173.255.197.46]:51456 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1730516AbfDYUBB (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 25 Apr 2019 16:01:01 -0400
Received: by fieldses.org (Postfix, from userid 2815)
        id 250D31C83; Thu, 25 Apr 2019 16:01:00 -0400 (EDT)
Date:   Thu, 25 Apr 2019 16:01:00 -0400
To:     Jeff Layton <jlayton@redhat.com>
Cc:     "J. Bruce Fields" <bfields@redhat.com>, linux-nfs@vger.kernel.org,
        linux-fsdevel@vger.kernel.org, abe@purdue.edu,
        lsof-l@lists.purdue.edu, util-linux@vger.kernel.org
Subject: Re: [PATCH 00/10] exposing knfsd opens to userspace
Message-ID: <20190425200100.GA9889@fieldses.org>
References: <1556201060-7947-1-git-send-email-bfields@redhat.com>
 <8d8bb81a1d0299395ec6c75a86d4ce0e7d6a53c6.camel@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <8d8bb81a1d0299395ec6c75a86d4ce0e7d6a53c6.camel@redhat.com>
User-Agent: Mutt/1.5.21 (2010-09-15)
From:   bfields@fieldses.org (J. Bruce Fields)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Thu, Apr 25, 2019 at 01:02:30PM -0400, Jeff Layton wrote:
> On Thu, 2019-04-25 at 10:04 -0400, J. Bruce Fields wrote:
> > From: "J. Bruce Fields" <bfields@redhat.com>
> > 
> > The following patches expose information about NFSv4 opens held by knfsd
> > on behalf of NFSv4 clients.  Those are currently invisible to userspace,
> > unlike locks (/proc/locks) and local proccesses' opens (/proc/<pid>/).
> > 
> > The approach is to add a new directory /proc/fs/nfsd/clients/ with
> > subdirectories for each active NFSv4 client.  Each subdirectory has an
> > "info" file with some basic information to help identify the client and
> > an "opens" directory that lists the opens held by that client.
> > 
> > I got it working by cobbling together some poorly-understood code I
> > found in libfs, rpc_pipefs and elsewhere.  If anyone wants to wade in
> > and tell me what I've got wrong, they're more than welcome, but at this
> > stage I'm more curious for feedback on the interface.
> > 
> > I'm also cc'ing people responsible for lsof and util-linux in case they
> > have any opinions.
> > 
> > Currently these pseudofiles look like:
> > 
> >   # find /proc/fs/nfsd/clients -type f|xargs tail 
> >   ==> /proc/fs/nfsd/clients/3741/opens <==
> >   5cc0cd36/6debfb50/00000001/00000001	rw	--	fd:10:13649	'open id:\x00\x00\x00&\x00\x00\x00\x00\x00\x00\x0b\xb7\x89%\xfc\xef'
> >   5cc0cd36/6debfb50/00000003/00000001	r-	--	fd:10:13650	'open id:\x00\x00\x00&\x00\x00\x00\x00\x00\x00\x0b\xb7\x89%\xfc\xef'
> > 
> >   ==> /proc/fs/nfsd/clients/3741/info <==
> >   clientid: 6debfb505cc0cd36
> >   address: 192.168.122.36:0
> >   name: Linux NFSv4.2 test2.fieldses.org
> >   minor version: 2
> > 
> > Each line of the "opens" file is tab-delimited and describes one open,
> > and the fields are stateid, open access bits, deny bits,
> > major:minor:ino, and open owner.
> > 
> 
> Nice work! We've needed this for a long time.
> 
> One thing we need to consider here from the get-go though is what sort
> of ABI guarantee you want for this format. People _will_ write scripts
> that scrape this info, so we should take that into account up front.

There is a man page for the nfsd filesystem, nfsd(7).  I should write up
something to add to that.  If people write code without reading that
then we may still end up boxed in, of course, but it's a start.

What I'm hoping we can count on from readers:

	- they will ignore any unkown files in clients/#/.
	- readers will ignore any lines in clients/#/info starting with
	  an unrecognized keyword.
	- they will ignore any unknown data at the end of
	  clients/#/opens.

That's in approximate decreasing order of my confidence in those rules
being observed, though I don't think any of those are too much to ask.

> > So, some random questions:
> > 
> > 	- I just copied the major:minor:ino thing from /proc/locks, I
> > 	  suspect we would have picked something different to identify
> > 	  inodes if /proc/locks were done now.  (Mount id and inode?
> > 	  Something else?)
> > 
> 
> That does make it easy to correlate with the info in /proc/locks.
> 
> We'd have a dentry here by virtue of the nfs4_file. Should we print a
> path in addition to this?

We could.  It won't be 100% reliable, of course (unlinks, renames), but
it could still be convenient for human readers, and an optimization for
non-human readers trying to find an inode.

The filehandle might be a good idea too.

I wonder if there's any issue with line length, or with quantity of data
emitted by a single seq_file show method.  The open owner can be up to
4K (after escaping), paths and filehandles can be long too.

> > 	- The open owner is just an opaque blob of binary data, but
> > 	  clients may choose to include some useful asci-encoded
> > 	  information, so I'm formatting them as strings with non-ascii
> > 	  stuff escaped.  For example, pynfs usually uses the name of
> > 	  the test as the open owner.  But as you see above, the ascii
> > 	  content of the Linux client's open owners is less useful.
> > 	  Also, there's no way I know of to map them back to a file
> > 	  description or process or anything else useful on the client,
> > 	  so perhaps they're of limited interest.
> > 
> > 	- I'm not sure about the stateid either.  I did think it might
> > 	  be useful just as a unique identifier for each line.
> > 	  (Actually for that it'd be enough to take just the third of
> > 	  those four numbers making up the stateid--maybe that would be
> > 	  better.)
> 
> It'd be ideal to be able to easily correlate this info with what
> wireshark displays. Does wireshark display hashes for openowners? I know
> it does for stateids. If so, generating the same hash would be really
> nice.
> 
> That said, waybe it's best to just dump the raw info out here though and
> rely on some postprocessing scripts for viewing it?

In that case, I think so, as I don't know how committed wireshark is to
the choice of hash.

> > In the "info" file, the "name" line is the client identifier/client
> > owner provided by the client, which (like the stateowner) is just opaque
> > binary data, though as you can see here the Linux client is providing a
> > readable ascii string.
> > 
> > There's probably a lot more we could add to that info file eventually.
> > 
> > Other stuff to add next:
> > 
> > 	- nfsd/clients/#/kill that you can write to to revoke all a
> > 	  client's state if it's wedged somehow.
> 
> That would also be neat. We have a bit of code to support today that in
> the fault injection code, but it'll need some cleanup and wiring it into
> a knob here would be better.

OK, good, I'm working on that.  Looks like fault injection gives up if
there are rpc's in process for the given client, whereas here I'd rather
force the expiry.  Looks like that needs some straightforward waitqueue
logic to wait for the in-progress rpc's.

--b.
