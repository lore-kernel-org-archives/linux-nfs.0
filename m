From: Marc Schmitt <mschmitt@inf.ethz.ch>
Subject: Re: nfs-utils 1.0.5 break amd?
Date: 05 Aug 2003 10:22:02 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1060071722.2980.74.camel@ikarus>
References: <1059672742.21271.58.camel@ikarus>
	<16169.55986.854984.818132@gargle.gargle.HOWL>
	<1060033126.1354.118.camel@localhost>
	<16175.4826.984307.413302@gargle.gargle.HOWL>
Mime-Version: 1.0
Content-Type: text/plain
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from medoc.inf.ethz.ch ([129.132.178.200])
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19jxOS-0006Nv-00
	for <nfs@lists.sourceforge.net>; Tue, 05 Aug 2003 01:42:09 -0700
To: Neil Brown <neilb@cse.unsw.edu.au>
In-Reply-To: <16175.4826.984307.413302@gargle.gargle.HOWL>
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

Well, again it's me confusing stuff.
With MOUNTD_TCP=no I thought I could prevent the clients from mounting
the server with NFS over tcp... which is something I already have,
because current RH kernels don't have NFS server support over TCP
enabled in the kernel.

Thanks for your time.

Greetings,
    Marc

On Tue, 2003-08-05 at 04:13, Neil Brown wrote:
> On  August 4, mschmitt@inf.ethz.ch wrote:
> > 
> > Now comes the interesting part, changing MOUNTD_TCP in
> > /etc/sysconfig/nfs from no to yes will make the problem go away. With
> > MOUNTD_TCP=yes I went up to 1000 exports and `showmount -e` worked fine.
> 
> Yes,  that makes sense.  UDP has a limited request/reply size.  TCP
> doesn't.
> 
> I honestly cannot think of any good reason to have MOUNTD_TCP=no  
> Maybe I should update the man page
>   
>        -n  or  --no-tcp
>               Don't advertise TCP for mount.
> 
>               NOTE: there is no good reason do use this option, and
> 	      if you do, then things will mysteriously break.
> 
> :-)
> NeilBrown
> 
> 
> -------------------------------------------------------
> This SF.Net email sponsored by: Free pre-built ASP.NET sites including
> Data Reports, E-commerce, Portals, and Forums are available now.
> Download today and enter to win an XBOX or Visual Studio .NET.
> http://aspnet.click-url.com/go/psa00100003ave/direct;at.aspnet_072303_01/01
> _______________________________________________
> NFS maillist  -  NFS@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/nfs




-------------------------------------------------------
This SF.Net email sponsored by: Free pre-built ASP.NET sites including
Data Reports, E-commerce, Portals, and Forums are available now.
Download today and enter to win an XBOX or Visual Studio .NET.
http://aspnet.click-url.com/go/psa00100003ave/direct;at.aspnet_072303_01/01
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
