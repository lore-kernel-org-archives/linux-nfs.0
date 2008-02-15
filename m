From: Steve Dickson <SteveD@redhat.com>
Subject: Re: location of headers under /usr/include/tirpc
Date: Fri, 15 Feb 2008 12:46:22 -0500
Message-ID: <47B5CFEE.2020502@RedHat.com>
References: <5761C623-763A-4B2C-8536-96B1989C162F@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: NFS list <linux-nfs@vger.kernel.org>
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:55898 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755640AbYBORqg (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 15 Feb 2008 12:46:36 -0500
In-Reply-To: <5761C623-763A-4B2C-8536-96B1989C162F@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



Chuck Lever wrote:
> Hi Steve-
> 
> I think libtirpc-devel installs the tirpc headers in the wrong place. 
> The #include directives in the headers themselves expect them to appear
> under /usr/include, not under /usr/include/tirpc, so my builds fail when
> trying to include these headers.
> 
> For example, /usr/include/tirpc/rpc/rpcb_clnt.h does a "#include
> <rpc/rpcb_prot.h>" -- and the build chokes because that header is
> actually in /usr/include/tirpc/rpc/rpcb_prot.h.
> 
> Now, I can probably fix this temporarily by adding "-I
> /usr/include/tirpc" to my build.  However:
> 
> 1.  On Solaris, these all appear under /usr/include, there is no
> /usr/include/tirpc.
> 
> 2.  libtirpc-devel installs a bunch of files that already exist, such as
> /usr/include/rpc/auth.h, in /usr/include/tirpc/rpc/auth.h.
> 
> It would be cleaner to have one place for nfs-utils to look for these
> headers, so I don't want to permanently add "-I /usr/include/tirpc" or
> autoconf magic to find the right path unless we decide
> /usr/include/tirpc is the final location for these files.
> 
> So I think applications in general will expect to find these under
> /usr/include, not under /usr/include/tirpc.
> 
> Comments?
Its not clear what we can do. We just can't replace the file 
under /usr/include with the tirpc since that would break other
RPC applications. 

So what I think needs to happens, is I need to create 
a libtirpc.pc file that will live in /usr/lib/pkgconfig/  so you 
can used things like 
    pkg-config --libs libtirpc and pkg-config --cflags libgssglue

similar to how the librpcsecgss.pc and libgssglue.pc work

steved.


a 
> 
> -- 
> Chuck Lever
> chuck[dot]lever[at]oracle[dot]com
