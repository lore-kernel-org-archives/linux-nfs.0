Return-Path: linux-nfs-owner@vger.kernel.org
Received: from idcmail-mo2no.shaw.ca ([64.59.134.9]:49219 "EHLO
	idcmail-mo2no.shaw.ca" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755344Ab2EJQFa (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 10 May 2012 12:05:30 -0400
Subject: Re: Extended file stat: Splitting file- and fs-specific info?
Mime-Version: 1.0 (Apple Message framework v1084)
Content-Type: text/plain; charset=us-ascii
From: Andreas Dilger <adilger@dilger.ca>
In-Reply-To: <14477.1336641794@redhat.com>
Date: Thu, 10 May 2012 10:05:28 -0600
Cc: Andreas Dilger <aedilger@gmail.com>, Dave Chinner <david@fromorbit.com>,
        "bfields@fieldses.org" <bfields@fieldses.org>,
        "smfrench@gmail.com" <smfrench@gmail.com>,
        "ben@decadent.org.uk" <ben@decadent.org.uk>,
        "Trond.Myklebust@netapp.com" <Trond.Myklebust@netapp.com>,
        "roland@hack.frob.com" <roland@hack.frob.com>,
        "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "linux-cifs@vger.kernel.org" <linux-cifs@vger.kernel.org>,
        "samba-technical@lists.samba.org" <samba-technical@lists.samba.org>,
        "linux-ext4@vger.kernel.org" <linux-ext4@vger.kernel.org>,
        "linux-api@vger.kernel.org" <linux-api@vger.kernel.org>,
        "libc-alpha@sourceware.org" <libc-alpha@sourceware.org>
Message-Id: <3DA7C6A5-E47C-47D4-BFBB-3E608492BD0B@dilger.ca>
References: <73759631-F1E4-4352-9FE6-E9F576F793FB@gmail.com> <20120419140558.17272.74360.stgit@warthog.procyon.org.uk> <16281.1336508382@redhat.com> <20120509002420.GL5091@dastard> <14477.1336641794@redhat.com>
To: David Howells <dhowells@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 2012-05-10, at 3:23 AM, David Howells wrote:
> Andreas Dilger <aedilger@gmail.com> wrote:
>> The main question I have about these fields is what the difference is
>> between st_blksize and st_alloc_blksize?
> 
> I would assume that st_blksize is some ideal I/O size, not the
> allocation block size.

But there are several optimal IO sizes, so unless there is a clear
description of what each of these fields is intended to be used for,
it doesn't make sense to add them in.

> Dave Chinner might be able to answer better as he suggested these
> I/O information fields.
> 
> David


Cheers, Andreas





