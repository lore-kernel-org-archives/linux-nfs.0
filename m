From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [RFC,PATCH 14/35] svc: Change sk_inuse to a kref
Date: Wed, 3 Oct 2007 11:13:58 -0400
Message-ID: <50751C78-DD55-4549-A03E-2DFBBEF7AED3@oracle.com>
References: <20071001191426.3250.15371.stgit@dell3.ogc.int>
	<20071001192801.3250.49751.stgit@dell3.ogc.int>
	<20071003111210.GA19381@infradead.org>
	<20071003144517.GA10001@fieldses.org>
	<20071003145238.GA30564@infradead.org>
Mime-Version: 1.0 (Apple Message framework v752.2)
Content-Type: text/plain; charset="us-ascii"
Cc: "J. Bruce Fields" <bfields@fieldses.org>, neilb@suse.de,
	nfs@lists.sourceforge.net, gnb@sgi.com
To: Christoph Hellwig <hch@infradead.org>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Id62N-0004Qv-8P
	for nfs@lists.sourceforge.net; Wed, 03 Oct 2007 08:21:23 -0700
Received: from rgminet01.oracle.com ([148.87.113.118])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1Id62P-0008Pm-Me
	for nfs@lists.sourceforge.net; Wed, 03 Oct 2007 08:21:28 -0700
In-Reply-To: <20071003145238.GA30564@infradead.org>
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

On Oct 3, 2007, at 10:52 AM, Christoph Hellwig wrote:
> On Wed, Oct 03, 2007 at 10:45:17AM -0400, J. Bruce Fields wrote:
>> On Wed, Oct 03, 2007 at 12:12:10PM +0100, Christoph Hellwig wrote:
>>> On Mon, Oct 01, 2007 at 02:28:01PM -0500, Tom Tucker wrote:
>>>>
>>>> Change the atomic_t reference count to a kref and move it to the
>>>> transport indepenent svc_xprt structure. Change the reference count
>>>> wrapper names to be generic.
>>>
>>> Why?  krefs are a complete pain in the ass, and it's hard to avoid
>>> various races with them.
>>
>> So kref's are deprecated now?  What's the deal?  Is there a  
>> pointer to
>> discussion somewhere?
>
> The people that have introduced them as still playing fanboys for  
> them,
> but that doesn't make them any better idea.  I don't think they've  
> every
> been encouraged by lots of people.

Christoph, I think you are stating a personal preference here...

We're using krefs without issue in several other areas of the RPC  
client and server.  Both rpc_clnt and rpc_xprt have a kref in them,  
for example.  I don't see the harm in using them here as well, as  
long as they are used carefully.

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
