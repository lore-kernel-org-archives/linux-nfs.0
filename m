From: Neil Brown <neilb@cse.unsw.edu.au>
Subject: Re: Error: RPC request reserved 244 but used 248
Date: Fri, 17 May 2002 21:13:38 +1000 (EST)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <15588.58850.316136.258030@notabene.cse.unsw.edu.au>
References: <15588.40700.328072.323813@notabene.cse.unsw.edu.au>
	<Pine.LNX.4.43.0205171519440.4556-100000@anubhav.lan.deeproot.co.in>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "nfs@lists.sourceforge.net" <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.28])
	by usw-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 178fgY-0007uO-00
	for <nfs@lists.sourceforge.net>; Fri, 17 May 2002 04:14:10 -0700
Received: From notabene ([129.94.242.45] == bartok.orchestra.cse.unsw.EDU.AU)
	(for <abhas@deeproot.co.in>) (for <nfs@lists.sourceforge.net>) By
	tone With Smtp ; Fri, 17 May 2002 21:13:58 +1000
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
> On Fri, 17 May 2002, Neil Brown wrote:
> 
> >--|> client and the server are running 2.4.8. The server uses ReiserFS for
>                                      ^^^^^^^^^^
> 							This was "small" typo - it should've been
> 							2.4.18!
> 
> >--|It means that I can't count, and that the patch you have is a bit
> >--|out-of-date.
> >--|The latext -ac patch should work fine.
> >--|
> >--|I probably wont be putting out another complete NFS patch until 2.4.19
> >--|comes out.
> 
> I patched the server kernel using the patch-Bd-NfsdAll for 2.4.18 that I
> downloaded from cse.unsw.edu.au. So I guess I am using your latest
> patches. The client was patched using 2.4.18 + Trond's NFS client
> patch linux-2.4.18-NFS_ALL.dif. Other than that both the server and the
> client were patched for reiserfs quota support (Chris Mason's patches).
> 
> All these patches were downloaded during the last 14 hours...

I think you don't understand how my patch repository works, which is
understandable, because it isn't really documented anywhere.

How it works is that every patch I create goes there somewhere.  From
time to time I might recommend particular patches on some mailing
list, or send particular patches to Linus/Alan/Marcelo for inclusion
into trees.
There is no attempt to keep a current 'best-of-breed' patch or to
guarantee correctness of any patches.

By using the patch you did you were doing the 'correct' thing in that
it is that latest one that I have publicly recommended.  However it is
not the latest patch... which is to say that I have not publicly
recommend any fixes that I have made, except by sending them to Alan.

But maybe I should....

On-top of that patch that you have, you could add:

http://www.cse.unsw.edu.au/~neilb/patches/linux-stable/2.4.19-pre3-ac1/patch-h-NfsdReserveFix
http://www.cse.unsw.edu.au/~neilb/patches/linux-stable/2.4.19-pre4-ac4/patch-A-NfsdSymolicSizes
http://www.cse.unsw.edu.au/~neilb/patches/linux-stable/2.4.19-pre7-ac1/patch-A-LockdTcpFix

plus this stanza:

--- ./fs/nfsd/export.c  2002/03/18 01:40:45     1.9
+++ ./fs/nfsd/export.c  2002/03/18 01:41:40     1.10
@@ -533,13 +506,15 @@
 
        for (hp = head; (tmp = *hp) != NULL; hp = &(tmp->h_next)) {
                if (tmp->h_addr.s_addr == addr) {
+#if 0
+/* this is not safe without BKL or some other spinlock */
                        /* Move client to the front */
                        if (head != hp) {
                                *hp = tmp->h_next;
                                tmp->h_next = *head;
                                *head = tmp;
                        }
-
+#endif
                        return tmp->h_client;
                }
        }

out of 
  http://www.cse.unsw.edu.au/~neilb/patches/linux-stable/2.4.19-pre3-ac1/patch-Q-NfsdLocksExplock

together these should bring you up-to-date...

Actually, there is another on.  I don't actually have a -stable patch
for it yet, but
http://www.cse.unsw.edu.au/~neilb/patches/linux-devel/2.5.15/patch-E-RpcDGRAMFix

should probably apply on-top of the others OK.

> 
> I am basically looking at test NFS-TCP support for a file server design
> for a mail server. We're using reiserfs throughout.

Well... Server support for NFS/TCP is very new, as you can probably
tell.  If you are happy to knit patches together, then go for it.

> 
> Would the -ac tree be stable enough to experiment with this? And are
> there any major advantages in using -ac tree or can I get away with
> using 2.4.18-stable.

I cannot comment on how stable -ac is, or what advantages it has,
other than the fact that all of the above are in it.

NeilBrown


> 
> thanks for your help,
> abhas.
> 
> -- 
> -------------------------------------------------------------------
> Abhas Abhinav		   | Free Software at its product-ive best.
> CEO, DeepRoot Linux
> http://www.deeproot.co.in           ---- Server Appliances ----
> Ph: +91 (80) 856 5624          ---- Linux Support and Services ----
> -------------------------------------------------------------------

_______________________________________________________________

Have big pipes? SourceForge.net is looking for download mirrors. We supply
the hardware. You get the recognition. Email Us: bandwidth@sourceforge.net
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
