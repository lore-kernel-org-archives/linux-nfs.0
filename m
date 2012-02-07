Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:58785 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756681Ab2BGT3k (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 7 Feb 2012 14:29:40 -0500
Message-ID: <4F317BA1.4050102@netapp.com>
Date: Tue, 07 Feb 2012 14:29:37 -0500
From: Bryan Schumaker <bjschuma@netapp.com>
MIME-Version: 1.0
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
CC: Jeff Layton <jlayton@redhat.com>,
        "Schumaker, Bryan" <Bryan.Schumaker@netapp.com>,
        "bfields@fieldses.org" <bfields@fieldses.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 1/3] NFS: Fall back on old idmapper if request_key() fails
References: <1327614865-29322-1-git-send-email-bjschuma@netapp.com>  <20120207141254.2948e735@tlielax.poochiereds.net> <1328642485.4124.40.camel@lade.trondhjem.org>
In-Reply-To: <1328642485.4124.40.camel@lade.trondhjem.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 02/07/12 14:21, Myklebust, Trond wrote:

> On Tue, 2012-02-07 at 14:12 -0500, Jeff Layton wrote:
>> On a 32-bit box when you try to mount and low memory is heavily
>> fragmented, you can get a NULL pointer back on that kzalloc with a
>> nice stack trace headed by a message like this:
>>
>>     mount.nfs: page allocation failure. order:4, mode:0xc0d0
>>
>> Here's a RHBZ against RHEL6 if you're interested in gory details:
>>
>>     https://bugzilla.redhat.com/show_bug.cgi?id=730045
>>
>> In any case, this problem was one of the reasons for pushing the new
>> idmapper. A number of people have complained about this problem in the
>> past and we told them "use the new idmapper". Now, with this patchset,
>> that won't help.
> 
> Wait. How is that true? The whole point of this patchset is that it
> allows you to compile in support for _both_ idmappers, with the new
> keyring-based idmapper being tried first. The client then falls back to
> using the old idmapper if and only if the user has failed to set up the
> new idmapper correctly.


Because it still allocates the structures, they just go unused if the new idmapper works.  This seems kind of wasteful now that I know about it...

> 
>> I think the right solution is to probably look at breaking up the idmap
>> structure in the legacy idmapper into multiple allocations. It's more
>> complicated to deal with and will mean restructuring the code a bit,
>> but it will allow for a relatively graceful transition to the new
>> idmapper.
> 
> I'd like to see the old idmapper code changed to use the new
> keyring-based cache instead. I've asked Bryan to look into how we can do
> this.


This will probably be easier than splitting up the allocation.  It should be possible to change whatever "actor" function the request_key code takes and then try again.  What is the best way to handle the fallback?  This patch always tries the new idmapper before falling back on the old one.  I could also set it up to try the new idmapper once, change the function pointer if it fails, and never change it back (until NFS is restarted).

- Bryan

> 
> 
> 


