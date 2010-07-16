Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:21940 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S964919Ab0GPKYx (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 16 Jul 2010 06:24:53 -0400
From: David Howells <dhowells@redhat.com>
In-Reply-To: <20100716062251.GA9318@zoia.osj.us>
References: <20100716062251.GA9318@zoia.osj.us> <201007152235.22373.arnd@arndb.de> <20100715021709.5544.64506.stgit@warthog.procyon.org.uk> <20100715021712.5544.44845.stgit@warthog.procyon.org.uk> <30646.1279230807@redhat.com>
To: Mark Harris <mhlk@osj.us>, Steve French <smfrench@gmail.com>
Cc: dhowells@redhat.com, viro@zeniv.linux.org.uk,
        linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-cifs@vger.kernel.org, linux-kernel@vger.kernel.org,
        samba-technical@lists.samba.org, linux-ext4@vger.kernel.org
Subject: Re: [PATCH 02/18] xstat: Add a pair of system calls to make extended file stats available [ver #6]
Date: Fri, 16 Jul 2010 11:24:02 +0100
Message-ID: <8527.1279275842@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Mark Harris <mhlk@osj.us> wrote:

> > struct xstat_time {
> > 	unsigned long long	tv_sec, tv_nsec;
> > };
> 
> unsigned?  Existing filesystems support on-disk timestamps
> representing times prior to the epoch.

I suppose it doesn't hurt to make is signed.  It's large enough...

Looking at it again, having a 64-bit field for tv_nsec is overkill.  It can't
(or shouldn't) exceed 999,999,999 - well within the capability of a 32-bit
unsigned integer.

So how about using up the dead space for what Steve French wanted:

	| One hole that this reminded me about is how to return the superblock
	| time granularity (for NFSv4 this is attribute 51 "time_delta" which
	| is called on a superblock not on a file).  We run into time rounding
	| issues with Samba too.

By doing something like:

	struct xstat_time {
		signed long long	tv_sec;
		unsigned int		tv_nsec;
		unsigned short		tv_granularity;
		unsigned short		tv_gran_units;
	};

Where tv_granularity is the minimum granularity for tv_sec and tv_nsec given
as a quantity of tv_gran_units.  tv_gran_units could then be a constant, such
as:

	XSTAT_NANOSECONDS_GRANULARITY
	XSTAT_MICROSECONDS_GRANULARITY
	XSTAT_MILLISECONDS_GRANULARITY
	XSTAT_SECONDS_GRANULARITY
	XSTAT_MINUTES_GRANULARITY
	XSTAT_HOURS_GRANULARITY
	XSTAT_DAYS_GRANULARITY

So, for example, FAT times are a 2s granularity, so FAT would set
tv_granularity to 2 and tv_gran_units to XSTAT_SECONDS_GRANULARITY.

We could even support picosecond granularity if we made tv_nsec a 5-byte
field (tv_psec):

	struct xstat_time {
		signed long long	tv_sec;
		unsigned long long	tv_gran_units : 8;
		unsigned long long	tv_granularity : 16;
		unsigned long long	tv_psec	: 48;
	};

but that's probably excessive.  Does any filesystem we currently support need
that?

David
