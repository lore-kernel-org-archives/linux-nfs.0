From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: rpc.mountd crashes when extensively using netgroups
Date: Tue, 31 Jul 2007 10:48:24 -0400
Message-ID: <20070731144824.GA15231@fieldses.org>
References: <46ADDFB2.9070709@inf.ethz.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net, linux-kernel@vger.kernel.org
To: Stefan Walter <stefan.walter@inf.ethz.ch>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IFt1R-00061H-SJ
	for nfs@lists.sourceforge.net; Tue, 31 Jul 2007 07:48:30 -0700
Received: from mail.fieldses.org ([66.93.2.214] helo=fieldses.org)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IFt1U-0004XN-JW
	for nfs@lists.sourceforge.net; Tue, 31 Jul 2007 07:48:33 -0700
In-Reply-To: <46ADDFB2.9070709@inf.ethz.ch>
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

On Mon, Jul 30, 2007 at 02:55:14PM +0200, Stefan Walter wrote:
> There are however two issues for which we could not find an easy
> solution:
> 
>  1. For every client rpc.mountd and the kernel seem to exchange
>     and use lists with _all_ netgroups used in exports that are
>     relevant for granting permission to some share for a particular
>     client. We could imagine two optimizations here:
> 
>        * Resolve netgroups and only put the (member) netgroups that
>          contained the host name that would be used to authorize
>          a mount in the list.
> 
>        * Use the list of mounted paths per client and only put the
>          netgroup(s) used to export paths that are actually mounted
>          on a client. 
> 
>     This also caused us severe performance problems because
>     rpc.mountd queries all these netgroups. We were initially using
>     a LDAP and mouting a directory took up to ten seconds
>     during which rpc.mountd was busily querying the LDAP server.
>     We got this down to two seconds using file based netgroups.
>  
>  2. Using a fixed size for NFSCLNT_IDMAX does not scale. Mounting
>     shares on a client for which the 'if' clause of the quick fix
>     becomes true will not be possible. We thought about enlarging
>     NFSCLNT_IDMAX and using a custom kernel but dropped the idea. 
> 
> Our ultimate goal is to get Red Hat fix the code in nfs-utils 1.0.6
> that is used in RHEL4. A first step would be to get a suitable fix in
> the current nfs-utils. 

That's an interesting problem.  Thanks for the report!

I don't believe that long comma-delimited string actually has any
meaning to the kernel--as far as the kernel is concerned, it's just an
opaque object that will be passed back to mountd later (along with a
path name) to get export options.

So I suppose that string could be replaced by a hash, or maybe even just
by the ip address of the particular host--the disadvantage to the latter
being that it would require the kernel to keep a separate export for
each client address.

--b.

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
