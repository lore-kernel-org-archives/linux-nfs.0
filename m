Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:45971 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755185AbZANPiu (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 14 Jan 2009 10:38:50 -0500
Message-ID: <496E0707.70606@redhat.com>
Date: Wed, 14 Jan 2009 10:38:47 -0500
From: Peter Staubach <staubach@redhat.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
CC: Nick Piggin <nickpiggin@yahoo.com.au>,
        NFS list <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] out of order WRITE requests
References: <496D1642.6060608@redhat.com> <1231887217.7036.24.camel@heimdal.trondhjem.org>
In-Reply-To: <1231887217.7036.24.camel@heimdal.trondhjem.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Trond Myklebust wrote:
>
> Heh.... I happen to have a _very_ similar patch that is basically
> designed to prevent new pages from being dirtied, and thus allowing
> those cache consistency flushes at close() and stat() to make progress.
> The difference is that I'm locking over nfs_write_mapping() instead of
> nfs_writepages()...
>
> Perhaps we should combine the two patches? If so, we need to convert
> nfs_write_mapping() to only flush once using the WB_SYNC_ALL mode,
> instead of the current 2 pass system...

Heh, indeed!  :-)

The combined patch looks fine to me, although I will have to
look at the changes to nfs_write_begin and nfs_write_mapping
to understand what their ramifications are.

I have another patch to propose which adds some flow control
to allow the NFS client to better control the number of pages
which can be dirtied per file.  I implemented this support in
response to a customer who had a server which required in-
order WRITE requests in order to function correctly.  It
also could not handle too much data being sent to it at a
time, so it functioned better when the client spaced out the
sending of data more smoothly.

It turns out that this framework can be used to solve the
stat() problem quite neatly.

I will construct a patch which applies on top of the combined
patch and post that, if that is okay.

    Thanx...

       ps
