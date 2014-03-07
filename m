Return-Path: linux-nfs-owner@vger.kernel.org
Received: from tundra.namei.org ([65.99.196.166]:58961 "EHLO tundra.namei.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752262AbaCGAlZ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 6 Mar 2014 19:41:25 -0500
Date: Fri, 7 Mar 2014 11:42:18 +1100 (EST)
From: James Morris <jmorris@namei.org>
To: Jeff Layton <jlayton@redhat.com>
cc: James Morris <james.l.morris@oracle.com>,
        Serge Hallyn <serge.hallyn@canonical.com>,
        linux-security-module@vger.kernel.org, linux-kernel@vger.kernel.org,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH] security: have cap_dentry_init_security return error
In-Reply-To: <1394041657-7114-1-git-send-email-jlayton@redhat.com>
Message-ID: <alpine.LRH.2.02.1403071142060.19326@tundra.namei.org>
References: <1394041657-7114-1-git-send-email-jlayton@redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 5 Mar 2014, Jeff Layton wrote:

> Currently, cap_dentry_init_security returns 0 without actually
> initializing the security label. This confuses its only caller
> (nfs4_label_init_security) which expects an error in that situation, and
> causes it to end up sending out junk onto the wire instead of simply
> suppressing the label in the attributes sent.
> 
> When CONFIG_SECURITY is disabled, security_dentry_init_security returns
> -EOPNOTSUPP. Have cap_dentry_init_security do the same.
> 
> Signed-off-by: Jeff Layton <jlayton@redhat.com>

Applied to
git://git.kernel.org/pub/scm/linux/kernel/git/jmorris/linux-security.git next


-- 
James Morris
<jmorris@namei.org>
