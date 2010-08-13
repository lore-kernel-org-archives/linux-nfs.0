From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: numeric UIDs
Date: Fri, 13 Aug 2010 14:43:31 -0400
Message-ID: <1CE074A1-2371-40E5-B0E5-F80474B02FA2@oracle.com>
References: <DE966DA98A4ABE438D726BDF1699CF61403FAF9D@MX05A.corp.emc.com> <20100803215704.GA15494@merit.edu> <1280873719.14520.17.camel@heimdal.trondhjem.org> <20100803222337.GA9752@fieldses.org> <1280874675.14520.23.camel@heimdal.trondhjem.org> <20100803224245.GB9752@fieldses.org> <1280887336.24669.23.camel@heimdal.trondhjem.org> <20100805153421.GD27141@fieldses.org> <20100812092232.344314b2@notabene> <4C6559FA.5070809@RedHat.com> <20100813163156.GA16863@fieldses.org>
Mime-Version: 1.0 (Apple Message framework v1081)
Content-Type: text/plain; charset=us-ascii
Cc: Steve Dickson <SteveD@redhat.com>, Neil Brown <neilb@suse.de>,
	Trond Myklebust <trond.myklebust@fys.uio.no>,
	Jim Rees <rees@umich.edu>, Daniel.Muntz@emc.com,
	linux-nfs@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet10.oracle.com ([148.87.113.121]:39224 "EHLO
	rcsinet10.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753184Ab0HMSo6 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 13 Aug 2010 14:44:58 -0400
In-Reply-To: <20100813163156.GA16863@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Aug 13, 2010, at 12:31 PM, J. Bruce Fields wrote:

> On Fri, Aug 13, 2010 at 10:43:06AM -0400, Steve Dickson wrote:
>> 
>> 
>> On 08/11/2010 07:22 PM, Neil Brown wrote:
>>> 
>>> I agree.  And surely it can all be solved in idmapd.
>>> 
>>> On the server, tell idmapd to map all users to "NUMERIC_USER:%d" and all
>>> groups to "NUMERIC_GROUP:%d" (or whatever) for some given clients (i.e. stop
>>> ignoring the 'authentication name'.  And of course map those names back to
>>> numbers.
>>> 
>>> I don't know if the client can easily differentiate based on which server it
>>> is talking to, but there is probably less need there (and maybe it can
>>> anyway).
>>> 
>>> It shouldn't take more that half an hour to hack something into
>>> idmapd.c:nfsdcb() for the server side and nfscb for the client side - or
>>> for a quicker hack, just go directly to imconv and ignore the client name on
>>> the server.  (all this in nfs-utils of course).
>> I took a look... and you are right it would not be that difficult to
>> hack something up... but would this only be a Linux to Linux thing? 
>> Or am I missing something?
> 
> There are four cases where translation can be done:
> 
> 	Sending id from server to client (ls, stat, getacl):
> 		1. server uid -> string
> 		2. string -> client uid
> 	Sending id from client to server (chown, setacl):
> 		3. client uid -> string
> 		4. string -> client uid
> 
> Cases 1 and 2 are uncontroversial.  Definitely map ascii-fied integers
> in both of those cases.
> 
> Case 4 violates the SHOULD on page 47.  Which would make case 3 useless
> if all servers respect that SHOULD.  I think we should ignore the SHOULD
> and implement 3 and 4 too, but Trond may not agree.

Is this something that should be taken up in 3530bis?

> I suppose we could make this all configurable, and then argue about what
> the defaults should be.  If we implement all this in idmapd then that's
> easy.
> 
> I don't know what other clients and servers do.  Probably 1 and 2 at
> least, but maybe it's something to check at the next bakeathon.
> 
> Do we actually use an @-less "nobody" as suggested in the last
> paragraph?  If not that might be something else to fix.
> 
> --b.
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com



