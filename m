Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp-o-3.desy.de ([131.169.56.156]:33787 "EHLO smtp-o-3.desy.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751606AbdFNV5H (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 14 Jun 2017 17:57:07 -0400
Received: from smtp-map-3.desy.de (smtp-map-3.desy.de [131.169.56.68])
        by smtp-o-3.desy.de (DESY-O-3) with ESMTP id 6FA08280896
        for <linux-nfs@vger.kernel.org>; Wed, 14 Jun 2017 23:57:05 +0200 (CEST)
Date: Wed, 14 Jun 2017 23:57:02 +0200 (CEST)
From: "Mkrtchyan, Tigran" <tigran.mkrtchyan@desy.de>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
        fedfs-utils Developers <fedfs-utils-devel@oss.oracle.com>,
        linux-nfs <linux-nfs@vger.kernel.org>, NFSv4 <nfsv4@ietf.org>
Message-ID: <1529444490.14625288.1497477422197.JavaMail.zimbra@desy.de>
In-Reply-To: <092C6B41-E55B-43D1-95DC-7A53A2445B7A@oracle.com>
References: <56804FBE-34B2-47FB-96EF-013D4476D89A@oracle.com> <20170607155549.GB26995@fieldses.org> <092C6B41-E55B-43D1-95DC-7A53A2445B7A@oracle.com>
Subject: Re: [nfsv4] Proposal for end-of-life for fedfs-utils development
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Chuck,

----- Original Message -----
> From: "Chuck Lever" <chuck.lever@oracle.com>
> To: "J. Bruce Fields" <bfields@fieldses.org>
> Cc: "fedfs-utils Developers" <fedfs-utils-devel@oss.oracle.com>, "linux-nfs" <linux-nfs@vger.kernel.org>, "NFSv4"
> <nfsv4@ietf.org>
> Sent: Wednesday, June 7, 2017 8:02:19 PM
> Subject: Re: [nfsv4] Proposal for end-of-life for fedfs-utils development

> Bruce, that's a good question, and an answer is worth sharing with
> the nfsv4 WG mailing list, whom I've cc'd.
> 
> 
>> On Jun 7, 2017, at 11:55 AM, bfields@fieldses.org wrote:
>> 
>> So if it's not too depressing I'd be curious what went wrong--did this
>> turn out to be harder than we thought to get stable, or are people happy
>> enough with automounting, or did we just not do a good job of explaining
>> it to people that might use it, or some combination of all those?
> 
> If you're interested in an intriguing discussion of what makes a
> successful protocol, I recommend RFC 5218. Now, not in any particular
> order, the main reasons FedFS has not been widely adopted are (IMO of
> course):
> 
> 
> 1. Lack of vendor adoption
> 
> After the specifications were completed, we anticipated two independent
> implementations. For various reasons the Solaris FedFS implementation
> was abandoned. One big reason was LDAP.
> 
> NFS/Ganesha has expressed some interest in FedFS over the years, but
> I'm not aware of an implementation.
> 
> NetApp abandoned FedFS before it was published as RFCs.
> 
> So we were left with just the Linux implementation, just like what
> happened with SPKM.
> 
> 
> 2. LDAP is onerously complex
> 
> The LDAP components of the Linux implementation were the worst to
> implement by far. This also proved to be the case in the Solaris
> prototype implementation. OpenLDAP is designed for massive scalability
> but aggressively shuns ease of administration.
> 
> It was suggested that we integrate with FreeIPA, which is a Linux-based
> management suite that can provide an LDAP service, a KDC, and a
> certificate authority. But there was never enough user inertia to make
> that effort.
> 
> There was resistance to integrating FedFS directly into nfs-utils
> because the LDAP components would have added complex library
> dependencies.
> 
> The LDAP pieces of FedFS are specified to use TLS, but NFS operates
> using GSS and Kerberos. Getting these two worlds to work together was
> going to be the next step (and also, figuring out how to make the LDAP
> service use GSS instead, which we should have done before completing
> the standard).
> 
> However, by the time the FedFS standards were complete, there was no
> longer WG interest to address its shortcomings. There were two small
> I-Ds published to start down that path. They went nowhere because the
> IETF's pool of LDAP expertise is difficult to consult, now that
> LDAP-related WGs have been disbanded.
> 
> IMO LDAP, which was chosen early in the 2000s by the IBM prototypes
> that were to become FedFS, was ultimately a poor choice for what
> eventually became the public FedFS standard. This can be attributed
> to changing times.
> 
> 
> 3. Lack of consensus about how to store junctions
> 
> There was never consensus in the Linux community about how to represent
> junction objects on disk. NFS wanted something that would look naturally
> like an empty directory to NFS versions that did not support referrals.
> Samba wanted something that could behave like symbolic links, as it
> had been using for its own DFS-style referrals. The filesystem folks
> were not interested in creating a new distinct object that could fill
> both roles.
> 
> As you are probably aware, Bruce, I asked about this every year at
> LFS/MM for several years. I was always told "get back to us when you
> have users."
> 
> Solaris went for reparse points in its implementation. Those are also
> supported by FreeBSD. I think RPs would have been a great direction
> but sadly these are not being actively pursued in the Linux FS
> community.
> 
> Lack of user adoption sapped the energy out of the effort to find a
> consensus. Though, if FedFS had been widely adopted before a consensus
> was reached on junction object representation, we'd have a significant
> data conversion problem.
> 
> 
> 4. Existing implementations are capable enough
> 
> This is mostly speculation on my part, but FedFS was a competitive
> response to the global namespace capabilities of AFS and SMB, not to
> any particular stated need in NFS communities.
> 
> I've discussed the use of FedFS with various large enterprises, but
> quite often the underlying needs are able to be filled by some form
> of pNFS. I think this class of solution is what NetApp and Primary
> Data have adopted.
> 
> Or put another way, pNFS seems capable of doing most anything that a
> referral-based mechanism can do. And in non-NFSv4 environments, the
> automounter is good enough for most people.
> 
> Certainly we could design something from the ground up that addresses
> many of these shortcomings, but I get about one query about FedFS a
> year. I just wonder if it would be worth the effort.

We  at DESY was interested in FedFS for two main reasons: one is to replace
AFS and second is to build a federation on independent NFS server.
The second option is not covered by pNFS as FedFS allows to run independent
pNFS instances with different administrative domains, implementations and 
namespaces, but still provide a common mount point. NetApp or Primary Data
does not provide solution for that. Even we don't :-D. 

Why we have failed? There was not clear how to set it up. LDAP management
was a mess. Schema was not standardized and not available with existing
LDAP server.

Currently we have 5 pNFS based instances with ~15PB in total. Some
nodes have direct mounts. But most of 'generic' clients automunter config
to fake FedFS as we don't know in advance which server will be used. Does
it works - Yes, does it solves all problems - No.

I would like to see a federated name space. We have the demand, but may be it's
only us.

For non NFS world we have a HTTP federation. It uses HTTP redirects, similar to
referrals. However, the tendency is to move towards distributed systems instead
of federated ones. If this project survive, then we can attempt to have a second
look at NFS federation. Life is a spiral.....

Regards,
   Tigran.

> 
> 
>> --b.
>> 
>> On Fri, Jun 02, 2017 at 11:01:05AM -0400, Chuck Lever wrote:
>>> Upstream fedfs-utils has not been under active development for
>>> two years or more, and there is a scant user base. I'd like to
>>> propose making 0.10 the final major release of fedfs-utils.
>>> 
>>> The plan:
>>> 
>>> - Since 0.10 is in at least one major enterprise distribution,
>>> I will remain available to integrate security fixes and make
>>> new minor releases in the 0.10 line, as needed, for one to
>>> two more years.
>>> 
>>> - Retire and remove fedfs-utils from upstream mirror distros
>>> such as Fedora rawhide.
>>> 
>>> - Transfer utilities such as nfsref into nfs-utils, with
>>> support for FedFS junctions removed.
>>> 
>>> - Announcements of the change in status will be made on
>>> fedfs-utils-announce and on the wiki.linux-nfs.org site.
> 
> --
> Chuck Lever
> 
> 
> 
> _______________________________________________
> nfsv4 mailing list
> nfsv4@ietf.org
> https://www.ietf.org/mailman/listinfo/nfsv4
