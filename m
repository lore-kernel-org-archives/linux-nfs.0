From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH 0/8] XDR strings use an unsigned length
Date: Mon, 5 Nov 2007 12:40:07 -0500
Message-ID: <460EEDF5-3264-43FC-B15F-52ECA4C4BD7A@oracle.com>
References: <20071101205057.5503.90636.stgit@manray.1015granger.net>
	<20071102220607.GO15595@fieldses.org>
Mime-Version: 1.0 (Apple Message framework v752.2)
Content-Type: text/plain; charset="us-ascii"
Cc: neilb@suse.de, nfs@lists.sourceforge.net,
	trond.myklebust@fys.uio.no
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Ip5yO-0002ks-6J
	for nfs@lists.sourceforge.net; Mon, 05 Nov 2007 09:42:52 -0800
Received: from agminet01.oracle.com ([141.146.126.228])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1Ip5yR-00072B-Ha
	for nfs@lists.sourceforge.net; Mon, 05 Nov 2007 09:42:57 -0800
In-Reply-To: <20071102220607.GO15595@fieldses.org>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

On Nov 2, 2007, at 6:06 PM, J. Bruce Fields wrote:
> On Thu, Nov 01, 2007 at 04:56:41PM -0400, Chuck Lever wrote:
>> Hi Trond, Neil, Bruce...
>>
>> The following patch series replaces
>>
>>    [PATCH 06/27] SUNRPC: Fix xdr_decode_string_inplace() argument  
>> signage
>>
>> which I posted last week.
>>
>> XDR variable length strings use an unsigned length.  This patch  
>> series
>> offers a series of clean ups to make the treatment of file names  
>> and path
>> names in the NFS and NLM server consistent with the XDR  
>> specification and
>> other areas of the NFS client.
>
> I guess I'm a little worried about these patches.
>
> It's not inherently a bug to store a length in an int.

Do my patches suggest that it is a bug?  Most of the patch  
descriptions state that this work is a "clean up" effort, done to  
make all the XDR helpers handle object lengths in a way consistent  
with the protocol specifications and each other.

> So if the point is to track down the causes of signed/unsigned
> comparison warnings, so that they stand out more in the future and  
> draw
> attention to particular bugs, that's fine.

The point of this work is to help reduce the likelihood of  
introducing new bugs.  We do that by making the code more clear, by  
introducing specific coded checks about our assumptions, by making it  
possible to use our tool chain more effectively, and by providing  
documentation.

> But that's only helpful if
> we do actually analyze each such case carefully to determine whether
> there are bugs.

If I argue there are no bugs, the simple way to prove me wrong is to  
demonstrate a bug.

> So, for example, if we're going to change the nfsd_lookup arguments to
> take an unsigned int for a length, I'd be much reassured if that came
> with an argument as to what exactly happens currently when we  
> recieve a
> "negative" length for the lookup argument off the wire.

I refer you to protocol specs (they say "the length is always  
unsigned") and last week's thread on this list that discusses this  
very issue.

http://sourceforge.net/mailarchive/forum.php? 
thread_name=20071031165045.5861.52308.stgit%40manray. 
1015granger.net&forum_name=nfs

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com



-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
