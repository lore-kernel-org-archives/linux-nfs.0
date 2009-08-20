From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: [PATCH 30/32] NFS: Add a dns resolver for use with NFSv4
 referrals and migration
Date: Thu, 20 Aug 2009 15:11:23 -0400
Message-ID: <1250795483.26904.6.camel@heimdal.trondhjem.org>
References: <1250725135-14632-1-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-2-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-3-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-4-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-5-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-6-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-7-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-8-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-9-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-10-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-11-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-12-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-13-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-14-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-15-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-16-git-s! ! end-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-17-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-18-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-19-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-20-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-21-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-22-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-23-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-24-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-25-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-26-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-27-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-28-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-29-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-30-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-31-git-send-email-Trond.Myklebust@! ne! tapp.com>
	 <74466E40-D037-4DCD-9129-0EE7B987C843@oracle.com! >
	 <1250785542.19156.12.camel@heimdal.trondhjem.org>
	 <F9C66E65-D885-4F14-88AD-16DCC5E5B563@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:42943 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755195AbZHTTLX (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 20 Aug 2009 15:11:23 -0400
In-Reply-To: <F9C66E65-D885-4F14-88AD-16DCC5E5B563@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 2009-08-20 at 12:54 -0400, Chuck Lever wrote:
> > I'm not too concerned. As it says above, this is a sample that
> > illustrates how you could do it. It does work, though, so people can
> > definitely use it to test the functionality.
> 
> I'm thinking of when we want to add new upcalls, since you went to  
> some length to generalize this facility.  It would be easier to manage  
> adding a new script than it would to update an existing one, and an  
> admin or distributor could control what scripts are present, or  
> provide their own.
> 
> The act of editing a single script is easy enough, but then you have  
> to worry about updates from the distributor possibly overwriting the  
> local modifications, and so on, and so on.
> 
> A model like /etc/init.d might be easier to manage in the long run.

True, and we might want to consider adding something like that into
nfs-utils.

Yes, I did generalise the facility: I'm planning on redoing the NFSv4
idmapper at some point soon.

> >>> +#define NFS_DNS_HASHBITS 4
> >>> +#define NFS_DNS_HASHTBL_SIZE (1 << NFS_DNS_HASHBITS)
> >>
> >> So the hash table is only 16 buckets.  Is it really worth the trouble
> >> of keeping a small cache of hostname lookups in the kernel?  I  
> >> guess I
> >> don't have a clear idea of how often you need to handle DNS  
> >> resolution
> >> for FS_LOCATIONS.
> >
> > At the moment, the number of referrals out there are few, but we're
> > expecting that to grow when the whole federated fs management
> > infrastructure develops.
> 
> OK.  Can you give some sense of quantity?

Could be in the hundreds in a large organisation. Then again, if we go
do the equivalent of /afs, it could be in the thousands. We'll see how
that turns out.

> >>> +#define NFS_DNS_HOSTNAME_MAXLEN	(128)
> >>
> >> It looks like you are using this to size the target buffer for a
> >> presentation address, not a hostname.  Perhaps you should use
> >> INET6_ADDRSTRLEN+IPV6_SCOPEID_LEN+1 here instead, and/or change the
> >> name of the macro.
> >
> > No. I'm using it primarily to store the hostname. See nfs_dns_parse().
> 
> OK, you store the presentation address in buf1 first, and now I see  
> that farther down you are storing the hostname too.  But note that the  
> maximum size of a hostname is 1024 (see the definition of NI_MAXHOST  
> in user space).
> 
> If there is a protocol specified limit on the hostname string returned  
> via FS_LOCATION, perhaps that should be noted here.  Otherwise, 128 is  
> too small, I think.

There is no limit in the protocol, but DNS names that are larger than 64
bytes will not fit into a Linux utsname structure. For that reason, I
think 128 characters is sufficient.

Anybody who has to type www.<122 characters>.com has my sympathy, and
deepest regrets...


-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com
