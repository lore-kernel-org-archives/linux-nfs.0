Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:42444 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751653Ab3EHS4i (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 8 May 2013 14:56:38 -0400
Date: Wed, 8 May 2013 14:56:35 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Cc: Steve Dickson <SteveD@redhat.com>,
        "David P. Quigley" <dpquigl@tycho.nsa.gov>,
        Linux NFS list <linux-nfs@vger.kernel.org>,
        Linux FS devel list <linux-fsdevel@vger.kernel.org>,
        Linux Security List <linux-security-module@vger.kernel.org>,
        SELinux List <selinux@tycho.nsa.gov>
Subject: Re: [PATCH 09/17] NFSv4: Introduce new label structure
Message-ID: <20130508185635.GB11497@pad.fieldses.org>
References: <1367240239-19326-1-git-send-email-SteveD@redhat.com>
 <1367240239-19326-10-git-send-email-SteveD@redhat.com>
 <1367434764.4189.33.camel@leira.trondhjem.org>
 <518A8C3D.9000407@RedHat.com>
 <1368036382.5978.24.camel@leira.trondhjem.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1368036382.5978.24.camel@leira.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, May 08, 2013 at 06:06:24PM +0000, Myklebust, Trond wrote:
> On Wed, 2013-05-08 at 13:32 -0400, Steve Dickson wrote:
> > Not the label but the inode. The bit is set in ACCESS, LOOKUP, 
> > LINK, OPEN, CREAT, SETATTR which all clearly update the inode.
> > 
> > So I guess my question is if the bit is not set in any of these 
> > ops how do we know if the label has changed? Should label changes
> > be synchronized with inode updates? 
> 
> I know that Bruce doesn't like FATTR4_CHANGE_SEC_LABEL,

Not true at all, sorry to give that impression.

It doesn't look like a lot of work to implement (how much work would it
be to use on the client side?), and I'd be perfectly happy if someone
would do so.

It's just that noone's volunteered, and my todo list is out of control
as it is.

> but that is the
> only option I can see for implementing a cache consistency model for
> labels. Without it, the choices are:
> 
> 1) always fetch the label as part of every COMPOUND.
> 2) assume the label never changes on the server.
> 
> The main use cases that have been presented for Labeled NFS on Linux
> would tend to push me towards door number 2, Monty please...

And that's fine with me too.

--b.
