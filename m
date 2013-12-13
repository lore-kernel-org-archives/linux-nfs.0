Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mout.perfora.net ([74.208.4.194]:57668 "EHLO mout.perfora.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751602Ab3LMMaw (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 13 Dec 2013 07:30:52 -0500
Date: Fri, 13 Dec 2013 07:30:36 -0500
From: Jim Rees <rees@umich.edu>
To: Benny Halevy <bhalevy@primarydata.com>
Cc: "J. Bruce Fields" <bfields@fieldses.org>, bfields@redhat.com,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH] nfsd4: fix printk format string in nfsd4_open
Message-ID: <20131213123036.GA3840@umich.edu>
References: <1386608743-23718-1-git-send-email-bhalevy@primarydata.com>
 <20131212161931.GF11521@fieldses.org>
 <52AAD99E.40706@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <52AAD99E.40706@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Benny Halevy wrote:

  On 12/12/2013 06:19 PM, J. Bruce Fields wrote:
  > On Mon, Dec 09, 2013 at 07:05:43PM +0200, Benny Halevy wrote:
  >> Signed-off-by: Benny Halevy <bhalevy@primarydata.com>
  > 
  > Are you sure?  Reminding myself from the sprintf man page.... %*s
  > provides padding, %.*s limits the number of characters taken from the
  > string.  We need that limit since there's no guarantee of null
  > termination here.
  
  Well, the .* format doesn't seem to be supported in the kernel library as
  far as I could tell. At least it doesn't work for me. We may need to copy
  the string and null terminate it if it's indeed the case.

There's nothing about strings in Documentation/printk-formats.txt, but if
you look at lib/vsprintf.c, it's clearly trying to support precision. The
precision is parsed in format_decode(), and used to limit the string length
in string().

String precision is used other places in the kernel, too:
% fgrep -l '%.*s' {kernel,fs}/*.c
kernel/hung_task.c
kernel/lockdep.c
fs/dcache.c
fs/filesystems.c

So I would be surprised if it doesn't work.
