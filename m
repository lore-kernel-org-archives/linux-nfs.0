Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from minas.ics.muni.cz ([147.251.4.46]:48649 "EHLO minas.ics.muni.cz"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750754AbcK2Ssv (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 29 Nov 2016 13:48:51 -0500
Date: Tue, 29 Nov 2016 19:48:43 +0100
From: Lukas Hejtmanek <xhejtman@ics.muni.cz>
To: Steve Dickson <SteveD@redhat.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: RFC rpc.gssd enhancement
Message-ID: <20161129184843.jrwbnytggrz6kdir@ics.muni.cz>
References: <20161128183757.d5pz64tsigmaxdc7@ics.muni.cz>
 <645d0f56-f357-6c58-5e2f-e85bbae93db1@RedHat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
In-Reply-To: <645d0f56-f357-6c58-5e2f-e85bbae93db1@RedHat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hello,

On Tue, Nov 29, 2016 at 01:37:00PM -0500, Steve Dickson wrote:
> The kernel would do an upcall to the user's
> creds but they have expired. Now if this 
> new option is set, rpc.gssd would used 
> the machine's cred? It seems to me that
> would not be too secure.

maybe it is not considered secure, but it is still more secure to me than
using sec=sys. 

the problem is, that kerberized home is problem for .k5login file and also for
.ssh/authorized_keys. While the .k5login file is accessed with root context
(sshd), the authorized_keys is accessed with user context, so login via ssh
pubkey is not possible at all. 

moreover, consider scenario where a user has symlink from his/her home to NFS
share, without kerberos ticket, logon process can get stucked until he/she has
the ticket. The ticket cannot be created until success logon. 

> > Consider the following scenario:
> > 1) machine has NFS mounted /home using kerberos authentication
> > 2) user logs in, sshd creates krb ticket ($HOME/.k5login needs to be world
> > readable to allow kerberized access, e.g., using kerberos ticket)
> > 3) user stays logged in and krb ticket expires
> > 4) kinit to renew ticket produces strange error because $HOME is not
> > accessible and a new ticket is not created.
> > 
> > So, I think in this case, I would like to see rpc.gssd uses host keytab while
> > user's ticket is not available, which maps to nobody/nogroup, but kinit should
> > succeed.
> Who is going the kinits in this scenario?

the user comes back and wants to issue kinit. Kinit fails due to eperm on
anything in $HOME. The user has to log off and on again.

> I'm pretty sure sssd will what you are looking for.

how this could help me to work around expired tickets?

-- 
Luká¹ Hejtmánek
