From: ed@sam-solutions.net (Ed V. Bartosh)
Subject: Re: NFS v.3 I18N
Date: 13 May 2002 19:10:04 +0300
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <85offk112b.fsf@pc213.belcaf.minsk.by>
References: <85offst0ou.fsf@pc213.belcaf.minsk.by>
	<shsk7qfhgmu.fsf@charged.uio.no>
	<85wuufq8wv.fsf@pc213.belcaf.minsk.by>
	<200205081746.54522.trond.myklebust@fys.uio.no>
	<857kmepoul.fsf@pc213.belcaf.minsk.by>
	<15578.35760.304321.857560@charged.uio.no>
	<85elgkm4bn.fsf@pc213.belcaf.minsk.by>
	<15582.50914.673194.830949@charged.uio.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from mail.belcaf.minsk.by ([217.21.35.41])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 177ISa-0002rt-00
	for <nfs@lists.sourceforge.net>; Mon, 13 May 2002 09:14:07 -0700
To: trond.myklebust@fys.uio.no
In-Reply-To: <15582.50914.673194.830949@charged.uio.no>
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


Hi, Trond!

/Sun, 12 May 2002 21:47:46 +0200/ you wrote:

 TM>> Exactly in what situation do the needs of an NFS exported
 TM>> system differ from that of your standard ext2/3 filesystem?

 >> In situation with different clients environments (OSes, for
 >> examle), which don't allow users to use standard Linux i18N
 >> functionality.

TM> Sure, but do you have a concrete example of a situation where this
TM> issue has been raised, and where a server-side solution was needed?

I have an example. Here it is:
I'm taking part in developing NAS software. It shares same files
through different file-sharing protocols: SMB, ATALK, NFS for wide range of
client platforms. It has Linux on server, of course.
How it can be possible to allow clients from different platforms and
different locales using their files with non-ASCII names ?
I think that server-side solution is more preferable in this case,
because we can't solve this problem on all possible client platforms.
Am I wrong ?

TM> Can't Windows NFS clients handle this sort of thing on their own (I
TM> really have no idea) and if they don't, has it ever been a problem?
In our situation this is really a problem.

-- 
Best regards,
Ed V. Bartosh

_______________________________________________________________

Have big pipes? SourceForge.net is looking for download mirrors. We supply
the hardware. You get the recognition. Email Us: bandwidth@sourceforge.net
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
