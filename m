From: Abhas Abhinav <abhas@deeproot.co.in>
Subject: Re: Error: RPC request reserved 244 but used 248
Date: Fri, 17 May 2002 15:27:07 +0000 (UTC)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.LNX.4.43.0205171519440.4556-100000@anubhav.lan.deeproot.co.in>
References: <15588.40700.328072.323813@notabene.cse.unsw.edu.au>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "nfs@lists.sourceforge.net" <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from [202.71.150.112] (helo=amogh.deeproot.co.in)
	by usw-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 178fEX-0005yY-00
	for <nfs@lists.sourceforge.net>; Fri, 17 May 2002 03:45:13 -0700
To: Neil Brown <neilb@cse.unsw.edu.au>
In-Reply-To: <15588.40700.328072.323813@notabene.cse.unsw.edu.au>
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

On Fri, 17 May 2002, Neil Brown wrote:

>--|> client and the server are running 2.4.8. The server uses ReiserFS for
                                     ^^^^^^^^^^
							This was "small" typo - it should've been
							2.4.18!

>--|It means that I can't count, and that the patch you have is a bit
>--|out-of-date.
>--|The latext -ac patch should work fine.
>--|
>--|I probably wont be putting out another complete NFS patch until 2.4.19
>--|comes out.

I patched the server kernel using the patch-Bd-NfsdAll for 2.4.18 that I
downloaded from cse.unsw.edu.au. So I guess I am using your latest
patches. The client was patched using 2.4.18 + Trond's NFS client
patch linux-2.4.18-NFS_ALL.dif. Other than that both the server and the
client were patched for reiserfs quota support (Chris Mason's patches).

All these patches were downloaded during the last 14 hours...

I am basically looking at test NFS-TCP support for a file server design
for a mail server. We're using reiserfs throughout.

Would the -ac tree be stable enough to experiment with this? And are
there any major advantages in using -ac tree or can I get away with
using 2.4.18-stable.

thanks for your help,
abhas.

-- 
-------------------------------------------------------------------
Abhas Abhinav		   | Free Software at its product-ive best.
CEO, DeepRoot Linux
http://www.deeproot.co.in           ---- Server Appliances ----
Ph: +91 (80) 856 5624          ---- Linux Support and Services ----
-------------------------------------------------------------------


_______________________________________________________________

Have big pipes? SourceForge.net is looking for download mirrors. We supply
the hardware. You get the recognition. Email Us: bandwidth@sourceforge.net
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
