From: Matt C <wago@phlinux.com>
Subject: Re: NFS attrib cache problems in 2.4.20 - 2.4.22-pre9
Date: Fri, 1 Aug 2003 09:34:36 -0700 (PDT)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.LNX.4.44.0308010930320.5261-100000@fubar.phlinux.com>
References: <shsel05dgke.fsf@charged.uio.no>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: NFS List <nfs@lists.sourceforge.net>, <cel@citi.umich.edu>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from fubar.phlinux.com ([216.254.54.154])
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19ics1-00061v-00
	for <nfs@lists.sourceforge.net>; Fri, 01 Aug 2003 09:35:09 -0700
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <shsel05dgke.fsf@charged.uio.no>
Errors-To: nfs-admin@lists.sourceforge.net
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

On 1 Aug 2003, Trond Myklebust wrote:

> >>>>> " " == Matt C <Matt> writes:
> 
>      > Hi NFS List, chuck, trond: I have a fun NFS problem with the
>      > recent 2.4 kernel NFS client. We have an application that is
>      > failing when it tries to move then open a file in very quick
>      > succession -- it fails because it can't find the file in the
>      > new location.
> 
> It's a known issue. mmap() writes appear to be screwed up
> w.r.t. truncate. I still don't have a proper solution for this
> problem since it appears to be more of a VM bug than a NFS one.
> 

Interesting. So the error condition you're describing would happen when we 
mmap() a file descriptor, then munmap() it followed by an ftruncate()? I 
guess I'm confused as to how this plays into the attribute cache (or if 
that's a red herring) since adding the 'noac' flag seems to make this 
problem go away.

Thanks for your help

-matt



-------------------------------------------------------
This SF.Net email sponsored by: Free pre-built ASP.NET sites including
Data Reports, E-commerce, Portals, and Forums are available now.
Download today and enter to win an XBOX or Visual Studio .NET.
http://aspnet.click-url.com/go/psa00100003ave/direct;at.aspnet_072303_01/01
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
