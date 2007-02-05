From: Neil Brown <neilb@suse.de>
Subject: Re: [PATCH] Update README
Date: Mon, 5 Feb 2007 14:10:12 +1100
Message-ID: <17862.40980.246111.403067@notabene.brown>
References: <20070201173847.GA26741@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HDuFl-0001aR-Vm
	for nfs@lists.sourceforge.net; Sun, 04 Feb 2007 19:10:50 -0800
Received: from ns2.suse.de ([195.135.220.15] helo=mx2.suse.de)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HDuFl-0005MZ-J4
	for nfs@lists.sourceforge.net; Sun, 04 Feb 2007 19:10:51 -0800
In-Reply-To: message from J. Bruce Fields on Thursday February 1
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

On Thursday February 1, bfields@fieldses.org wrote:
> The README has bit-rotted: redhat and debian packaging scripts are no
> longer included, util-linux mount is (in theory) no longer required, and
> instructions on building from latest git would be useful.

Thanks.

> 
> I'm autotool-clueless and have no clue about the "ltmain.sh" thing
> mentioned in the last section; I just followed the bootstrapping
> instructions in the commit message for 922d6cfd and found I needed a
> copy of ltmain.sh to make it work.

I just run
   ./autogen.sh

works every time... I might change that in the README.

NeilBrown

> -4. REQUIRED VERSIONS OF OTHER TOOLS
> -
> -Proper NFS operation requires a 'mount' program from util-linux 2.11f
> -or later.
> +	aclocal -I aclocal
> +	autoheader
> +	automake
> +	autoconf
>  
> +You may also need to copy ltmain.sh to the current directory if the
> +above doesn't do that.  Usually there's a copy in
> +/usr/share/libtool/ltmain.sh.  Finally, build as usual as above.
>  
>  Share And Enjoy!
>  
>      --	the nfs-utils developers
>  	<nfs@lists.sourceforge.net>
> -	26 Dec 2001
> -
> -- 
> 1.5.0.rc1.g72fe

-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier.
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
