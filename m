Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:36433 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751762Ab0JRRFD (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 18 Oct 2010 13:05:03 -0400
Date: Mon, 18 Oct 2010 13:04:59 -0400
To: Boaz Harrosh <bharrosh@panasas.com>
Cc: Jesper Krogh <jesper@krogh.cc>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: lsof and open files from the nfs-server
Message-ID: <20101018170459.GA3744@fieldses.org>
References: <4CB62095.4010708@krogh.cc>
 <4CBC74E8.7070801@panasas.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4CBC74E8.7070801@panasas.com>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Mon, Oct 18, 2010 at 06:25:12PM +0200, Boaz Harrosh wrote:
> On 10/13/2010 11:11 PM, Jesper Krogh wrote:
> > Hi.
> > 
> > Quite often when you have to umount a fileshare you get the
> > message "Device or resource busy". Typically I traverse through
> > the output of lsof | grep mountpoint and stop processes or kill
> > until I can safely umount.
> > 
> > But the nfs-kernel-server does not register its open files, so
> > seen from userspace is it extremely hard to find out that is actually
> > is the nfs-server that prevents you from being able to umount
> > the filesystems.
> > 
> > Would it be possible to register the open files the same place
> > so administrators can see them?
> > 
> > ... basically just a feature-request from one who just spend an hour on 
> > that.
> > 
> 
> Me to!
> 
> Also note that even if there are no open files in clients
> and no client mounts on the server, but there where in the
> passed. The used to be used super-block is referenced. Only
> restart of the nfs service will release it.
> 
> But yes if it could register as a special file for lsof to
> see it would help a lot.

So what does lsof do, scan /proc/?  Does it make sense to have proc
entries for kernel threads?  Is there any other subsystem that does this
kind of thing?

--b.
