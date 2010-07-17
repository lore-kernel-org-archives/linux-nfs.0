From: David Howells <dhowells@redhat.com>
Subject: Re: [PATCH 02/18] xstat: Add a pair of system calls to make extended file stats available [ver #6]
Date: Sat, 17 Jul 2010 10:49:00 +0100
Message-ID: <19785.1279360140@redhat.com>
References: <20100717055130.GA2053@zoia.osj.us> <201007161302.35775.arnd@arndb.de> <20100716062251.GA9318@zoia.osj.us> <30646.1279230807@redhat.com> <8527.1279275842@redhat.com> <10677.1279283886@redhat.com>
Cc: dhowells@redhat.com, Arnd Bergmann <arnd@arndb.de>,
	Steve French <smfrench@gmail.com>, viro@zeniv.linux.org.uk,
	linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
	linux-cifs@vger.kernel.org, linux-kernel@vger.kernel.org,
	samba-technical@lists.samba.org, linux-ext4@vger.kernel.org
To: Mark Harris <mhlk-gcwzot8L0og@public.gmane.org>
Return-path: <linux-cifs-owner@vger.kernel.org>
In-Reply-To: <20100717055130.GA2053-EJgEOVOPJGBzbRFIqnYvSA@public.gmane.org>
Sender: linux-cifs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Mark Harris <mhlk-gcwzot8L0og@public.gmane.org> wrote:

> At least for the in-tree filesystems, I do not see any that keep
> timestamps with a granularity larger than 2s.  For that, a simple
> 32-bit tv_granularity in nanoseconds (not limited to 1e9) would
> suffice, and there is no need for the complexity of dealing with
> a separate exponent.

That's a good point.

David
