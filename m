From: Peter Gostelow <gostelow@global.co.za>
Subject: Re: nfs newbie, where to find portmapper?
Date: Mon, 25 Aug 2003 04:32:23 +0000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <200308250432.23739.gostelow@global.co.za>
References: <200308210452.06388.gostelow@global.co.za> <16199.6218.848334.275159@gargle.gargle.HOWL>
Reply-To: gostelow@global.co.za
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from ctb-mesg4.saix.net ([196.25.240.76])
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19r8sF-0000Iw-00
	for <nfs@lists.sourceforge.net>; Sun, 24 Aug 2003 21:22:36 -0700
To: Neil Brown <neilb@cse.unsw.edu.au>
In-Reply-To: <16199.6218.848334.275159@gargle.gargle.HOWL>
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

Thanks for the prompt reply, I got it working with the patch!

The portmap compiles with many (harmless) warnings, due mostly to the ancient 
code.

nfs worked first time over one ethernet link. Great job, guys. Other issues 
with the third host must be resolved before I can try nfs through the router/
bridge.

If anyone is interested, I'm converting the Debian portmap package to use 
configure and eliminating the warning messages. The bugs remain (and maybe 
new ones added) until I know a bit more about rpc.

nfs is really cool, thanks again :-)
Peter

On 23 August 2003 07:31, you wrote:
> On Thursday August 21, gostelow@global.co.za wrote:
> > Slightly off-topic, but I'm a bit stuck.
> >

<snip>

> > So, what portmapper are the nfs developers using and is there a source
> > tarball available for it?
>
> I use the one that comes with debian.  It works fine.
>
> Debian distribute a patch along with the tar-ball, and the patch
> presumable makes it compile with debian's libraries.
>
> NeilBrown



-------------------------------------------------------
This SF.net email is sponsored by: VM Ware
With VMware you can run multiple operating systems on a single machine.
WITHOUT REBOOTING! Mix Linux / Windows / Novell virtual machines
at the same time. Free trial click here:http://www.vmware.com/wl/offer/358/0
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
