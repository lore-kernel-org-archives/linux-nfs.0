Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:47010 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751675Ab3HZRLV (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 26 Aug 2013 13:11:21 -0400
Date: Mon, 26 Aug 2013 13:11:19 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Jeff Layton <jlayton@redhat.com>
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>, linux-nfs@vger.kernel.org,
        Jan Stancek <jstancek@redhat.com>
Subject: Re: [PATCH v3] SUNRPC: Ensure that the RPCSEC_GSS daemon uses the
 correct service names
Message-ID: <20130826171119.GA13212@fieldses.org>
References: <1377202213-5031-1-git-send-email-jlayton@redhat.com>
 <20130823231843.GB18084@fieldses.org>
 <20130824124314.GD18084@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20130824124314.GD18084@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, Aug 24, 2013 at 08:43:14AM -0400, J. Bruce Fields wrote:
> On Fri, Aug 23, 2013 at 07:18:43PM -0400, J. Bruce Fields wrote:
> > On Thu, Aug 22, 2013 at 04:10:13PM -0400, Jeff Layton wrote:
> > > From: Trond Myklebust <Trond.Myklebust@netapp.com>
> > > 
> > > v2: added pipe_dir_name field to nfsacl program to fix v3+krb5
> > >     (Should we add pipe_dir_name fields to other programs too?).
> > > 
> > > v3: Drop changes to gss_encode_v1_msg. They don't seem to be
> > >     needed since gssd scrapes that out of the "info" file.
> > 
> > Hm.  nfsv3/krb5 is still broken for me after this patch.  I'll try to
> > figure out why....
> 
> Whoops, never mind, my client was booted to the wrong kernel, with this
> patch it does work.

Oh, and by the way, I made the same mistake testing Jan's original patch
(installed the patched kernel to the server but not the client...).
Retesting, it worked fine too.

--b.
