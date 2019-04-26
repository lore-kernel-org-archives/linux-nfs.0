Return-Path: <SRS0=vcFy=S4=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C63E5C43219
	for <linux-nfs@archiver.kernel.org>; Fri, 26 Apr 2019 01:18:06 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id A174C20878
	for <linux-nfs@archiver.kernel.org>; Fri, 26 Apr 2019 01:18:06 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1729501AbfDZBSF (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 25 Apr 2019 21:18:05 -0400
Received: from fieldses.org ([173.255.197.46]:52054 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1727782AbfDZBSF (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 25 Apr 2019 21:18:05 -0400
Received: by fieldses.org (Postfix, from userid 2815)
        id 8816A1C98; Thu, 25 Apr 2019 21:18:04 -0400 (EDT)
Date:   Thu, 25 Apr 2019 21:18:04 -0400
From:   "J. Bruce Fields" <bfields@fieldses.org>
To:     Andreas Dilger <adilger@dilger.ca>
Cc:     Jeff Layton <jlayton@redhat.com>,
        "J. Bruce Fields" <bfields@redhat.com>,
        linux-nfs <linux-nfs@vger.kernel.org>,
        linux-fsdevel@vger.kernel.org, abe@purdue.edu,
        lsof-l@lists.purdue.edu, util-linux@vger.kernel.org
Subject: Re: [PATCH 08/10] nfsd4: add file to display list of client's opens
Message-ID: <20190426011804.GA12457@fieldses.org>
References: <1556201060-7947-1-git-send-email-bfields@redhat.com>
 <1556201060-7947-9-git-send-email-bfields@redhat.com>
 <d26e7611f4e610bff81a16abbb88ca1c5ed70c91.camel@redhat.com>
 <20190425201413.GB9889@fieldses.org>
 <7F460FEA-BD69-4559-926C-5C1B0CF90E3C@dilger.ca>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <7F460FEA-BD69-4559-926C-5C1B0CF90E3C@dilger.ca>
User-Agent: Mutt/1.5.21 (2010-09-15)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Thu, Apr 25, 2019 at 11:14:23PM +0200, Andreas Dilger wrote:
> On Apr 25, 2019, at 10:14 PM, J. Bruce Fields <bfields@fieldses.org> wrote:
> > 
> > On Thu, Apr 25, 2019 at 02:04:59PM -0400, Jeff Layton wrote:
> >> More bikeshedding: should we have a "states" file instead of an "opens"
> >> file and print a different set of output for each stateid type?
> > 
> > Sure.  The format of the file could be something like
> > 
> > 	<stateid> open rw -- <openowner>...
> > 	<stateid> lock r 0-EOF <lockowner>...
> > 	<stateid> deleg r
> > 
> > I wonder if we could put owners on separate lines and do some
> > heirarchical thing to show owner-stateid relationships?  Hm.  That's
> > kind of appealing but more work.
> 
> My suggestion here would be to use YAML-formatted output rather than
> space/tab separated positional fields.  That can still be made human
> readable, but also machine parseable and extensible if formatted properly.

Well, anything we do will be machine-parseable.  But I can believe YAML
would make future extension easier.  It doesn't look like it would be
more complicated to generate.  It uses C-style escaping (like \x32) so
there'd be no change to how we format binary blobs.

The field names make it a tad more verbose but I guess it's not too bad.

> Something like the following (use https://yaml-online-parser.appspot.com/
> to validate the formatting):
> 
> - <stateid>: { state: open, mode: rw, owner: <openowner> }
> - <stateid>: { state: lock, mode: r, start: 0, end: EOF, owner: <openowner> }

I haven't noticed other kernel interfaces using YAML.  But I guess I'm
not coming up with any real objection.

--b.
