From: Casey Schaufler <casey@schaufler-ca.com>
Subject: Re: [PATCH 0/4][RFC] NFSv3: implement extended attribute (XATTR)
 protocol
Date: Tue, 13 Oct 2009 19:05:52 -0700
Message-ID: <4AD53200.1010100@schaufler-ca.com>
References: <alpine.LRH.2.00.0909200020360.31818@tundra.namei.org>  <4ACB5FC0.7060307@redhat.com>  <alpine.LRH.2.00.0910091132130.32154@tundra.namei.org>  <4AD36C82.8080904@redhat.com>  <CA06CB5C-6084-45AA-B185-FBDA7E3B9754@excfb.com>  <4AD384BE.2090008@redhat.com>  <1255388158.3711.57.camel@heimdal.trondhjem.org>  <alpine.LRH.2.00.0910131733070.28896@tundra.namei.org> <1255458444.3711.113.camel@heimdal.trondhjem.org> <alpine.LRH.2.00.0910141134410.4671@tundra.namei.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Trond Myklebust <trond.myklebust@fys.uio.no>,
	Peter Staubach <staubach@redhat.com>,
	Tom Haynes <tdh-8AdZ+HgO7noAvxtiuMwx3w@public.gmane.org>,
	"J. Bruce Fields" <bfields@fieldses.org>,
	"linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
	Christoph Hellwig <hch@infradead.org>,
	"linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>,
	David Patrick Quigley <dpquigl@tycho.nsa.gov>,
	Tyler Hicks <tyhicks@linux.vnet.ibm.com>,
	Dustin Kirkland <kirkland@canonical.com>
To: James Morris <jmorris@namei.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp107.prem.mail.sp1.yahoo.com ([98.136.44.62]:20076 "HELO
	smtp107.prem.mail.sp1.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1753989AbZJNCGi (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 13 Oct 2009 22:06:38 -0400
In-Reply-To: <alpine.LRH.2.00.0910141134410.4671-CK9fWmtY32x9JUWOpEiw7w@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

James Morris wrote:
> On Tue, 13 Oct 2009, Trond Myklebust wrote:
>
> [added the ecryptfs folk]
>
>   
>> On Tue, 2009-10-13 at 18:02 +1100, James Morris wrote:
>>     
>>> This xattr approach would only cover the "dumb server" scenario, where the 
>>> server simply stores and retrieves security labels on behalf of the 
>>> client.  It's intended primarily to enable things like nfsroot, backups, 
>>> serving virtualized file systems etc., and not for fully trusted sharing 
>>> like Labeled NFS.
>>>
>>> It is essentially just security label transport.
>>>
>>> Support for this feature would be configured at the server, possibly an 
>>> option in /etc/exports which enables specific security namespaces, e.g:
>>>
>>>   /opt/share   10.0.0.0/8(rw,insecure,xattr="user.*,security.SMACK64")
>>>
>>> This says that the XATTR side protocol is enabled and clients can read and 
>>> write user and security.smack xattrs (local DAC would be applied to both).
>>>
>>> The server kernel would likely need to know that these are foreign labels, 
>>> and not necessarily 'trust' them for its own use, so a root_squash -like 
>>> option may be used to remap them to an 'untrusted' local label for local 
>>> enforcement purposes -- if it was running SELinux or Smack at all, which 
>>> it may not be.
>>>       
>> Fair enough. That might indeed work.
>>
>> One simple alternative might be to just store the exported xattrs in
>> something other than the 'security' extended attribute namespace so that
>> your server processes don't have to deal with any conflicts.
>>
>> IOW: maybe add a 'nfs.security' xattr namespace, which would contain
>> those security labels that are actually exported by this XATTR protocol,
>> and which the clients could then translate into their local 'security'
>> labels.
>>     
>
> This sounds like a really good idea, and may provide a general solution 
> for non-user xattrs.  i.e. any system, security or trusted xattr is stored 
> in the 'nfs' namespace on the server, and these are always opaque to the 
> server -- semantics are managed at the client.
>
> The wire protocol would always carry the client view, for simplicity, and 
> there's no negotiation -- label mapping is always configured at the server 
> by the admin.
>   

If you wanted to you could implement a mapping scheme of your choice
on the server. A Smack server might be happy with mapping
nfs.security.SMACK64 to security.SMACK64, while an HP/UX server might
have a function to map nfs.security.selinux into security.BellAndLaPadula
for its own nefarious purposes. Because you could do this strictly
on the server you don't have to implement a negotiation protocol,
although you could.

> i.e. the client always sends and receives "security.selinux"; the 
> server by default maps these locally as "nfs.security.selinux"; and may be 
> optionally configured to map to "nfs.$(custom).security.selinux"
>
> I wonder how to handle ecryptfs -- it strikes me as a special case where 
> the semantics are always local i.e. files can always be decrypted locally 
> because of the crypto metatdata stored with them.
>
>   
>> You might even be able to store per-client security labels as something
>> like 'nfs.$(hostname).security', or perhaps have a namespace like
>> 'nfs.fedora11.security' that applies to all clients running fedora?
>>     
>
> I don't know if there's an established need for this, but some kind of 
> generalized mapping scheme might be useful, and I suspect it's pretty 
> simple to implement as long as the xattr values are always opaque to the 
> server.
>
>
> - James
>   

