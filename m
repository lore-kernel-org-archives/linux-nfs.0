From: James Pearson <james-p@moving-picture.com>
Subject: Re: kernel version problem
Date: Fri, 15 Mar 2002 10:17:01 +0000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <3C91CA1D.9F779A29@moving-picture.com>
References: <DAV20GvQ3C3unebhJHa0000ed31@hotmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Received: from mpc-26.sohonet.co.uk ([193.203.82.251] helo=moving-picture.com)
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 16lolt-0001vQ-00
	for <nfs@lists.sourceforge.net>; Fri, 15 Mar 2002 02:17:13 -0800
To: Tina Arora <tinaarora@hotmail.com>
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
List-Archive: <http://www.geocrawler.com/redir-sf.php3?list=nfs>

> Tina Arora wrote:
> 
> hi,
> nfs.soureforge.net talks of kernel version atleast 2.2.18 to use nfs
> version 3 .My system shows
> "Red Hat Linux release 7.0(Guinness)
>  Kernel 2.2.16-22 on i686"
> Nebody ne clues what this -22 means and also will i be able to use nfs
> (3) on this system of mine..
> thanx
> Tina

If you don't want to build your own kernel, then there are a couple of
things you could do:

Upgrade to RedHat 7.2 - which has a 2.4.X kernel plus everything else
you need to use NFSv3.

If you can't upgrade to RedHat 7.2, then the latest RedHat update kernel
for RedHat 7.0 is 2.2.19-7.0.15. I have no idea if this kernel does
support NFSv3, but I guess it does. (RedHat make a number of
additions/modifications to a standard kernel - the number after the '-'
is added by RedHat and probably means something like the 15th build of a
RH kernel based on 2.2.19 for RH 7.0). Download from:

ftp://updates.redhat.com/7.0/en/os/i686/

The RedHat support site should have instructions on how to upgrade a RH
kernel.

You will probably still have to update the nfs-utils (and mount?) as per
the FAQ.

James Pearson

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
