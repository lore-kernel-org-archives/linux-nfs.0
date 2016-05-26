Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from resqmta-po-03v.sys.comcast.net ([96.114.154.162]:40129 "EHLO
	resqmta-po-03v.sys.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754279AbcEZSjq (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 26 May 2016 14:39:46 -0400
Date: Thu, 26 May 2016 11:31:34 -0700
From: Tom Haynes <loghyr@excfb.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Andy Adamson <androsadamson@gmail.com>,
        Chuck Lever <chuck.lever@oracle.com>,
        "Adamson, Andy" <William.Adamson@netapp.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Configuring flex file DS on Linux upstream
Message-ID: <20160526183134.GA30979@psyklo.internal.excfb.com>
References: <04273F60-806B-4E12-B097-388C346F2DED@oracle.com>
 <40E6E131-029E-4337-A235-B1DB5CA687AA@netapp.com>
 <20160525184837.GA15210@fieldses.org>
 <9614D777-9C75-4FBB-BD06-4EC366273B49@oracle.com>
 <CAHVgHyVEx1fUP36tHaB-uBMJmC3gqCeQ5PSgaHm9XrAWQqerqw@mail.gmail.com>
 <20160526152253.GC21450@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20160526152253.GC21450@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

fwiw, I'm looking at being able to specify a remote DS for the next version
of the flex file server. Is it worth considering that in the discussion
being done in Andy's thread about "Configuring fs_locations on Linux upstream server pseudo fs for session trunking"?

For example:

/mds *(rw,pnfs,ff_ds=192.168.2.101.2049:/ds,insecure,no_root_squash,no_all_squash)

And in the far future, I'd want it to be a multipath list.

I don't see this as something that changes often and the exports
seem like the most natural fit.
