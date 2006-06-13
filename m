From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: 2.4 vs 2.6
Date: Tue, 13 Jun 2006 16:42:25 -0400
Message-ID: <20060613204225.GB26315@fieldses.org>
References: <17526.44653.228663.713864@cse.unsw.edu.au>
	<20060526081905.73641.qmail@web51609.mail.yahoo.com>
	<20060526193118.GB17761@fieldses.org>
	<17530.36039.227704.325645@cse.unsw.edu.au>
	<20060529160236.GC6832@fieldses.org>
	<20060530011208.GB12818@sgi.com>
	<20060530015918.GA27940@fieldses.org>
	<17550.12582.742528.454837@cse.unsw.edu.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: mehta kiran <kiranmehta1981@yahoo.com>,
	Vijay Chauhan <kernel.vijay@gmail.com>, nfs@lists.sourceforge.net,
	Greg Banks <gnb@sgi.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-list2-b.sourceforge.net ([10.3.1.8]
	helo=sc8-sf-list2.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1FqFis-0002Nf-BH
	for nfs@lists.sourceforge.net; Tue, 13 Jun 2006 13:42:50 -0700
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1FqFis-0002zY-7k
	for nfs@lists.sourceforge.net; Tue, 13 Jun 2006 13:42:50 -0700
Received: from mail.fieldses.org ([66.93.2.214] helo=pickle.fieldses.org)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1FqFir-0003Fp-P5
	for nfs@lists.sourceforge.net; Tue, 13 Jun 2006 13:42:50 -0700
To: Neil Brown <neilb@suse.de>
In-Reply-To: <17550.12582.742528.454837@cse.unsw.edu.au>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

On Tue, Jun 13, 2006 at 01:29:42PM +1000, Neil Brown wrote:
> Having the mapping permanently in the kernel rather than filled in on
> demand would mean that:
> 
>  - the filesystem has to be mounted the whole time, and we cannot do
>    any on-demand mounting (based on fsid) - not that we currently do.
>    This is a fairly small point however.

Fair enough.

>    If a request arrives from a host which is in both 'somehosts' and
>    'otherhosts', then what name do you give to the kernel for that IP
>    address?
>    We currently say the IP address maps to 
>           @somehosts+@otherhosts
>    (or something like that) and then tell the kernel any of the
>    following as required:
>           /export1 @somehosts+@otherhosts  -> rw,root_squash
>           /export1 @somehosts  -> rw,root_squash
>           /export2 @somehosts+@otherhosts  -> ro,no_root_squash
>           /export2 @otherhosts  -> ro,no_root_squash

The kernel could of course just split these plus+separated+name+lists
itself before mapping to export options.  But I guess the point is that
in cases such as the above there's a policy decision that's better made
in userspace.  OK.

> Hopefully you can see that giving a full (path, client-name ) ->
> export mapping the kernel in advance is not practical.

Just to be clear--I'm definitely not on some crusade to change all this.
I'm just curious about the motivation for the design; thanks for the
explanation.

--b.


_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
