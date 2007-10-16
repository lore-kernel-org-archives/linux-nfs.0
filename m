From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: Benchmarks: ACCESS RPCs, NOACLs, RHEL3 and RHEL4 Kernels
Date: Tue, 16 Oct 2007 12:30:12 -0400
Message-ID: <8D58CDF3-6940-4DCB-AC20-8523A3FA0C08@oracle.com>
References: <920746F6DF728345915EF4D6DA610D0F03F8E5D0@MAILSJ2.global.cadence.com>
Mime-Version: 1.0 (Apple Message framework v752.2)
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: "Jim Dennis" <jdennis@cadence.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IhpKD-0003oD-Ei
	for nfs@lists.sourceforge.net; Tue, 16 Oct 2007 09:31:21 -0700
Received: from rgminet01.oracle.com ([148.87.113.118])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IhpKG-00059G-0R
	for nfs@lists.sourceforge.net; Tue, 16 Oct 2007 09:31:25 -0700
In-Reply-To: <920746F6DF728345915EF4D6DA610D0F03F8E5D0@MAILSJ2.global.cadence.com>
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

On Oct 15, 2007, at 3:14 PM, Jim Dennis wrote:
>  I've been tasked with performing some benchmarks to measure the  
> effect
> of using the NOACL option
>  on RHEL3, RHEL4, RHEL5, and SLES10  NFS clients (mostly accessing
> NetApps filers).
>
>  Apparently in the 2.4.21-* (RHEL3) kernels there was a bug  
> relating to
> caching of the results of ACCESS
>  RPCs.  A side effect of this issue is an apparent performance gain  
> when
> one uses the NOACL mount
>  option.
>
>  This is apparently still the case as of RHEL3 update 8 (fixed in  
> update
> 9???).  Here's an old e-mail
>  reference:
>
> http://acl.bestbits.at/pipermail/acl-devel/2002-September/001158.html
>
> Don't know how closely this relates to this following:
>
>     CVE-2007-0004
>
>     The NFS client implementation in the kernel in Red Hat Enterprise
> Linux (RHEL) 3, when
>     a filesystem is mounted with the noacl option, checks permissions
> for the open system
>     call via vfs_permission (mode bits) data rather than an NFS ACCESS
> call to the server,
>     which allows local client processes to obtain a false success  
> status
> from open calls that
>     the server would deny, and possibly obtain sensitive information
> about file permissions on
>     the server, as demonstrated in a root_squash environment.   
> NOTE: it
> is uncertain whether
>     any scenarios involving this issue cross privilege boundaries.
>
>  ... but we're unconcerned about the security implications in any  
> event.
> (These particular compute
>  clusters are limited to filers on which only the UNIX permissions  
> apply
> --- we don't put any ACLs
>  in these file trees.
>
>  I'm aware that the stock vendor kernels for RHEL4 and later do not
> support the NOACL option; and
>  I'm also aware of simple patches which allow us to re-introduce the
> support.  Part of my task is
>  to test the effects of those patches.
>
>  Questions I have:
>
>     * Has anyone published test results related to this?
>     * Any suggestions on the best performance testing (benchmarking)
> methodology?
>         * (In particular for measuing the specific effects of the RPC
> ACCESS and any other
> 	     ACL related overhead?)
> 	  * Comments on fstress? (http://www.cs.duke.edu/ari/fstress/)
> 	  * Other tools/suites?
>     * Any caveats about unintended consequences or risks associated  
> with
> disabling ACL checks
> 	on the client side?

Hi Jim-

When I was at NetApp we worked on this problem in all of these  
distributions.

My impression of fstress is that it is a read/write benchmark, thus  
it won't generate a lot of access traffic in any event.

A software build workload is going to be much more impacted by excess  
ACCESS requests.  When we investigated this issue, our customers used  
multi-client software build workloads, and evaluated the results  
based on the wall clock time for a cold and warm cache run of a full  
build.

The community choice to address this issue was to improve the NFS  
client's ability to cache the results of ACCESS requests rather than  
to continue to allow administrators to disable ACCESS checking.   
Disabling ACCESS checking was really a side-effect of "noacl" -- it's  
true purpose was to prevent the client from sending ACL requests to  
servers that don't support NFSv3 ACLs.

As a result of these improvements, the RHEL 5 NFS client should have  
very good ACCESS result caching behavior.

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
