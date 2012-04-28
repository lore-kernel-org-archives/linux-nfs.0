Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qc0-f174.google.com ([209.85.216.174]:43146 "EHLO
	mail-qc0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758446Ab2D1AyN (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 27 Apr 2012 20:54:13 -0400
MIME-Version: 1.0
In-Reply-To: <20120428003833.GH9541@dastard>
References: <20120419140558.17272.74360.stgit@warthog.procyon.org.uk>
	<20120427010610.GE9541@dastard>
	<ED5B8F1B-6C99-4516-85FA-A767E94B635F@dilger.ca>
	<20120428003833.GH9541@dastard>
Date: Fri, 27 Apr 2012 19:54:12 -0500
Message-ID: <CAH2r5ms2b=5zOFA0+E+Nf9oot+5Q3Ye42ET62_P6hnrD8HTt7w@mail.gmail.com>
Subject: Re: [PATCH 0/6] Extended file stat system call
From: Steve French <smfrench@gmail.com>
To: Dave Chinner <david@fromorbit.com>
Cc: Andreas Dilger <adilger@whamcloud.com>,
        David Howells <dhowells@redhat.com>, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org, linux-cifs@vger.kernel.org,
        samba-technical@lists.samba.org, linux-ext4@vger.kernel.org,
        wine-devel@winehq.org, linux-api@vger.kernel.org,
        libc-alpha@sourceware.org
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Apr 27, 2012 at 7:38 PM, Dave Chinner <david@fromorbit.com> wrote:
> preferred minimum IO size (mp->m_readio_log/mp->m_writeio_log)

This discussion about i/o sizes is very interesting.   For network
file system (at least for SMB2 to all known servers, and
for cifs mounts to Samba, but probably for recent NFS), ideal i/o
sizes are often well over a megabyte ... but how to indicate that to
the application...

> That's why I'd prefer specific optimal IO hints - we don't have to
> overload st_blksize with lots of meanings to pass what is relatively
> trivial information back to the application.
>
> Cheers,
>
> Dave.
> --
> Dave Chinner

Yes.




-- 
Thanks,

Steve
