Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:40162 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758051Ab2B2Ocj (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 29 Feb 2012 09:32:39 -0500
Date: Wed, 29 Feb 2012 09:32:36 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: steve <steve@steve-ss.com>
Cc: Jeff Layton <jlayton@poochiereds.net>, linux-nfs@vger.kernel.org
Subject: Re: POSIX acls over nfs4
Message-ID: <20120229143236.GB3007@fieldses.org>
References: <4F465C3A.9080802@steve-ss.com>
 <20120223154215.GA26706@fieldses.org>
 <4F466467.3030506@steve-ss.com>
 <4F489999.30909@steve-ss.com>
 <20120228200524.GE2723@fieldses.org>
 <4F4D61B6.5090304@steve-ss.com>
 <20120229124401.GA9160@fieldses.org>
 <4F4E306C.6030400@steve-ss.com>
 <20120229140903.GA3007@fieldses.org>
 <4F4E3599.2050209@steve-ss.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4F4E3599.2050209@steve-ss.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Feb 29, 2012 at 03:26:33PM +0100, steve wrote:
> On 02/29/2012 03:09 PM, J. Bruce Fields wrote:
> >On Wed, Feb 29, 2012 at 03:04:28PM +0100, steve wrote:
> >>On 29/02/12 13:44, J. Bruce Fields wrote:
> >>>On Wed, Feb 29, 2012 at 12:22:30AM +0100, steve wrote:
> >>>>We are authenticating against Samba4, so our domain user accounts
> >>>>are under Kerberos.
> >>>Kerberos works fine with v3.
> >>>
> >>>--b.
> >>Hi
> >>Unfortunately, it doesn't seem to. We just tried it, and anyone
> >>(with or without a ticket) gets access:-(
> >Could you give any more detail about your test?
> >
> >--b.
> steve is a /etc/passwd user
> 
> steve@hh3:~$ sudo su
> [sudo] password for steve:
> root@hh3:/home/steve# mount -t nfs4 hh3:/home /mnt -o sec=krb5
> root@hh3:/home/steve# exit
> exit
> steve@hh3:~$ cd /mnt
> bash: cd: /mnt: Permission denied
> steve@hh3:~$ sudo su
> root@hh3:/home/steve# umount /mnt
> root@hh3:/home/steve# mount -t nfs hh3:/home /mnt -o sec=krb5
> root@hh3:/home/steve# exit
> exit
> steve@hh3:~$ cd /mnt
> steve@hh3:/mnt$

Why is that a problem?  You haven't actually accessed anything on the
filesystem.

--b.
