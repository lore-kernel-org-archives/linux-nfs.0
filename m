Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fmailhost04.isp.att.net ([207.115.11.54]:56801 "EHLO
	fmailhost04.isp.att.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S935638Ab0GPG2b (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 16 Jul 2010 02:28:31 -0400
Date: Thu, 15 Jul 2010 23:22:51 -0700
From: Mark Harris <mhlk@osj.us>
To: David Howells <dhowells@redhat.com>
Cc: viro@zeniv.linux.org.uk, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org, linux-cifs@vger.kernel.org,
        linux-kernel@vger.kernel.org, samba-technical@lists.samba.org,
        linux-ext4@vger.kernel.org
Subject: Re: [PATCH 02/18] xstat: Add a pair of system calls to make
	extended file stats available [ver #6]
Message-ID: <20100716062251.GA9318@zoia.osj.us>
References: <201007152235.22373.arnd@arndb.de> <20100715021709.5544.64506.stgit@warthog.procyon.org.uk> <20100715021712.5544.44845.stgit@warthog.procyon.org.uk> <30646.1279230807@redhat.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20100715021712.5544.44845.stgit@warthog.procyon.org.uk>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

> struct xstat_time {
> 	unsigned long long	tv_sec, tv_nsec;
> };

unsigned?  Existing filesystems support on-disk timestamps
representing times prior to the epoch.
