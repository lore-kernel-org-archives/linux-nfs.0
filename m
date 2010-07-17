Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fmailhost03.isp.att.net ([204.127.217.103]:37420 "EHLO
	fmailhost03.isp.att.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752380Ab0GQFvf (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 17 Jul 2010 01:51:35 -0400
Date: Fri, 16 Jul 2010 22:51:30 -0700
From: Mark Harris <mhlk@osj.us>
To: David Howells <dhowells@redhat.com>
Cc: Arnd Bergmann <arnd@arndb.de>, Steve French <smfrench@gmail.com>,
        viro@zeniv.linux.org.uk, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org, linux-cifs@vger.kernel.org,
        linux-kernel@vger.kernel.org, samba-technical@lists.samba.org,
        linux-ext4@vger.kernel.org
Subject: Re: [PATCH 02/18] xstat: Add a pair of system calls to make
	extended file stats available [ver #6]
Message-ID: <20100717055130.GA2053@zoia.osj.us>
References: <201007161302.35775.arnd@arndb.de> <20100716062251.GA9318@zoia.osj.us> <30646.1279230807@redhat.com> <8527.1279275842@redhat.com> <10677.1279283886@redhat.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <10677.1279283886@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

David Howells wrote:
> With a 2:2 split between exponent
> (tv_gran_units) and mantissa (tv_granularity), you can do:
> 
> 	UNIT		SECONDS/UNIT	EXPONENT	MANTISSA
> 	nanoseconds	0.000000001	-9		1
> 	microseconds	0.000001	-6		1
> 	millseconds	0.001		-3		1
> 	seconds		1		0		1
> 	minutes		60		1		6
> 	hours		3600		2		36
> 	days		86400		2		864
> 	weeks		604800		2		6048

At least for the in-tree filesystems, I do not see any that keep
timestamps with a granularity larger than 2s.  For that, a simple
32-bit tv_granularity in nanoseconds (not limited to 1e9) would
suffice, and there is no need for the complexity of dealing with
a separate exponent.

If there is a need to handle larger granularity, its msb could
potentially be used to indicate that the number is in seconds
instead of nanoseconds.  This is convenient because the timestamp
is already broken down into sec and nsec fields.  So this bit would
then indicate that the granularity applies to the tv_sec field, and
that tv_nsec is not in use.  But even this is overkill if no one
uses a granularity larger than 2s.

 - Mark
