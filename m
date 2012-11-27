Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:53468 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755851Ab2K0QxE (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 27 Nov 2012 11:53:04 -0500
Received: from int-mx01.intmail.prod.int.phx2.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id qARGr4nT004880
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Tue, 27 Nov 2012 11:53:04 -0500
Message-ID: <50B4EFEF.1060504@RedHat.com>
Date: Tue, 27 Nov 2012 11:53:03 -0500
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: Steve Dickson <steved@redhat.com>
CC: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 1/3] mount.nfs: Continue to trying address when the server
 return ENOENT
References: <1353961029-6317-1-git-send-email-steved@redhat.com>
In-Reply-To: <1353961029-6317-1-git-send-email-steved@redhat.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hello,

On 26/11/12 15:17, Steve Dickson wrote:
> With recent changes to the /etc/hosts file, the 'localhost'
> is now multiply defined as both an IPv4 address (127.0.01)
> and an IPv6 address (::1). This change causes first address
> returned by getaddrinfo('localhost') to be the IPv6 address
> instead of the IPv4 address.
> 
> The change in the default 'localhost' address type causes
> existing exports using '127.0.0.1' to fail, because the
> '::1' address is tried first and fails. The problem
> being not all the addresses that are returned by
> getaddrinfo('localhost') are tried.
> 
> So this patch allows that address list to continue to be
> process when the 'ENOENT' error is returned by the server.
> 
> Signed-off-by: Steve Dickson <steved@redhat.com>
After further review and some chat on IRC (thanks Frank!) using
EACCES, instead of ENOENT, to cause the next address to be tried 
is much more straightforward and simpler... V2 is on the way...

steved.
