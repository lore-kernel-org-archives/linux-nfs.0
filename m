Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp110.prem.mail.sp1.yahoo.com ([98.136.44.55]:20384 "HELO
	smtp110.prem.mail.sp1.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1752109Ab0CAA4F (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 28 Feb 2010 19:56:05 -0500
Message-ID: <4B8B0F0B.4080603@schaufler-ca.com>
Date: Sun, 28 Feb 2010 16:49:15 -0800
From: Casey Schaufler <casey@schaufler-ca.com>
To: Stephen Smalley <sds@tycho.nsa.gov>
CC: James Morris <jmorris@namei.org>, linux-nfs@vger.kernel.org,
        linux-security-module@vger.kernel.org,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        "J. Bruce Fields" <bfields@fieldses.org>, Neil Brown <neilb@suse.de>,
        Dave Quigley <dpquigl@tycho.nsa.gov>,
        "Serge E. Hallyn" <serue@us.ibm.com>,
        Casey Schaufler <casey@schaufler-ca.com>
Subject: Re: [PATCH 5/5] NFSv3: Add server namespace support for XATTR protocol
 implementation
References: <alpine.LRH.2.00.1002261457420.25193@tundra.namei.org>	 <alpine.LRH.2.00.1002261537020.25193@tundra.namei.org> <1267191990.7691.37.camel@moss-pluto.epoch.ncsc.mil>
In-Reply-To: <1267191990.7691.37.camel@moss-pluto.epoch.ncsc.mil>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Stephen Smalley wrote:
> On Fri, 2010-02-26 at 15:37 +1100, James Morris wrote:
>   
>> Add support for a server namespace for storing and retrieving
>> client-supplied xattrs.  All xattrs are now stored on the server under
>> the user._nfsd namespace, and are not interpreted by the server at all.
>> This allows clients to utilize arbitrary xattr namespaces and for the
>> server to act only as a storage mechanism for the xattrs.
>>
>> The user._nfsd namespace was chosen because filesystems generally have
>> a user. xattr handler implemented.  Using something like system. would
>> require implementing a generalized handler for each backing fs on the
>> server, as well as requiring privilege to access.
>>     
>
> I'm wondering whether the user. namespace is best for storage on the
> server given that:
> - the user. namespace is restricted to regular files or directories (see
> xattr_permission()), and
> - the user. namespace applies its own set of permission checking logic
> that we don't necessarily want applied in the case of trusted. or
> security. attributes (e.g. special rules on sticky directories and read
> or write access to the file, see xattr_permission()), and
> - storing the attributes in the user. namespace would allow local users
> on the server to manipulate them directly.  I know that you stated an
> assumption that end users do not have local access to the exported
> filesystem, but it would be better if the system itself would restrict
> the ability to set these attributes to privileged processes on the
> server.
>
> Using the security. or trusted. namespace would avoid the restriction on
> file type and require CAP_SYS_ADMIN on setxattr.  That would prevent
> local modification by non-admins and should have no effect on clients
> (since nfsd doesn't drop CAP_SYS_ADMIN).
>
>   

I'm mostly in agreement with Stephen. I wouldn't object to a separate
"nfsd." namespace, as opposed to "security." or "trusted." because I
think that in reality you're not going to get very far without treating
is a special case in any event. May as well acknowledge it up front.

>> Currently, only the user and trusted namespaces are supported by
>> the client, as system and security namespaces require further analysis,
>> and some special-case handling will be required (for security.selinux,
>> at least).
>>
>> NFS ACLs continue to work as expected, because they implement a
>> hard-coded system xattr namespace which is invoked before the
>> NFS layer.  e.g. any access to a system.posix_acl_access xattr
>> is invokes the NFS_ACL protocol.
>>     
>
>   

