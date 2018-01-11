Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:40880 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754549AbeAKPRi (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 11 Jan 2018 10:17:38 -0500
Date: Thu, 11 Jan 2018 10:17:38 -0500
From: Bruce Fields <bfields@fieldses.org>
To: Steve Dickson <SteveD@RedHat.com>
Cc: Chuck Lever <chuck.lever@oracle.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH RFC 0/3] Add server-side support for junctions to
 nfs-utils
Message-ID: <20180111151738.GB4839@fieldses.org>
References: <20180108213356.20133.54161.stgit@manet.1015granger.net>
 <20180109192100.GB18087@fieldses.org>
 <492B1883-83EE-40AF-AA8C-1B797D842E5E@oracle.com>
 <01acd06d-98d4-c6ff-5ef1-b6edbb447405@RedHat.com>
 <6D1A900F-3F5C-4D70-9466-69ECC4985544@oracle.com>
 <d3a5175c-a330-ac7a-67ed-19cfc5363ec1@RedHat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <d3a5175c-a330-ac7a-67ed-19cfc5363ec1@RedHat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Jan 11, 2018 at 09:20:54AM -0500, Steve Dickson wrote:
> On 01/10/2018 02:42 PM, Chuck Lever wrote:
> > I don't have any quarrel with carving out the non-network-exposed
> > functionality of mountd and putting it in an upcall similar to
> > nfsidmap. Seems like an entirely separate project, though, and
> > probably a significant chunk of work.
> It is... I was just floating the idea. 

Yeah, I don't mean to veto the idea, I think we've discussed it before
and it's kind of appealing.  I just think we haven't thought it through
and we don't have any real reason it's necessary right now.  I'd hate to
send someone down that rabbit hole and have the come back with a bunch
of work and us say "uh, but why do we want this?".

--b.
