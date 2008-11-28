From: Frank van Maarseveen <frankvm@frankvm.com>
Subject: Re: [NLM] 2.6.27 broken
Date: Fri, 28 Nov 2008 12:24:47 +0100
Message-ID: <20081128112447.GA25340@janus>
References: <20081115132831.GA11329@janus> <20081120222731.GA591@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux NFS mailing list <linux-nfs@vger.kernel.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from frankvm.xs4all.nl ([80.126.170.174]:44838 "EHLO
	janus.localdomain" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752161AbYK1LYt (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 28 Nov 2008 06:24:49 -0500
In-Reply-To: <20081120222731.GA591@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Nov 20, 2008 at 05:27:31PM -0500, J. Bruce Fields wrote:
> On Sat, Nov 15, 2008 at 02:28:31PM +0100, Frank van Maarseveen wrote:
> > Try running multiple instances of attached program on 1 NFS client
> > against a 2.6.27(.5) NFSv3 server:
> > 
> > 	gcc -Wall -Wstrict-prototypes -o lck lck.c
> > 	for i in `seq 30`
> > 	do
> > 		lck &
> > 	done
> 
> Or reproduceable using the "flock" utility with:
> 
> 	for i in `seq 30`
> 	do
> 		flock /mnt/foo sleep 10
> 	done
> 
> Hm.  What's the last known good server version?

2.6.24.4

-- 
Frank
