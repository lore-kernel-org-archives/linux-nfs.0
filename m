From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [NFS] [PATCH 2/18] exportfs: add fid type
Date: Wed, 28 Mar 2007 19:35:20 -0400
Message-ID: <20070328233520.GL21221@fieldses.org>
References: <20070317011009.GC24947@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net, linux-fsdevel@vger.kernel.org
To: Christoph Hellwig <hch@infradead.org>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <20070317011009.GC24947@infradead.org>
Sender: linux-fsdevel-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

On Sat, Mar 17, 2007 at 01:10:09AM +0000, Christoph Hellwig wrote:
> Add a structured fid type so that we don't have to pass an array
> of u32 values around everywhere.  It's a union of possible layouts.
> As a start there's only the u32 array and the traditional 32bit
> inode format, but there will be more in one of my next patchset
> when I start to document the various filehandle formats we have
> in lowlevel filesystems better.
> 
> Also add an enum that gives the various filehandle types humand
> readable names.
> 
> Note:  Some people might think the struct containing an anonymous
> union is ugly, but I didn't want to pass around a raw union type.

A basic question: what do these apply against?  For example, I don't
have this file:

> Index: linux-2.6/include/linux/exportfs.h
> ===================================================================
> --- linux-2.6.orig/include/linux/exportfs.h	2007-03-16 15:44:02.000000000 +0100
> +++ linux-2.6/include/linux/exportfs.h	2007-03-16 15:44:09.000000000 +0100

--b.
