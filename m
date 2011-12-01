Return-Path: linux-nfs-owner@vger.kernel.org
Received: from smtp.mail.umich.edu ([141.211.14.81]:39123 "EHLO
	hackers.mr.itd.umich.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755736Ab1LARgq (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 1 Dec 2011 12:36:46 -0500
Date: Thu, 1 Dec 2011 12:36:42 -0500
From: Jim Rees <rees@umich.edu>
To: bjschuma@netapp.com
Cc: linux-nfs@vger.kernel.org
Subject: Re: [RFC 0/4] NFS: Modularize NFS v3
Message-ID: <20111201173642.GB11436@umich.edu>
References: <1322758102-29260-1-git-send-email-bjschuma@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1322758102-29260-1-git-send-email-bjschuma@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

bjschuma@netapp.com wrote:

  From: Bryan Schumaker <bjschuma@netapp.com>
  
  This set of patches removes NFS v3 from the main NFS kernel module and creates
  a new module containing the proc, xdr, and acl code.  This will give us a
  single directory to put NFS v3 specific code so it doesn't need to be mixed in
  with the generic client stuff.

Thanks!  Is v4 next?  This will come in handy when we implement v5.

But seriously...  If we take this to its logical conclusion, won't we need a
subdirectory for nfs4?  And if we do that, will block and object layout be
subdirectories of nfs, or of v4?

And while we're at it, should file layout move to a subdir like block and
object?

And what about v2?  There's only nfs2xdr.c, so a subdir seems like overkill.
