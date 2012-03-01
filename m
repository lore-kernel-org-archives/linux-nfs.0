Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:54409 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757339Ab2CAU4l (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 1 Mar 2012 15:56:41 -0500
Date: Thu, 1 Mar 2012 15:56:39 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: steve <steve@steve-ss.com>
Cc: Jeff Layton <jlayton@poochiereds.net>, linux-nfs@vger.kernel.org
Subject: Re: POSIX acls over nfs4
Message-ID: <20120301205639.GC17433@fieldses.org>
References: <4F466467.3030506@steve-ss.com>
 <4F489999.30909@steve-ss.com>
 <20120228200524.GE2723@fieldses.org>
 <4F4D61B6.5090304@steve-ss.com>
 <20120229124401.GA9160@fieldses.org>
 <4F4E306C.6030400@steve-ss.com>
 <20120229140903.GA3007@fieldses.org>
 <4F4E3599.2050209@steve-ss.com>
 <20120229143236.GB3007@fieldses.org>
 <4F4E38E7.6060308@steve-ss.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4F4E38E7.6060308@steve-ss.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Feb 29, 2012 at 03:40:39PM +0100, steve wrote:
> On 02/29/2012 03:32 PM, J. Bruce Fields wrote:
> >On Wed, Feb 29, 2012 at 03:26:33PM +0100, steve wrote:
> >>On 02/29/2012 03:09 PM, J. Bruce Fields wrote:
> >>>On Wed, Feb 29, 2012 at 03:04:28PM +0100, steve wrote:
> >>>>On 29/02/12 13:44, J. Bruce Fields wrote:
> >>>>>On Wed, Feb 29, 2012 at 12:22:30AM +0100, steve wrote:
> >>>>>>We are authenticating against Samba4, so our domain user accounts
> >>>>>>are under Kerberos.
> >>>>>Kerberos works fine with v3.
> >>>>>
> >>>>>--b.
> >>>>Hi
> >>>>Unfortunately, it doesn't seem to. We just tried it, and anyone
> >>>>(with or without a ticket) gets access:-(
> >>>Could you give any more detail about your test?
> >>>
> >>>--b.
> >>steve is a /etc/passwd user
> >>
> >>steve@hh3:~$ sudo su
> >>[sudo] password for steve:
> >>root@hh3:/home/steve# mount -t nfs4 hh3:/home /mnt -o sec=krb5
> >>root@hh3:/home/steve# exit
> >>exit
> >>steve@hh3:~$ cd /mnt
> >>bash: cd: /mnt: Permission denied
> >>steve@hh3:~$ sudo su
> >>root@hh3:/home/steve# umount /mnt
> >>root@hh3:/home/steve# mount -t nfs hh3:/home /mnt -o sec=krb5

Careful: a recent client will negotiate v4 if you leave this
unspecified.  You want -onfsversion=3,sec=krb5.

> >>root@hh3:/home/steve# exit
> >>exit
> >>steve@hh3:~$ cd /mnt
> >>steve@hh3:/mnt$
> >Why is that a problem?  You haven't actually accessed anything on the
> >filesystem.
> >
> >--b.
> Steve can access the mounted folder. I can live with that but the
> acl still isn't working:
> 
> lynn2 has authinticated by Kerberos
> 
> root@hh3:~# setfacl -d -m g::rw /home/CACTUS/dropbox
> root@hh3:~# mount -t nfs hh3:/home /mnt -o sec=krb5
> lynn2@hh3:/mnt/CACTUS$ ls -la
> total 28
> drwxr-xr-x  6 root   root         4096 2012-02-27 14:24 .
> drwxr-xr-x  4 root   root         4096 2012-02-18 18:52 ..
> drwxrws---  3 root   debusers     4096 2012-02-29 15:31 dropbox
> drwxr-xr-x 20 lynn2  debusers     4096 2012-02-26 16:43 lynn2
> drwxrwxrwx  5 root   root         4096 2012-02-29 14:19 profiles
> drwxr-xr-x  4 steve2 Domain Users 4096 2012-02-29 14:36 steve2
> 
> lynn2 then crates a file in the mount called l3:
> 
> lynn2@hh3:/mnt/CACTUS$ ls -la /home/CACTUS/dropbox/
> total 20
> drwxrws---+ 3 root  debusers 4096 2012-02-29 15:31 .
> drwxr-xr-x  6 root  root     4096 2012-02-27 14:24 ..
> -rw-r-----  1 lynn2 debusers    0 2012-02-29 15:31 a
> drwxrwS---+ 2 root  debusers 4096 2012-02-29 14:28 adminfolder
> -rw-rw----  1 lynn2 debusers    0 2012-02-25 23:23 l2
> -rw-r-----  1 lynn2 debusers    0 2012-02-29 15:24 l3
> -rw-rw----  1 lynn2 debusers    0 2012-02-26 16:20 lynn2-ubuntu.txt
> -rw-rw----  1 lynn2 debusers   11 2012-02-26 00:46 lynnnautilus.txt
> 
> ??

I would have expected the default acl on the parent to override any
umask on v3.

So if it's actually v3, then that looks like a bug to me.

--b.
