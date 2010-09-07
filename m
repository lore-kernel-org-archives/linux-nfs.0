Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet10.oracle.com ([148.87.113.121]:27915 "EHLO
	rcsinet10.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752933Ab0IGPwi convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 7 Sep 2010 11:52:38 -0400
Subject: Re: [PATCH 1/1] mount: RDMA processing in the mount command is broken
Content-Type: text/plain; charset=us-ascii
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <4C8153B5.7020304@RedHat.com>
Date: Tue, 7 Sep 2010 11:51:09 -0400
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Message-Id: <455C9921-2849-4804-B28E-298DC2888471@oracle.com>
References: <1283457651-12010-1-git-send-email-steved@redhat.com> <1FB4635E-5757-420B-A32B-47D2D1778A56@oracle.com> <4C802914.50505@RedHat.com> <34BF22EC-F3D3-40AA-A4AA-8019886DAC94@oracle.com> <4C8153B5.7020304@RedHat.com>
To: Steve Dickson <SteveD@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Sep 3, 2010, at 3:59 PM, Steve Dickson wrote:
> Hey,
> 
> On 09/03/2010 12:01 PM, Chuck Lever wrote:
>> But to address a specific technical point: if nfs_nfs_protocol() 
>> returned a specific value for "proto=rdma" or "rdma" then I don't think 
>> you would need rdma_enabled() at all.
> I took a look doing it this way... sincerely hoping it would be that
> easy.. but its not... 

I think you are making this way harder than it needs to be because you want to be "right."  I can send you three patches that prove that my suggestion would make this code simpler and obviate the need for rdma_enabled().

> nfs_nfs_protocol() returns network established protocols for things like 
> the portmapper, the configuration file and such... Now we have clearly 
> established there is no IPPROTO_RDMA protocol, so I would have to teach 
> all the callers of nfs_nfs_protocol() about IPPROTO_RDMA.

The nfs_nfs_protocol() function is designed to parse protocol-related mount options.  There's no reason to add more functions that do the same thing.

IPPROTO_RDMA is not what is needed, since RDMA is not an IP protocol.  A fixed arbitrary local value is all that is required.

> Plus, nfs_get_proto() would still have to be taught about rdma since 
> the first thing it does is call getnetconfigent() with the given netid and
> we've clearly established we currently don't have the support for 
> a rdma netid...

Yes.  Simply done.

> Now I'm not against doing this work, but let the IANA people to
> give use something to work with. When I see the rdma protocol in
> /etc/protocols and a IPPROTO_RDMA established, I will be more
> than willing to do the work... but at this point, to simply
> enable this new technology, its just not worth it... 

That claim only makes sense if you believe there would be a lot of work.  I'll post my version in a bit and you will see how very simple it is.

> All that's need, at this point, is for the mount command to 
> use the correct address family, set the correct protocol version 
> and not do portmapper negation.. that's it!

By not setting the *protocol output parameter in nfs_get_proto() you invite future bugs.  You basically are breaking the API contract (that both output variables will be filled in) and require that all callers be aware that sometimes *protocol won't be set.  That's a layering violation.  Isn't this code complicated enough without such a special case?

-- 
chuck[dot]lever[at]oracle[dot]com




