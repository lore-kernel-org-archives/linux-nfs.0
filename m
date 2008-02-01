From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH 3/3] enhanced NFS ESTALE error handling (v2)
Date: Fri, 01 Feb 2008 16:06:57 -0500
Message-ID: <1201900017.11291.43.camel@heimdal.trondhjem.org>
References: <4790C76F.2050105@redhat.com>  <47A387D9.1070206@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	linux-nfs@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>,
	linux-fsdevel <linux-fsdevel@vger.kernel.org>
To: Peter Staubach <staubach@redhat.com>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <47A387D9.1070206@redhat.com>
Sender: linux-fsdevel-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Fri, 2008-02-01 at 15:58 -0500, Peter Staubach wrote:
> Hi.
> 
> The patch enhanced the ESTALE error handling for NFS mounted
> file systems.  It expands the number of places that the NFS
> client checks for ESTALE returns from the server.
> 
> It also enhances the ESTALE handling for directories by
> occasionally retrying revalidation to check to see whether the
> directory becomes valid again.  This sounds odd, but can occur
> when a systems administrator, accidently or unknowingly,
> unexports a file system which is in use.  All active
> non-directory files become permanently inaccessible, but
> directories can be become accessible again after the
> administrator re-exports the file system.  This is a situation
> that users have been complaining about for years and this
> support can help to alleviate their situations.

As far as I can see, this patch can be applied separately from the VFS
fixes. If so, would it make sense for me to take charge of this patch in
the NFS tree, while Andrew queues up the other two VFS changes in -mm?

Cheers
  Trond

