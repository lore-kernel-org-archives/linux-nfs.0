From: Krishna Kumar2 <krkumar2@in.ibm.com>
Subject: Re: [PATCH 3/11] nfsd: CHANGE old function calls to new calls
Date: Thu, 23 Apr 2009 21:25:34 +0530
Message-ID: <OFB63DF5D6.1A77785C-ON652575A1.004F6726-652575A1.00577C61@in.ibm.com>
References: <20090325133607.16437.33288.sendpatchset@localhost.localdomain> <20090325133707.16437.66360.sendpatchset@localhost.localdomain> <20090422200553.GH9541@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: jlayton@redhat.com, Krishna Kumar <krikku@gmail.com>,
	linux-nfs@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from e28smtp08.in.ibm.com ([59.145.155.8]:36726 "EHLO
	e28smtp08.in.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751271AbZDWP4Q (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 23 Apr 2009 11:56:16 -0400
Received: from d28relay02.in.ibm.com (d28relay02.in.ibm.com [9.184.220.59])
	by e28smtp08.in.ibm.com (8.13.1/8.13.1) with ESMTP id n3NFIW0b026979
	for <linux-nfs@vger.kernel.org>; Thu, 23 Apr 2009 20:48:32 +0530
Received: from d28av01.in.ibm.com (d28av01.in.ibm.com [9.184.220.63])
	by d28relay02.in.ibm.com (8.13.8/8.13.8/NCO v9.2) with ESMTP id n3NFpw4Y3956802
	for <linux-nfs@vger.kernel.org>; Thu, 23 Apr 2009 21:21:58 +0530
Received: from d28av01.in.ibm.com (loopback [127.0.0.1])
	by d28av01.in.ibm.com (8.13.1/8.13.3) with ESMTP id n3NFuB2F011837
	for <linux-nfs@vger.kernel.org>; Thu, 23 Apr 2009 21:26:11 +0530
In-Reply-To: <20090422200553.GH9541@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Bruce,

(combining all three of your mails into one response for easier tracking)

"J. Bruce Fields" <bfields@fieldses.org> wrote on 04/23/2009 01:35:53 AM:

> How do you know fh_auth[3] is sufficient to identify the file reliably?
> This looks very fragile to me.
>
> If the goal is to bypass rqst_exp_find(), exportfs_decode_fh() and
> friends--that makes me nervous.  We should figure out how to make those
> lookups faster instead.  Or at the very least, make sure we're keying on
> the entire filehandle instead of just part of it.

To understand how filehandles works, I was looking at nfsd_set_fh_dentry,
here fid is fh->auth[2] (since type is FSID_DEV). However, the unique FH
value is stored in fh->auth[3], while auth[0]/[1] contains the maj/min and
ino. fh->auth[3] is unique for different files and across file systems, but
it is not actually used to find the file (only the exp) - the stored
dev/ino
(auth[0] and auth[1]) are used to find the dentry by calling the underlying
filesystem (exportfs_decode_fh).

Keying on the entire filehandle seems reasonable, but I don't think it is
required as auth[3] seems to be allocated memory which is unique in a
system,
just that we don't use it for locating the file currently and I was
proposing
that we do. Please correct me if this is wrong, or whether a better way is
possible.

> This patch doesn't change anything--it only adds new lines.  If you're
> trying to make minimal changes, that's admirable, but break up the
> patches in such a way that each patch shows that minimal change.

To make each revision compile cleanly, I had to add the infrastructure and
then delete the old one. So it looks like new code. The entire function and
data structures are re-written so it is difficult to break into individual
components where each will compile clean.

> By "noisy" I just mean that they look like there's a lot of randomness.
> So, yes, I'm fine with a subset, but I'm curious what the variance is on
> repeated runs of each test.

Sure, I will try to do this over the weekend and submit.

thanks,

- KK

