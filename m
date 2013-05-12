Return-Path: linux-nfs-owner@vger.kernel.org
Received: from tundra.namei.org ([65.99.196.166]:43207 "EHLO tundra.namei.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753967Ab3ELLdJ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 12 May 2013 07:33:09 -0400
Date: Sun, 12 May 2013 21:37:03 +1000 (EST)
From: James Morris <jmorris@namei.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
cc: James Morris <james.l.morris@oracle.com>,
        Serge Hallyn <serge.hallyn@canonical.com>,
        linux-security-module@vger.kernel.org, linux-nfs@vger.kernel.org,
        "David P. Quigley" <dpquigl@tycho.nsa.gov>,
        Steve Dickson <SteveD@redhat.com>
Subject: Re: [PATCH] security: clarify cap_inode_getsecctx description
In-Reply-To: <20130509154104.GD9316@fieldses.org>
Message-ID: <alpine.LRH.2.02.1305122136520.23175@tundra.namei.org>
References: <20130509014329.GH23747@fieldses.org> <20130509054926.GA31134@tp> <20130509140820.GB9316@fieldses.org> <20130509151333.GA2211@tp> <20130509154104.GD9316@fieldses.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 9 May 2013, J. Bruce Fields wrote:

> From: "J. Bruce Fields" <bfields@redhat.com>
> 
> Make it clear that cap_inode_getsecctx shouldn't return success without
> filling in the context data.
> 
> Acked-by: Serge E. Hallyn <serge.hallyn@ubuntu.com>
> Signed-off-by: J. Bruce Fields <bfields@redhat.com>


Applied to
git://git.kernel.org/pub/scm/linux/kernel/git/jmorris/linux-security.git next



-- 
James Morris
<jmorris@namei.org>
