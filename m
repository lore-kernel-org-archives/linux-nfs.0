Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp02.online.nl ([194.134.41.32]:58200 "EHLO smtp02.online.nl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751102Ab1G1EWY (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 28 Jul 2011 00:22:24 -0400
Subject: Re: NFSv4 / POSIX ACL mapping bug?
From: Vladimir Elisseev <vovan@vovan.nl>
To: Robert Marcano <robert@marcanoonline.com>
Cc: linux-nfs@vger.kernel.org
In-Reply-To: <4E303A09.10906@marcanoonline.com>
References: <4E2ED2A0.4030401@marcanoonline.com>
	 <20110727154736.GB974@fieldses.org>  <4E303A09.10906@marcanoonline.com>
Content-Type: text/plain; charset="UTF-8"
Date: Thu, 28 Jul 2011 06:13:27 +0200
Message-ID: <1311826407.1520.5.camel@vovan.net.home>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Just because of this problem we're (still) using NFS3 with kerberos...

On Wed, 2011-07-27 at 11:47 -0430, Robert Marcano wrote:
> On 07/27/2011 11:17 AM, J. Bruce Fields wrote:
> > On Tue, Jul 26, 2011 at 10:13:44AM -0430, Robert Marcano wrote:
> ...
> >> Is this normal or a bug?, My interpretation is that even that the
> >> mapping of the ACLs is not 100% perfect this simple example should
> >> not be a problem. Is it impossible using NFS to create a shared
> >> directory for a group of users?
> >
> > Without looking at your example carefully, it sounds like the same
> > problem as discussed here:
> >
> > 	http://marc.info/?t=123739823200003&r=1&w=2
> 
> Thanks, exactly the same problem, current user umask getting in the way 
> of ACL inheritance, looks like the answers is that this is currently not 
> possible because the umask is applied client side and the NFSv4 protocol 
> does not help to send that info to the server. No workaround available 
> (mount option or something like that)
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

