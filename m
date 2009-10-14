From: Peter Staubach <staubach@redhat.com>
Subject: Re: [PATCH 0/4][RFC] NFSv3: implement extended attribute (XATTR)
 protocol
Date: Wed, 14 Oct 2009 08:46:35 -0400
Message-ID: <4AD5C82B.2020109@redhat.com>
References: <alpine.LRH.2.00.0909200020360.31818@tundra.namei.org>  <4ACB5FC0.7060307@redhat.com>  <alpine.LRH.2.00.0910091132130.32154@tundra.namei.org>  <4AD36C82.8080904@redhat.com>  <CA06CB5C-6084-45AA-B185-FBDA7E3B9754@excfb.com>  <4AD384BE.2090008@redhat.com>  <1255388158.3711.57.camel@heimdal.trondhjem.org>  <alpine.LRH.2.00.0910131733070.28896@tundra.namei.org> <1255458444.3711.113.camel@heimdal.trondhjem.org> <alpine.LRH.2.00.0910141134410.4671@tundra.namei.org> <4AD53200.1010100@schaufler-ca.com> <alpine.LRH.2.00.0910141526530.5279@tundra.namei.org> <4AD55879.2060207@schaufler-ca.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: James Morris <jmorris@namei.org>,
	Trond Myklebust <trond.myklebust@fys.uio.no>,
	Tom Haynes <tdh-8AdZ+HgO7noAvxtiuMwx3w@public.gmane.org>,
	"J. Bruce Fields" <bfields@fieldses.org>,
	"linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
	Christoph Hellwig <hch@infradead.org>,
	"linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>,
	David Patrick Quigley <dpquigl@tycho.nsa.gov>,
	Tyler Hicks <tyhicks@linux.vnet.ibm.com>,
	Dustin Kirkland <kirkland@canonical.com>
To: Casey Schaufler <casey@schaufler-ca.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:33942 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758619AbZJNMrd (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 14 Oct 2009 08:47:33 -0400
In-Reply-To: <4AD55879.2060207@schaufler-ca.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Casey Schaufler wrote:
> James Morris wrote:
>> On Tue, 13 Oct 2009, Casey Schaufler wrote:
>>
>>   
>>> If you wanted to you could implement a mapping scheme of your choice
>>> on the server.
>>>     
>> Just as long as you don't expect any defined semantics from this protocol 
>> -- it's purely xattr transport.
>>   
> 
> I agree completely. My point is that you can leave it up to the
> server to deal with if it is so inclined. No networking required.
> 
>>   
>>> A Smack server might be happy with mapping
>>> nfs.security.SMACK64 to security.SMACK64, while an HP/UX server might
>>> have a function to map nfs.security.selinux into security.BellAndLaPadula
>>> for its own nefarious purposes. Because you could do this strictly
>>> on the server you don't have to implement a negotiation protocol,
>>> although you could.
>>>     
>> I think if we start looking at negotiation & interpretation, then we've 
>> moved beyond simple metadata transport and should be looking at extending 
>> NFSv4 instead (e.g. like Labeled NFS).
>>   
> 
> Again, I agree. The appeal to this xattr approach is that there
> is no negotiation. It is just transport and storage. And for those
> who question the value of the scheme, it has been in use in Irix
> for -I'm not 100% sure- 10 years now.
> 

We need something like this support and this design is sufficient
to meet the current set of needs.  Let's not go too far, trying to
solve problems which do not need to be solved.

	Thanx...

		ps
