From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: mount.nfs: access denied by server
Date: Fri, 21 Aug 2009 16:04:03 -0400
Message-ID: <20090821200403.GA23529@fieldses.org>
References: <1250822171.6514.29.camel@heimdal.trondhjem.org> <BAE89B4F-CA8C-46B2-82EA-9BAA438C1DF7@oracle.com> <20090821182418.GE21043@fieldses.org> <31F3372A-891E-44EF-8DD2-78D5A3AD5CF1@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>,
	NFS list <linux-nfs@vger.kernel.org>,
	Tom Haynes <Thomas.Haynes-UdXhSnd/wVw@public.gmane.org>
To: Chuck Lever <Chuck.Lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:58111 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932123AbZHUUEG (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 21 Aug 2009 16:04:06 -0400
In-Reply-To: <31F3372A-891E-44EF-8DD2-78D5A3AD5CF1@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Aug 21, 2009 at 02:46:28PM -0400, Chuck Lever wrote:
> On Aug 21, 2009, at 2:24 PM, J. Bruce Fields wrote:
>> On Fri, Aug 21, 2009 at 02:16:08PM -0400, Chuck Lever wrote:
>>> I want to understand the server bug a little more.  I glanced over  
>>> RFC
>>> 2623 and didn't see anything specific.
>>>
>>> Is it the case that only Linux NFSD does this, or do other servers do
>>> it?  In other words, is this a typical server response, and if so, is
>>> there a specific semantic attached to it?
>>>
>>> If no list is provided, should the client assume that only AUTH_NONE 
>>> and
>>> AUTH_SYS are supported, or instead, perhaps that the client can try  
>>> to
>>> use any flavor?  In other words, if no list is provided, let the  
>>> mount
>>> proceed no matter what was specified by sec= ?
>>
>> I think the safest behavior on the client would be something like:
>>
>> 	- If an explicit sec= is provided on the client, try that
>> 	  flavor.  Otherwise:
>> 		- If the server returned a nonempty list, pick something
>> 		  off that list.  Otherwise:
>> 		  	- Try auth_sys.
>
> Right now, we use AUTH_SYS if the mount command didn't specify a flavor, 
> but the flavor we're going to use is always checked against the server's 
> returned list.  You seem to be suggesting we should ignore the server's 
> list entirely if sec= was specified...?

Yes.  I can't see what practical problems that would cause.

Also, while I hope this is the last bug in the mountd's flavor list
return, it isn't the first--only recently did we even start using real
information from the export instead of just faking something up.  So I
think it's safest to preserve the historical sec= behavior and give
users a way to override the negotiation, to cut down on bug reports of
mount failures on upgrade.

--b.
