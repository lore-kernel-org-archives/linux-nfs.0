From: Neil Brown <neilb@cse.unsw.edu.au>
Subject: Re: RPC: TCP connect error 104!
Date: Fri, 3 May 2002 11:53:22 +1000 (EST)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <15569.60818.842967.989749@notabene.cse.unsw.edu.au>
References: <20020503003922.A403936F9@sitemail.everyone.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.28])
	by usw-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 173SGZ-0001xX-00
	for <nfs@lists.sourceforge.net>; Thu, 02 May 2002 18:53:48 -0700
Received: From notabene ([129.94.242.45] == bartok.orchestra.cse.unsw.EDU.AU)
	(for <croatia@firstlinux.net>) (for <nfs@lists.sourceforge.net>) By
	tone With Smtp ; Fri, 3 May 2002 11:53:34 +1000
To: croatia@firstlinux.net
In-Reply-To: message from Vladimir Vuksan on Thursday May 2
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

On Thursday May 2, croatia@firstlinux.net wrote:
> I am experiencing a problem on a number of different clients mounting NFS mounts over TCP. The error message showing up is
> 
> RPC: TCP connect error 104!
> 
> I searched through Google Groups and found following message
> 
> =========================================
> 
> http://www.geocrawler.com/mail/msg.php3?msg_id=8215374&list=789
> 
> You may need more threads to service the clients?  See Neil's notes
> that accompanied the patches (in the archives) w.r.t the number of threads and the number of RPC receive buffers.
> 
> ==========================================
> 
> I was wondering what is the easiest way to increase the number of
> threads. Most clients run RedHat's 2.4.9-31 kernel installed from an
> RPM. I also have a Rawhide kernel 2.4.18-0.12 that seems to exhibit
> same kind of behavior. 
>   

Just run rpc.nfsd and give it the number that you want.

  rpc.nfsd 32

will increase the number of threads to 32

  rpc.nfsd 128

will then increase it to 128.

If you find that has fixed the problem, the find the init.d script
that starts rpc.nfsd and change the number to whatever you want.

NeilBrown

_______________________________________________________________

Have big pipes? SourceForge.net is looking for download mirrors. We supply
the hardware. You get the recognition. Email Us: bandwidth@sourceforge.net
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
