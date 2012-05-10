Return-Path: linux-nfs-owner@vger.kernel.org
Received: from toast.topped-with-meat.com ([204.197.218.159]:44782 "EHLO
	topped-with-meat.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754998Ab2EJRKU (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 10 May 2012 13:10:20 -0400
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
From: Roland McGrath <roland@hack.frob.com>
To: David Howells <dhowells@redhat.com>
Cc: Andreas Dilger <aedilger@gmail.com>, Dave Chinner <david@fromorbit.com>,
        "adilger@dilger.ca" <adilger@dilger.ca>,
        "bfields@fieldses.org" <bfields@fieldses.org>,
        "smfrench@gmail.com" <smfrench@gmail.com>,
        "ben@decadent.org.uk" <ben@decadent.org.uk>,
        "Trond.Myklebust@netapp.com" <Trond.Myklebust@netapp.com>,
        "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "linux-cifs@vger.kernel.org" <linux-cifs@vger.kernel.org>,
        "samba-technical@lists.samba.org" <samba-technical@lists.samba.org>,
        "linux-ext4@vger.kernel.org" <linux-ext4@vger.kernel.org>,
        "linux-api@vger.kernel.org" <linux-api@vger.kernel.org>,
        "libc-alpha@sourceware.org" <libc-alpha@sourceware.org>
Subject: Re: Extended file stat: Splitting file- and fs-specific info?
In-Reply-To: David Howells's message of  Thursday, 10 May 2012 10:23:14 +0100 <14477.1336641794@redhat.com>
References: <73759631-F1E4-4352-9FE6-E9F576F793FB@gmail.com>
	<20120419140558.17272.74360.stgit@warthog.procyon.org.uk>
	<16281.1336508382@redhat.com>
	<20120509002420.GL5091@dastard>
	<14477.1336641794@redhat.com>
Message-Id: <20120510171016.B45BA2C096@topped-with-meat.com>
Date: Thu, 10 May 2012 10:10:16 -0700 (PDT)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

POSIX specifies st_blksize thusly: "A file system-specific preferred I/O
block size for this object. In some file system types, this may vary from
file to file."

Since there is only one available to POSIX applications, it should map to
the one that's described as "preferred IO size for general usage".


Thanks,
Roland

