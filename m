Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:56902 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753243AbcK2ShC (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 29 Nov 2016 13:37:02 -0500
Subject: Re: RFC rpc.gssd enhancement
To: Lukas Hejtmanek <xhejtman@ics.muni.cz>, linux-nfs@vger.kernel.org
References: <20161128183757.d5pz64tsigmaxdc7@ics.muni.cz>
From: Steve Dickson <SteveD@redhat.com>
Message-ID: <645d0f56-f357-6c58-5e2f-e85bbae93db1@RedHat.com>
Date: Tue, 29 Nov 2016 13:37:00 -0500
MIME-Version: 1.0
In-Reply-To: <20161128183757.d5pz64tsigmaxdc7@ics.muni.cz>
Content-Type: text/plain; charset=iso-8859-2
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hello,

On 11/28/2016 01:37 PM, Lukas Hejtmanek wrote:
> Hello,
> 
> would it be acceptable to add an option for rpc.gssd to use host keytab if
> user's kerberos ticket is not available?
I'm not sure how this would work.

The kernel would do an upcall to the user's
creds but they have expired. Now if this 
new option is set, rpc.gssd would used 
the machine's cred? It seems to me that
would not be too secure.
 
> 
> Consider the following scenario:
> 1) machine has NFS mounted /home using kerberos authentication
> 2) user logs in, sshd creates krb ticket ($HOME/.k5login needs to be world
> readable to allow kerberized access, e.g., using kerberos ticket)
> 3) user stays logged in and krb ticket expires
> 4) kinit to renew ticket produces strange error because $HOME is not
> accessible and a new ticket is not created.
> 
> So, I think in this case, I would like to see rpc.gssd uses host keytab while
> user's ticket is not available, which maps to nobody/nogroup, but kinit should
> succeed.
Who is going the kinits in this scenario?

 
> 
> Or are there any other options if one is using kerberized homes only?
> 
I'm pretty sure sssd will what you are looking for.

steved.
