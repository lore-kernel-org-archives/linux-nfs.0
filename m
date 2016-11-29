Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:33144 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753065AbcK2T2L (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 29 Nov 2016 14:28:11 -0500
Subject: Re: RFC rpc.gssd enhancement
To: Lukas Hejtmanek <xhejtman@ics.muni.cz>
References: <20161128183757.d5pz64tsigmaxdc7@ics.muni.cz>
 <645d0f56-f357-6c58-5e2f-e85bbae93db1@RedHat.com>
 <20161129184843.jrwbnytggrz6kdir@ics.muni.cz>
Cc: linux-nfs@vger.kernel.org
From: Steve Dickson <SteveD@redhat.com>
Message-ID: <2ff5b760-a3ca-9ab8-d1a8-efe5f36aaaf3@RedHat.com>
Date: Tue, 29 Nov 2016 14:28:10 -0500
MIME-Version: 1.0
In-Reply-To: <20161129184843.jrwbnytggrz6kdir@ics.muni.cz>
Content-Type: text/plain; charset=iso-8859-2
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 11/29/2016 01:48 PM, Lukas Hejtmanek wrote:
> Hello,
> 
> On Tue, Nov 29, 2016 at 01:37:00PM -0500, Steve Dickson wrote:
>> The kernel would do an upcall to the user's
>> creds but they have expired. Now if this 
>> new option is set, rpc.gssd would used 
>> the machine's cred? It seems to me that
>> would not be too secure.
> 
> maybe it is not considered secure, but it is still more secure to me than
> using sec=sys. 
True.

> 
> the problem is, that kerberized home is problem for .k5login file and also for
> .ssh/authorized_keys. While the .k5login file is accessed with root context
> (sshd), the authorized_keys is accessed with user context, so login via ssh
> pubkey is not possible at all. 
What would the .k5login look like and what would the principal look like?
My apologies but I'm not very familar with how sshd interacts with 
the .k5login. 

> 
> moreover, consider scenario where a user has symlink from his/her home to NFS
> share, without kerberos ticket, logon process can get stucked until he/she has
> the ticket. The ticket cannot be created until success logon.
Yeah... This has been a long running problem which is why
I'm curious about your RFC... 
 
> 
>>> Consider the following scenario:
>>> 1) machine has NFS mounted /home using kerberos authentication
>>> 2) user logs in, sshd creates krb ticket ($HOME/.k5login needs to be world
>>> readable to allow kerberized access, e.g., using kerberos ticket)
>>> 3) user stays logged in and krb ticket expires
>>> 4) kinit to renew ticket produces strange error because $HOME is not
>>> accessible and a new ticket is not created.
>>>
>>> So, I think in this case, I would like to see rpc.gssd uses host keytab while
>>> user's ticket is not available, which maps to nobody/nogroup, but kinit should
>>> succeed.
>> Who is going the kinits in this scenario?
> 
> the user comes back and wants to issue kinit. Kinit fails due to eperm on
> anything in $HOME. The user has to log off and on again.
I see.

> 
>> I'm pretty sure sssd will what you are looking for.
> 
> how this could help me to work around expired tickets?
> 
sssd will renew the ticket before it expired (I think).
But the user has to be known to a ipa-server on 
an ipa-client, so this may not be workable... 

steved.
