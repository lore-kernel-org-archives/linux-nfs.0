From: Neil Brown <neilb@cse.unsw.edu.au>
Subject: Re: "kernel: nfsd: request from insecure port"
Date: Sun, 3 Aug 2003 14:11:18 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <16172.35686.238087.808956@gargle.gargle.HOWL>
References: <0806DAA43B1555479D53B58675D346831DB8E3@xrose01.rose.hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "'nfs@lists.sourceforge.net'" <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19jADV-0007kV-00
	for <nfs@lists.sourceforge.net>; Sat, 02 Aug 2003 21:11:33 -0700
Received: From notabene ([129.94.242.45] == bartok.orchestra.cse.unsw.EDU.AU)
	(for <stuart.cedrone@hp.com>) (for <nfs@lists.sourceforge.net>) By
	note With Smtp ; Sun, 3 Aug 2003 14:11:27 +1000
To: "CEDRONE,STUART (HP-USA,ex2)" <stuart.cedrone@hp.com>
In-Reply-To: message from CEDRONE,STUART (HP-USA,ex2) on Friday August 1
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

On Friday August 1, stuart.cedrone@hp.com wrote:
>  
> 
> If an HP-UX 11.00 or later client NFS mounts a filesystem exported from a
> Linux server and attempts to lock files, the following things happen: (1)
> The locks fail (2) The linux server logs messages such as "<datestamp>
> kernel: nfsd: request from insecure port" in /var/log/messages (3) sooner or
> later, the kernel on the Linux NFS server will hang or panic. 
> 
> Is this a known issue with Linux NFS servers?
> 

1+2  I'm guessing HP-UX makes lock requests from insecure ports (I
know other OSes do).  You need the insecure_lock export option for
this to be allowed.

3.  Don't know about this.  I would need more details.

NeilBrown


-------------------------------------------------------
This SF.Net email sponsored by: Free pre-built ASP.NET sites including
Data Reports, E-commerce, Portals, and Forums are available now.
Download today and enter to win an XBOX or Visual Studio .NET.
http://aspnet.click-url.com/go/psa00100003ave/direct;at.aspnet_072303_01/01
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
