From: "Steinar H. Gunderson" <sgunderson-jG/AHqQBv7lBDgjK7y7TUQ@public.gmane.org>
Subject: Re: NFS mount over IPv6 success
Date: Wed, 12 Nov 2008 14:35:53 +0100
Message-ID: <20081112133553.GA32294@uio.no>
References: <20081109164132.GA19615@uio.no> <DBEFEF5C-00E2-4C4D-A9D4-81D24632DE34@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from cassarossa.samfundet.no ([129.241.93.19]:39621 "EHLO
	cassarossa.samfundet.no" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752678AbYKLNf7 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 12 Nov 2008 08:35:59 -0500
In-Reply-To: <DBEFEF5C-00E2-4C4D-A9D4-81D24632DE34@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Nov 12, 2008 at 01:00:27AM -0500, Chuck Lever wrote:
> Keep an eye out for IPv6-related patches for nfs-utils.  The key is to  
> ensure IPv4 continues to work, especially on Debian which tracks  
> upstream nfs-utils closely.

We don't plan to incorporate IPv6-specific patches before upstream does (and
lenny, our upcoming release, is not going to get libtirpc or rpcbind). When
upstream nfs-utils is ready, you can expect us to configure with
--enable-ipv6 pretty quickly, though :-)

I still haven't had any success with nfsd on the server side in Linux; it's a
bit unclear to me what nfs-utils to use in particular.

/* Steinar */
-- 
Homepage: http://www.sesse.net/
