From: Bogdan Costescu <bogdan.costescu@iwr.uni-heidelberg.de>
Subject: Re: rpc.rexd source for Linux?
Date: Mon, 21 Jul 2003 15:21:54 +0200 (CEST)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.LNX.4.44.0307211511590.32628-100000@kenzo.iwr.uni-heidelberg.de>
References: <15FDCE057B48784C80836803AE3598D53B8CDB@racerx.ixiacom.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "'nfs@lists.sourceforge.net'" <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from mail.iwr.uni-heidelberg.de ([129.206.104.30])
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19eacA-0002Jn-00
	for <nfs@lists.sourceforge.net>; Mon, 21 Jul 2003 06:22:06 -0700
To: Dan Kegel <dkegel@ixiacom.com>
In-Reply-To: <15FDCE057B48784C80836803AE3598D53B8CDB@racerx.ixiacom.com>
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

On Fri, 18 Jul 2003, Dan Kegel wrote:

> That got me thinking -- why not add that execve wrapper to Linux's
> native NFS package?  Then I went looking, and discovered that 
> (perhaps wisely) Linux's NFS package doesn't include 'on' or 'rpc.rexd'.

I don't follow your logic here. What has on/rpc.rexd to do with NFS ? 
Sure, they are both supposed to use RPC as do lots of others (look in 
/etc/rpc), but other than this ? So why bundle on with NFS ?

-- 
Bogdan Costescu

IWR - Interdisziplinaeres Zentrum fuer Wissenschaftliches Rechnen
Universitaet Heidelberg, INF 368, D-69120 Heidelberg, GERMANY
Telephone: +49 6221 54 8869, Telefax: +49 6221 54 8868
E-mail: Bogdan.Costescu@IWR.Uni-Heidelberg.De



-------------------------------------------------------
This SF.net email is sponsored by: VM Ware
With VMware you can run multiple operating systems on a single machine.
WITHOUT REBOOTING! Mix Linux / Windows / Novell virtual machines at the
same time. Free trial click here: http://www.vmware.com/wl/offer/345/0
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
