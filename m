From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: Re: why there is a complex sync between /var/lib/nfs/etab in
	user-modeand  export_table in kernel mode?
Date: Mon, 22 Dec 2008 12:14:53 -0500
Message-ID: <20081222171453.GM4191@fieldses.org>
References: <200812181433568806030@gmail.com> <200812192250226871692@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Steve Dickson <SteveD@redhat.com>,
	linux-nfs <linux-nfs@vger.kernel.org>
To: lioupayphone <lioupayphone@gmail.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from pie.citi.umich.edu ([141.211.133.115]:34041 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751978AbYLVRf5 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 22 Dec 2008 12:35:57 -0500
In-Reply-To: <200812192250226871692@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Dec 19, 2008 at 10:50:27PM +0800, lioupayphone wrote:
> >I hope this helps...
> :-) thank you very much. i think your comments are very clear and very
> helpful for me.  but i still think rpc.mountd is somewhat complex. we
> all know that a daemon in user-mode is likely to be killed. rpc.mountd
> is no exception. once rpc.mountd was killed, there are no chance for
> the export_table to be updated via upcall.
> 
> It cannot be denied that putting the etab into kernel mode is wastful
> for memory. but i still think it is an easy  and stable method.

Even with the export table in memory, rpc.mountd will still be needed
for ip-address lookup (e.g. if a filesystem is exported to *.umich.edu,
and the kernel gets an rpc from 141.211.133.1, then it needs to do an
upcall to determine whether the given ip address matches that wildcard).

However it's true that there might be advantages to having the export
table in-kernel.

--b.
