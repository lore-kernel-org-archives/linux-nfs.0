Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp104.prem.mail.sp1.yahoo.com ([98.136.44.59]:42923 "HELO
	smtp104.prem.mail.sp1.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1753764Ab0FWVjx (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 23 Jun 2010 17:39:53 -0400
Message-ID: <4C227F28.7050604@schaufler-ca.com>
Date: Wed, 23 Jun 2010 14:39:52 -0700
From: Casey Schaufler <casey@schaufler-ca.com>
To: Chuck Lever <chuck.lever@oracle.com>
CC: James Morris <jmorris@namei.org>, linux-nfs@vger.kernel.org,
        linux-security-module@vger.kernel.org,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        "J. Bruce Fields" <bfields@fieldses.org>, Neil Brown <neilb@suse.de>,
        linux-fsdevel@vger.kernel.org, Stephen Smalley <sds@tycho.nsa.gov>,
        Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH 3/8][RFC v05] NFSv3: add client implementation of XATTR
 protocol
References: <alpine.LRH.2.00.1006212051530.13583@tundra.namei.org> <alpine.LRH.2.00.1006212128160.13583@tundra.namei.org> <4C1FC553.4030904@oracle.com> <alpine.LRH.2.00.1006220906300.16648@tundra.namei.org> <4C20D779.5040008@oracle.com> <alpine.LRH.2.00.1006230857450.25778@tundra.namei.org> <4C224463.90306@oracle.com>
In-Reply-To: <4C224463.90306@oracle.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Chuck Lever wrote:
> Hi James-
>
> Good points, see below.
>
> On 06/22/10 08:26 PM, James Morris wrote:
>> On Tue, 22 Jun 2010, Chuck Lever wrote:
>>
>>> Another place to look is at NFSv4.  Some of the operations that can be
>>> performed on NFSv4 xattrs are probably nearly what you would want
>>> for an NFSv3
>>> implementation.  I think it is desirable for anything done for NFSv3
>>> to be
>>> compatible with NFSv4, as that is already a standard.
>>
>> Are you referring to named attributes?  I've looked into this, as have
>> others, and they appear to be fundamentally incompatible with Linux/BSD
>> xattrs.  They're filesystems within files, with different semantics
>> to the
>> name/value string model that we use.  I've heard a few developers say
>> they've looked at implementing xattrs over NAs, but found it unworkable.
>>
>> There's the issue of namespacing -- named attributes have no structured
>> namespace, whereas, Linux/BSD xattrs use namespaces to denote semantics.
>>
>> NAs are also intended to be managed at the user level without kernel
>> interaction, which conflicts with the semantics of our system
>> namespaces.
>>
>> In the past, I've seen several discussions on the issue conclude that
>> NFSv4 should have distinct Linux/BSD xattr OPs, although I don't know
>> what
>> the current thinking is.
>
> My thought was to extend NFSv4 to provide native xattr support
> alongside named attribute support.  If NFSv4 is getting security label
> support then that's a moot point, unless there are other use cases for
> exposing xattrs to NFS clients.
>
> Overall, I think everyone is better off in the long run if we get the
> needed features into NFSv4.

Agreed, but we're talking years before that happens. Work on labeled
NFS has been ongoing since 1985 and there is no reason to believe that
NFSv4 is going to progress at a quicker pace than any of its predecessors.

