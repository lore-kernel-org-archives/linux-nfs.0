From: Jeff Layton <jlayton@redhat.com>
Subject: Re: IPv6 support
Date: Mon, 2 Nov 2009 15:43:12 -0500
Message-ID: <20091102154312.72db0ab1@tlielax.poochiereds.net>
References: <4AEE9645.6010503@suse.de>
	<B3F6BEAE-A564-475F-93D5-7D6E0FC79147@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: Suresh Jayaraman <sjayaraman@suse.de>,
	Linux NFS Mailing list <linux-nfs@vger.kernel.org>,
	Chris Mason <chris.mason@oracle.com>
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:41013 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756812AbZKBUnO (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 2 Nov 2009 15:43:14 -0500
In-Reply-To: <B3F6BEAE-A564-475F-93D5-7D6E0FC79147@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 2 Nov 2009 11:40:47 -0500
Chuck Lever <chuck.lever@oracle.com> wrote:

> 
> There is also the gssd twins.  Jeff has fixed up at least one of  
> them.  I think we've reviewed the kerberos libraries and determined  
> that they are IPv6-aware, but that could be incorrect.  TCP wrappers  
> are definitely not IPv6-aware.
> 

rpc.gssd should be ready to go for IPv6. rpc.svcgssd didn't need any
changes since it only talks to the kernel.

-- 
Jeff Layton <jlayton@redhat.com>
