From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 0/8] XDR strings use an unsigned length
Date: Fri, 2 Nov 2007 18:06:07 -0400
Message-ID: <20071102220607.GO15595@fieldses.org>
References: <20071101205057.5503.90636.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: neilb@suse.de, nfs@lists.sourceforge.net,
	trond.myklebust@fys.uio.no
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Io4eh-0005sV-ON
	for nfs@lists.sourceforge.net; Fri, 02 Nov 2007 15:06:23 -0700
Received: from mail.fieldses.org ([66.93.2.214] helo=fieldses.org)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1Io4em-0006Hr-Rx
	for nfs@lists.sourceforge.net; Fri, 02 Nov 2007 15:06:25 -0700
In-Reply-To: <20071101205057.5503.90636.stgit@manray.1015granger.net>
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

On Thu, Nov 01, 2007 at 04:56:41PM -0400, Chuck Lever wrote:
> Hi Trond, Neil, Bruce...
> 
> The following patch series replaces
> 
>    [PATCH 06/27] SUNRPC: Fix xdr_decode_string_inplace() argument signage
> 
> which I posted last week.
> 
> XDR variable length strings use an unsigned length.  This patch series
> offers a series of clean ups to make the treatment of file names and path
> names in the NFS and NLM server consistent with the XDR specification and
> other areas of the NFS client.

I guess I'm a little worried about these patches.

It's not inherently a bug to store a length in an int.

So if the point is to track down the causes of signed/unsigned
comparison warnings, so that they stand out more in the future and draw
attention to particular bugs, that's fine.  But that's only helpful if
we do actually analyze each such case carefully to determine whether
there are bugs.

So, for example, if we're going to change the nfsd_lookup arguments to
take an unsigned int for a length, I'd be much reassured if that came
with an argument as to what exactly happens currently when we recieve a
"negative" length for the lookup argument off the wire.  Otherwise we're
defeating the purpose of these warnings, aren't we?

--b.

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
