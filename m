Return-Path: linux-nfs-owner@vger.kernel.org
Received: from hapkido.dreamhost.com ([66.33.216.122]:39669 "EHLO
	hapkido.dreamhost.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751495Ab3JaVhQ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 31 Oct 2013 17:37:16 -0400
Received: from homiemail-a110.g.dreamhost.com (caiajhbdcaid.dreamhost.com [208.97.132.83])
	by hapkido.dreamhost.com (Postfix) with ESMTP id 49E76DE9BC
	for <linux-nfs@vger.kernel.org>; Thu, 31 Oct 2013 14:37:16 -0700 (PDT)
Date: Thu, 31 Oct 2013 16:36:33 -0500
From: Nico Williams <nico@cryptonector.com>
To: Anand Avati <aavati@redhat.com>
Cc: eshel@us.ibm.com, Linux NFS list <linux-nfs@vger.kernel.org>,
        nfsv4@ietf.org, nfsv4-bounces@ietf.org,
        Steve Dickson <SteveD@redhat.com>
Subject: Re: [nfsv4] XATTRs in NFS
Message-ID: <20131031213630.GA32733@gmail.com>
References: <OF7DBE5533.A67587D8-ON88257C12.007C1560-88257C12.007CA986@us.ibm.com>
 <5272742D.7000905@redhat.com>
 <5272C397.6020201@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <5272C397.6020201@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Oct 31, 2013 at 01:54:47PM -0700, Anand Avati wrote:
> >2. Why are current named attributes in NFS not the right answer.
> 
> I think they might be, if we can map user.XXXX xattrs to named
> attributes and avoid any sort of interpretation of they key/values
> by NFS. Though from my point of view, all I care is for
> getxattr/setxattr of user.XXX keys to "just work" (whether they are
> mapped to named attributes or implemented as a separate feature).

That's an open question.  Are writes to xattrs supposed to be atomic?

Anyways, it seems at least one filesystem (XFS) maps xattrs onto a
hidden data fork (named attribute) for that purpose.  So, I'm guessing:
a) no, they're not atomic, b) named attributes should work... c) if
only we had a namespace to steal names from for this purpose.

Nico
-- 
