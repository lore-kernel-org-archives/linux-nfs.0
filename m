From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: use of non-privileged ports for MNT and NLM
Date: Tue, 19 Aug 2008 17:22:02 -0400
Message-ID: <20080819212202.GD8331@fieldses.org>
References: <0CD0CE08-CB11-419A-9AAC-DEB1AC2B26B3@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>,
	Steve Dickson <SteveD@redhat.com>,
	Linux NFS Mailing List <linux-nfs@vger.kernel.org>
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:46341 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758416AbYHSVWN (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 19 Aug 2008 17:22:13 -0400
In-Reply-To: <0CD0CE08-CB11-419A-9AAC-DEB1AC2B26B3@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Aug 19, 2008 at 05:14:54PM -0400, Chuck Lever wrote:
> Working on "resvport" mount option.  Question occurred to me:
>
> If I specify "noresvport" on a mount, can the client also use a non- 
> privileged port for the initial MNT request, and can it use it for the  
> NLM connection as well?
>
> Question applies not just to Linux servers, but servers in general.   
> Brief searching on teh internets does not reveal a quick answer.  I  
> think rpc.mountd will allow a non-privileged port for "insecure"  
> exports.

>From nfs-utils/utils/mountd/auth.c:auth_authenticate_internal():

	if (!(exp->m_export.e_flags & NFSEXP_INSECURE_PORT) &&
                    (ntohs(caller->sin_port) <  IPPORT_RESERVED/2 ||
                     ntohs(caller->sin_port) >= IPPORT_RESERVED)) {
                *error = illegal_port;
                return NULL;
        }

So assuming that function does what it name suggests, I think you're
right.

> I think the answer is "yes, non-privileged ports can be used for MNT and 
> NLM if the server explicitly allows it" but I thought I would open this 
> up to the list.

That's what I would have guessed.

And if the goal is to keep the number of reserved ports from being a
limit, it would be disappointing to eliminate only the ports used for
nfs itself.

--b.
