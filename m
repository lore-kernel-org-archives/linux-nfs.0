From: Neil Brown <neilb@cse.unsw.edu.au>
Subject: Re: RPC request error message
Date: Thu, 25 Apr 2002 09:00:59 +1000 (EST)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <15559.14635.757201.643753@notabene.cse.unsw.edu.au>
References: <3CC6C5AD.3048F8D6@amis.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "nfs@lists.sourceforge.net" <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.28])
	by usw-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 170Vi2-000837-00
	for <nfs@lists.sourceforge.net>; Wed, 24 Apr 2002 15:57:58 -0700
Received: From notabene ([129.94.242.45] == bartok.orchestra.cse.unsw.EDU.AU)
	(for <ewhiting@amis.com>) (for <nfs@lists.sourceforge.net>) By tone
	With Smtp ; Thu, 25 Apr 2002 08:57:46 +1000
To: Eric Whiting <ewhiting@amis.com>
In-Reply-To: message from Eric Whiting on Wednesday April 24
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

On Wednesday April 24, ewhiting@amis.com wrote:
> 
> Apr 24 06:16:08 windriver kernel: RPC request reserved 240 but used 244
> Apr 24 06:17:58 windriver kernel: RPC request reserved 240 but used 244
> Apr 24 06:17:58 windriver kernel: RPC request reserved 52 but used 56
> Apr 24 06:34:35 windriver kernel: RPC request reserved 240 but used 244
> Apr 24 06:34:35 windriver kernel: RPC request reserved 52 but used 56
> 
> 
> 
> I get about 50-200 of these messages each day. Kernel is 2.4.18. 

Shouldn't be in 2.4.18.  They should only be in -ac patches.
I'm fairly sure that the latest -ac gets all the numbers right.

Exactly what kernel are you running?

NeilBrown

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
