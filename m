From: Greg Banks <gnb@sgi.com>
Subject: Re: NFS4 ACL <-> Posix ACL
Date: Tue, 24 Mar 2009 14:09:34 +1100
Message-ID: <49C84EEE.9020405@sgi.com>
References: <7f62dcb30903181042n42bae0bbk99f5c91fce6e9e82@mail.gmail.com>	 <20090319193514.GE3072@fieldses.org> <7f62dcb30903230646u183c79e0i4366edebe32654d5@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
	linux-nfs@vger.kernel.org, Andreas Gruenbacher <agruen@suse.de>
To: Alex Bremer <albremer@googlemail.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from relay2.sgi.com ([192.48.179.30]:52370 "EHLO relay.sgi.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752281AbZCXCuZ (ORCPT
	<rfc822;@relay.corp.sgi.com:linux-nfs@vger.kernel.org>);
	Mon, 23 Mar 2009 22:50:25 -0400
In-Reply-To: <7f62dcb30903230646u183c79e0i4366edebe32654d5-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Alex Bremer wrote:
> [...]
>  Would the inheritance work if we
> used a fully NFS4-ACL compatible filesystem? Is there any for Linux?
>   

There are patches to make ext3 and XFS natively NFSv4 ACL aware.  The
XFS patches have been shipping in an SGI product for some months now.

http://oss.sgi.com/projects/nfs/nfs4acl/

I believe GPFS2 from IBM has native NFSv4 ACL support too.

-- 
Greg Banks, P.Engineer, SGI Australian Software Group.
the brightly coloured sporks of revolution.
I don't speak for SGI.

