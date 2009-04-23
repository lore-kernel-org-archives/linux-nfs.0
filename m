From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 3/11] nfsd: CHANGE old function calls to new calls
Date: Thu, 23 Apr 2009 18:39:09 -0400
Message-ID: <20090423223909.GF1906@fieldses.org>
References: <20090325133607.16437.33288.sendpatchset@localhost.localdomain> <20090325133707.16437.66360.sendpatchset@localhost.localdomain> <20090422200553.GH9541@fieldses.org> <OFB63DF5D6.1A77785C-ON652575A1.004F6726-652575A1.00577C61@in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jlayton@redhat.com, Krishna Kumar <krikku@gmail.com>,
	linux-nfs@vger.kernel.org
To: Krishna Kumar2 <krkumar2@in.ibm.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([141.211.133.115]:35533 "EHLO
	pickle.fieldses.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751575AbZDWWjR (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 23 Apr 2009 18:39:17 -0400
In-Reply-To: <OFB63DF5D6.1A77785C-ON652575A1.004F6726-652575A1.00577C61@in.ibm.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Apr 23, 2009 at 09:25:34PM +0530, Krishna Kumar2 wrote:
> Hi Bruce,
> 
> (combining all three of your mails into one response for easier tracking)
> 
> "J. Bruce Fields" <bfields@fieldses.org> wrote on 04/23/2009 01:35:53 AM:
> 
> > How do you know fh_auth[3] is sufficient to identify the file reliably?
> > This looks very fragile to me.
> >
> > If the goal is to bypass rqst_exp_find(), exportfs_decode_fh() and
> > friends--that makes me nervous.  We should figure out how to make those
> > lookups faster instead.  Or at the very least, make sure we're keying on
> > the entire filehandle instead of just part of it.
> 
> To understand how filehandles works, I was looking at nfsd_set_fh_dentry,
> here fid is fh->auth[2] (since type is FSID_DEV). However, the unique FH
> value is stored in fh->auth[3], while auth[0]/[1] contains the maj/min and
> ino. fh->auth[3] is unique for different files and across file systems, but
> it is not actually used to find the file (only the exp) - the stored
> dev/ino
> (auth[0] and auth[1]) are used to find the dentry by calling the underlying
> filesystem (exportfs_decode_fh).
> 
> Keying on the entire filehandle seems reasonable, but I don't think it is
> required as auth[3] seems to be allocated memory which is unique in a
> system,

You lost me.  Where do you see auth[3] getting encoded, and what do you
mean by saying it's "allocated memory which is unique in a system"?

There are a lot of different filehandle encoding options.  I lose track
of them myself....

> just that we don't use it for locating the file currently and I was
> proposing
> that we do. Please correct me if this is wrong, or whether a better way is
> possible.
> 
> > This patch doesn't change anything--it only adds new lines.  If you're
> > trying to make minimal changes, that's admirable, but break up the
> > patches in such a way that each patch shows that minimal change.
> 
> To make each revision compile cleanly, I had to add the infrastructure and
> then delete the old one. So it looks like new code. The entire function and
> data structures are re-written so it is difficult to break into individual
> components where each will compile clean.

Breaking up a complex change into logical individual steps, each of
which compile and run cleanly, is sometimes tricky.  So it may be that
there *is* some way to do it in this case, but that you just haven't
found it yet.

That said, it could be, as you say, that this requires just replacing
everything.  In that case, please just start over from scratch and don't
feel bound to keep stuff from the old implementation that you don't
understand.

--b.

> > By "noisy" I just mean that they look like there's a lot of randomness.
> > So, yes, I'm fine with a subset, but I'm curious what the variance is on
> > repeated runs of each test.
> 
> Sure, I will try to do this over the weekend and submit.
> 
> thanks,
> 
> - KK
> 
