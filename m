From: Neil Brown <neilb@cse.unsw.edu.au>
Subject: Re: Error: RPC request reserved 244 but used 248
Date: Fri, 17 May 2002 16:11:08 +1000 (EST)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <15588.40700.328072.323813@notabene.cse.unsw.edu.au>
References: <20020516153907.A23113@lucon.org>
	<Pine.LNX.4.43.0205170658200.3848-100000@anubhav.lan.deeproot.co.in>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "nfs@lists.sourceforge.net" <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.28])
	by usw-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 178axn-0004FM-00
	for <nfs@lists.sourceforge.net>; Thu, 16 May 2002 23:11:39 -0700
Received: From notabene ([129.94.242.45] == bartok.orchestra.cse.unsw.EDU.AU)
	(for <abhas@deeproot.co.in>) (for <nfs@lists.sourceforge.net>) By
	tone With Smtp ; Fri, 17 May 2002 16:11:27 +1000
To: Abhas Abhinav <abhas@deeproot.co.in>
In-Reply-To: message from Abhas Abhinav on Friday May 17
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

On Friday May 17, abhas@deeproot.co.in wrote:
> Hi...
> 
> I have been running nhfsstone on a tcp-mount NFS partition. Both the
> client and the server are running 2.4.8. The server uses ReiserFS for
> its disk partition. I've applied the respective nfs-tcp patches to the
> client and server... and was able to mount the nfs export using mount
> -otcp on the client...
> 
> However, during the test, the server kept giving the error:
> 
> RPC request reserved 244 but used 248
> 
> Any idea what this error could mean and how to stop it?

It means that I can't count, and that the patch you have is a bit
out-of-date.
The latext -ac patch should work fine.

I probably wont be putting out another complete NFS patch until 2.4.19
comes out.

NeilBrown

_______________________________________________________________

Have big pipes? SourceForge.net is looking for download mirrors. We supply
the hardware. You get the recognition. Email Us: bandwidth@sourceforge.net
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
