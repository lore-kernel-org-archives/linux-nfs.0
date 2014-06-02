Return-Path: linux-nfs-owner@vger.kernel.org
Received: from relay1.mentorg.com ([192.94.38.131]:37627 "EHLO
	relay1.mentorg.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754438AbaFBNwf (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 2 Jun 2014 09:52:35 -0400
Date: Mon, 2 Jun 2014 13:52:19 +0000
From: "Joseph S. Myers" <joseph@codesourcery.com>
To: Arnd Bergmann <arnd@arndb.de>
CC: <linux-kernel@vger.kernel.org>, <linux-arch@vger.kernel.org>,
        <john.stultz@linaro.org>, <hch@infradead.org>, <tglx@linutronix.de>,
        <geert@linux-m68k.org>, <lftan@altera.com>, <hpa@zytor.com>,
        <linux-fsdevel@vger.kernel.org>, <ceph-devel@vger.kernel.org>,
        <cluster-devel@redhat.com>, <coda@cs.cmu.edu>,
        <codalist@TELEMANN.coda.cs.cmu.edu>,
        <fuse-devel@lists.sourceforge.net>, <linux-afs@lists.infradead.org>,
        <linux-btrfs@vger.kernel.org>, <linux-cifs@vger.kernel.org>,
        <linux-ext4@vger.kernel.org>, <linux-f2fs-devel@lists.sourceforge.net>,
        <linux-mtd@lists.infradead.org>, <linux-nfs@vger.kernel.org>,
        <linux-ntfs-dev@lists.sourceforge.net>, <linux-scsi@vger.kernel.org>,
        <logfs@logfs.org>, <ocfs2-devel@oss.oracle.com>,
        <reiserfs-devel@vger.kernel.org>, <samba-technical@lists.samba.org>,
        <xfs@oss.sgi.com>
Subject: Re: [RFC 00/32] making inode time stamps y2038 ready
In-Reply-To: <1401480116-1973111-1-git-send-email-arnd@arndb.de>
Message-ID: <Pine.LNX.4.64.1406021350030.19591@digraph.polyomino.org.uk>
References: <1401480116-1973111-1-git-send-email-arnd@arndb.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 30 May 2014, Arnd Bergmann wrote:

> a) is this the right approach in general? The previous discussion
>    pointed this way, but there may be other opinions.

The syscall changes seem like the sort of thing I'd expect, although 
patches adding new syscalls or otherwise affecting the kernel/userspace 
interface (as opposed to those relating to an individual filesystem) 
should go to linux-api as well as other relevant lists.

-- 
Joseph S. Myers
joseph@codesourcery.com
