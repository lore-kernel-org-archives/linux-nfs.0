Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp103.prem.mail.sp1.yahoo.com ([98.136.44.58]:40480 "HELO
	smtp103.prem.mail.sp1.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1753275Ab0FWQDU (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 23 Jun 2010 12:03:20 -0400
Message-ID: <4C222EB7.9020501@schaufler-ca.com>
Date: Wed, 23 Jun 2010 08:56:39 -0700
From: Casey Schaufler <casey@schaufler-ca.com>
To: James Morris <jmorris@namei.org>
CC: Chuck Lever <chuck.lever@oracle.com>, linux-nfs@vger.kernel.org,
        linux-security-module@vger.kernel.org,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        "J. Bruce Fields" <bfields@fieldses.org>, Neil Brown <neilb@suse.de>,
        linux-fsdevel@vger.kernel.org, Stephen Smalley <sds@tycho.nsa.gov>,
        Christoph Hellwig <hch@infradead.org>,
        Casey Schaufler <casey@schaufler-ca.com>
Subject: Re: [PATCH 3/8][RFC v05] NFSv3: add client implementation of XATTR
 protocol
References: <alpine.LRH.2.00.1006212051530.13583@tundra.namei.org> <alpine.LRH.2.00.1006212128160.13583@tundra.namei.org> <4C1FC553.4030904@oracle.com> <alpine.LRH.2.00.1006220906300.16648@tundra.namei.org> <4C20D779.5040008@oracle.com> <alpine.LRH.2.00.1006230857450.25778@tundra.namei.org>
In-Reply-To: <alpine.LRH.2.00.1006230857450.25778@tundra.namei.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

James Morris wrote:
> On Tue, 22 Jun 2010, Chuck Lever wrote:
>
>   
>> Another place to look is at NFSv4.  Some of the operations that can be
>> performed on NFSv4 xattrs are probably nearly what you would want for an NFSv3
>> implementation.  I think it is desirable for anything done for NFSv3 to be
>> compatible with NFSv4, as that is already a standard.
>>     
>
> Are you referring to named attributes?  I've looked into this, as have 
> others, and they appear to be fundamentally incompatible with Linux/BSD 
> xattrs.  They're filesystems within files, with different semantics to the 
> name/value string model that we use.  I've heard a few developers say 
> they've looked at implementing xattrs over NAs, but found it unworkable.
>
> There's the issue of namespacing -- named attributes have no structured 
> namespace, whereas, Linux/BSD xattrs use namespaces to denote semantics.
>
> NAs are also intended to be managed at the user level without kernel 
> interaction, which conflicts with the semantics of our system namespaces.
>
> In the past, I've seen several discussions on the issue conclude that 
> NFSv4 should have distinct Linux/BSD xattr OPs, although I don't know what 
> the current thinking is.
>
>   
>>> (Btw, slides from a presentation I did on this last year at LinuxCon are
>>> at http://namei.org/presentations/linuxcon09_nfsv3xattrs.pdf)
>>>       
>> NFSACL was added to our NFSv3 implementation because there was a desire to
>> interoperate with an existing (albeit nonstandard) implementation. Here you
>> are building a new side band protocol from scratch.
>>     
>
> Well, it is implemented in IRIX -- I used their GPL code as a starting 
> point.  I'm not sure what that was not originally done through the IETF -- 
> possibly because there are so many different OS implementations of xattrs 
> with different semantics (some of which are slight).
>   

The IRIX implementation was not proposed to the IETF. This was
primarily a cost/benefit decision as no one else was using xattrs
the way that IRIX was an interoperability was not a major concern.
The Linux xattr scheme is only distinguishable from the IRIX
usage if you dig deeply, and Linux has much greater emphasis on
transparency than IRIX.

The important bit is that there is an existing worked example of
this model that has already been deployed, the code is available,
and it is compatible with the Linux way of doing xattrs.

> There are also several proprietary NFSv3 xattr implementations out there 
> across various OSs -- it would be useful to provide users of these an 
> open, maintained option, as well as a pathway to NFSv4.
>
>   
>> Before you go too much farther, you should justify the need to enhance a
>> closed standard like NFSv3 rather than expanding on NFSv4 for your purposes.
>> Since NFSv4 already has a lot of what is needed, it seems like you'd just need
>> a couple of changes in order to support name/value pairs.
>>     
>
> As mentioned, I don't think the NFSv3 NAs are a good match to the 
> Linux/BSD xattr semantics.
>
> e.g. what happens if a client creates a named attribute called 
> "system.posix_acl_access" ?  
>
> My reading of the spec is that a compliant server implementation would 
> have to allow this, from any user-level client application, without 
> interpretation of the NA itself.
>
> If this is is the case, then it would clash with our ACL mechanism, which 
> uses xattrs locally for storage, with system-level interpretation and 
> mediation.
>
>   
>>  You would have a shot at actually making this an internet standard.
>>
>> I think this community would prefer to advance reasons for users to adopt
>> NFSv4, rather than tie users even more to NFSv3.
>>     
>
> There are two main drivers for this NFSv3 work.
>
> One is to simply provide xattr support over NFS for Linux (and possibly 
> FreeBSD), given that it xattrs are a common filesystem feature and that 
> many people are still using NFSv3.
>
> Since I started this work last year, more people do seem to be using NFSv4 
> (it seems to be the default for some distros now).  I'd be interested if 
> anyone has figures or informed guesses on NFSv4 adoption -- certainly, if 
> NFSv3 is going to effectively disappear soon, it affects the rationale for 
> this work.
>
> The other driver is the integration of MAC security into general purpose 
> OSs.  SELinux and Smack extend Unix inode security metadata with MAC 
> labels implemented as xattrs.  There is currently no way to convey these 
> labels over NFS, as there is no support for xattrs in the NFS protocol.
>
> There is effort underway for NFSv4 in this area, designed around the full 
> security requirements of networked MAC labeling (Labeled NFS).  This 
> is a far more comprehensive effort, and obviously does not provide a 
> solution for NFSv3 users.
>
> With this NFSv3 xattr code, we are able to provide useful partial support 
> for MAC security labeling, for the scenario where the server simply stores 
> security labels without interpreting them.  This allows clients to perform 
> fine-grained security labeling over NFSv3, and enforce policy locally.
>
> There is considerable demand for NFS security labeling from users.  
>
> They've been deploying MAC security in production for several years now 
> but have always had to limit what they do regarding NFS.  This would 
> provide a useful partial solution for these users via NFSv3, as an 
> intermediate step towards adopting NFSv4 and Labeled NFS.
>
> One currently pressing use-case is where systems are deployed in VMs with 
> remote filesystems.  It becomes very problematic to deploy security 
> schemes such as sVirt in this manner without fine-grained security 
> labeling, hindering attempts to take advantage of its security benefits 
> (see the notes on page 4 of the Atsec virt comparison study [1]).
>
> Another more general case is simply being able to use NFS and MAC security 
> at the same time.  A significant majority of Fedora users have SELinux 
> enabled [2], for example.  If they want to deploy NFS home directories, 
> they either lose fine-grained security labeling there or disable security 
> entirely.  In other words, lack of NFS support is hindering security 
> adoption.
>
> I would not see this as tying people in to NFSv3, rather, providing useful 
> functionality until they adopt NFSv4 with all of these features supported.  
> The NFSv4 LNFS effort will provide a more complete solution for security 
> labeling, and is being worked on in parallel, but it is not clear how long 
> the IETF processes for the various aspects of that project will take.
>
> In summary, the benefits are:
>
> - General xattr support for Linux NFSv3 users, and possibly for compatible 
> OSs such as FreeBSD
>
> - Storage of security labels over NFSv3 for users deploying Linux MAC 
> security schemes (SELinux and Smack)
>
> These objectives can be met relatively simply and quickly with this XATTR 
> protocol, which has precedents in the Linux ACL work and in existing NFSv3 
> xattr implementations.
>
>
>
> [1] http://www.redhat.com/f/pdf/rhev/kvm_security_comparison.pdf
> [2] http://smolt.fedoraproject.org/static/stats/stats.html
>
>   

