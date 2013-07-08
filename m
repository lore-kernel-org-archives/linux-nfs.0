Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:55617 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752159Ab3GHSkT (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 8 Jul 2013 14:40:19 -0400
Date: Mon, 8 Jul 2013 14:39:57 -0400
From: Jeff Layton <jlayton@redhat.com>
To: Johan GUILBAUD <guilbaud.johan@gmail.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: Problem with sharing mounted iso
Message-ID: <20130708143957.2ebc75e3@tlielax.poochiereds.net>
In-Reply-To: <CAF38w7Xf87k=GfM38XcO+ag+Na=f=Mg1KDn0jv2Y8Yp6Q_5a=g@mail.gmail.com>
References: <CAF38w7Xx0_TqZem6cen+EJKpUrziGT_dAVcjG7oFFwM+ANm5mA@mail.gmail.com>
	<CAF38w7Xf87k=GfM38XcO+ag+Na=f=Mg1KDn0jv2Y8Yp6Q_5a=g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 8 Jul 2013 14:47:00 +0200
Johan GUILBAUD <guilbaud.johan@gmail.com> wrote:

> Hello !
> 
> I have a problem to access a mounted ISO through NFS protocol
> 
> i have a server (RHEL6) on which are mounted ISOs
> i have a lot of client accessing files into ISO via the NFS share
> 
> My problem is clients (RHEL5 & 6, Solaris 8 & 10) don't see content of
> ISO folder
> 
> In example :
> 
> on NFS server i have a folder /pub/ where the ISO are mounted (ie :
> with the iso mybeautifuliso.iso on the mount point
> "/pub/mybeautifuliso/") there are also, for test, text files in /pub/
> NFS shares content of /pub
> 
> 
> Client see tests text files, and folder "mybeautifuliso" but this one
> is empty...
> 
> 
> thanks for help
> 

Exports don't cross mountpoints by default, so if you exported "/pub"
no filesystem mounted under it will be automatically exported. The best
solution is to explicitly export those filesystems as well -- i.e. add
an export of "/pub/mybeautifuliso". Then, when clients wander into
those directories they should see the contents.

-- 
Jeff Layton <jlayton@redhat.com>
