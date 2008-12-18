From: "Gabor Z. Papp" <gzp-2g/1Y3AqmNE@public.gmane.org>
Subject: Re: nfs-utils mountd getfh failed: No such file or directory
Date: Thu, 18 Dec 2008 15:36:54 +0100
Message-ID: <x67i5x4kjd@gzp>
References: <x6k5a0166x@gzp> <49498029.1080307@RedHat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: Steve Dickson <SteveD@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from odpn1.odpn.net ([212.40.96.53]:36020 "EHLO odpn1.odpn.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751237AbYLROhB (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 18 Dec 2008 09:37:01 -0500
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

* Steve Dickson <SteveD@redhat.com>:

| > 2008 Dec 16 15:48:44 <daemon.warning> gzp mountd[1748]: getfh failed: No such file or directory
| > 
| > Found the revelant code in the mountd source, but I don't know what is this error.

| This might be due to the fact that the nfsd module is not loaded when
| mountd is started since it appears mountd is not using the new caching.

| Make sure a 'modprobe nfsd' happens before mountd is started...

Thanks, I have found the problem. The exported filesystem wasn't
mounted and the mountpoint is on 2.6 initrd. Read in the manpage
that can't be exported via nfs.
