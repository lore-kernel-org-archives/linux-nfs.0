From: Dan Kegel <dkegel@ixiacom.com>
Subject: Re: rpc.rexd source for Linux?
Date: Mon, 21 Jul 2003 10:00:34 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <3F1C1C32.7090502@ixiacom.com>
References: <Pine.LNX.4.44.0307211511590.32628-100000@kenzo.iwr.uni-heidelberg.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: "'nfs@lists.sourceforge.net'" <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from 64-60-75-69.cust.telepacific.net ([64.60.75.69] helo=racerx.ixiacom.com)
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19ee4g-0006DM-00
	for <nfs@lists.sourceforge.net>; Mon, 21 Jul 2003 10:03:46 -0700
To: Bogdan Costescu <bogdan.costescu@iwr.uni-heidelberg.de>
In-Reply-To: <Pine.LNX.4.44.0307211511590.32628-100000@kenzo.iwr.uni-heidelberg.de>
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

Bogdan Costescu wrote:
> On Fri, 18 Jul 2003, Dan Kegel wrote:
> 
>>That got me thinking -- why not add that execve wrapper to Linux's
>>native NFS package?  Then I went looking, and discovered that 
>>(perhaps wisely) Linux's NFS package doesn't include 'on' or 'rpc.rexd'.
> 
> I don't follow your logic here. What has on/rpc.rexd to do with NFS ? 
> Sure, they are both supposed to use RPC as do lots of others (look in 
> /etc/rpc), but other than this ? So why bundle on with NFS ?

Two reasons:
1. they were part of Sun's original NFS
2. they are only useful if there's a distributed filesystem like NFS in use

But if y'all think those are too weak, then that's fine, it can stay
out of the NFS package.

The question remains - has anyone seen an open source implementation
of rpc.rexd?

Thanks,
Dan





-------------------------------------------------------
This SF.net email is sponsored by: VM Ware
With VMware you can run multiple operating systems on a single machine.
WITHOUT REBOOTING! Mix Linux / Windows / Novell virtual machines at the
same time. Free trial click here: http://www.vmware.com/wl/offer/345/0
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
