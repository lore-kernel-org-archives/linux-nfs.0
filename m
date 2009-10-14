From: Tyler Hicks <tyhicks@linux.vnet.ibm.com>
Subject: Re: [PATCH 0/4][RFC] NFSv3: implement extended attribute (XATTR)
 protocol
Date: Wed, 14 Oct 2009 10:05:47 -0500
Message-ID: <4AD5E8CB.1070008@linux.vnet.ibm.com>
References: <alpine.LRH.2.00.0909200020360.31818@tundra.namei.org> <4ACB5FC0.7060307@redhat.com> <alpine.LRH.2.00.0910091132130.32154@tundra.namei.org> <4AD36C82.8080904@redhat.com> <CA06CB5C-6084-45AA-B185-FBDA7E3B9754@excfb.com> <4AD384BE.2090008@redhat.com> <1255388158.3711.57.camel@heimdal.trondhjem.org> <alpine.LRH.2.00.0910131733070.28896@tundra.namei.org> <1255458444.3711.113.camel@heimdal.trondhjem.org> <alpine.LRH.2.00.0910141134410.4671@tundra.namei.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Trond Myklebust <trond.myklebust@fys.uio.no>,
	Peter Staubach <staubach@redhat.com>,
	Tom Haynes <tdh@excfb.com>,
	"J. Bruce Fields" <bfields@fieldses.org>,
	"linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
	Christoph Hellwig <hch@infradead.org>,
	Casey Schaufler <casey@schaufler-ca.com>,
	"linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>,
	David Patrick Quigley <dpquigl@tycho.nsa.gov>,
	Dustin Kirkland <kirkland@canonical.com>
To: James Morris <jmorris@namei.org>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <alpine.LRH.2.00.0910141134410.4671@tundra.namei.org>
Sender: linux-fsdevel-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 10/13/2009 07:48 PM, James Morris wrote:
> On Tue, 13 Oct 2009, Trond Myklebust wrote:
> 
> [added the ecryptfs folk]
> 
>> On Tue, 2009-10-13 at 18:02 +1100, James Morris wrote:
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
>>
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
> i.e. the client always sends and receives "security.selinux"; the 
> server by default maps these locally as "nfs.security.selinux"; and may be 
> optionally configured to map to "nfs.$(custom).security.selinux"
> 
> I wonder how to handle ecryptfs -- it strikes me as a special case where 
> the semantics are always local i.e. files can always be decrypted locally 
> because of the crypto metatdata stored with them.

After skimming back through the thread, I'm not quite understanding the
special case that you're getting at here.  Are you assuming that
eCryptfs uses the security namespace?

#define ECRYPTFS_XATTR_NAME "user.ecryptfs"

In my opinion, the option to store the eCryptfs metadata in an xattr is
a bad idea and I haven't heard of anyone actually using the feature.
I've considered removing it for a while now.  Don't let this bad
eCryptfs feature get in the way of a good design decision. :)

Tyler
