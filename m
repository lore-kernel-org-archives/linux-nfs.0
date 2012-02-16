Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:15231 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751316Ab2BPRAW (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 16 Feb 2012 12:00:22 -0500
Date: Thu, 16 Feb 2012 12:00:20 -0500
From: "J. Bruce Fields" <bfields@redhat.com>
To: Benny Halevy <bhalevy@tonian.com>
Cc: NFS list <linux-nfs@vger.kernel.org>
Subject: Re: wireshark decoding of nfsv4.1
Message-ID: <20120216170019.GC6749@pad.fieldses.org>
References: <4F3D333A.1000108@tonian.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4F3D333A.1000108@tonian.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Feb 16, 2012 at 06:47:54PM +0200, Benny Halevy wrote:
> I stumbled upon a bug in wireshark decoding of NFSv4.1 open res
> when delegation_type==OPEN_DELEGATE_NONE_EXT where od_whynone
> seems to be ignored.
> 
> Who owns that code nowadays?

I don't know, I see a lot of 4.1 problems, and I don't know if it's the
wireshark version in my distro or if the problems are in upstream.  I
haven't had time to fool with it in a few years.

> There seems to be a bug in pynfs in this area as well
> which I'm trying to debug.

That doesn't sound familiar to me.

--b.
