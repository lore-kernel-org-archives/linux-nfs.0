From: ed@sam-solutions.net (Ed V. Bartosh)
Subject: Re: NFS v.3 I18N
Date: 10 May 2002 18:05:00 +0300
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <85elgkm4bn.fsf@pc213.belcaf.minsk.by>
References: <85offst0ou.fsf@pc213.belcaf.minsk.by>
	<shsk7qfhgmu.fsf@charged.uio.no>
	<85wuufq8wv.fsf@pc213.belcaf.minsk.by>
	<200205081746.54522.trond.myklebust@fys.uio.no>
	<857kmepoul.fsf@pc213.belcaf.minsk.by>
	<15578.35760.304321.857560@charged.uio.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from mail.belcaf.minsk.by ([217.21.35.41])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 176C11-00026U-00
	for <nfs@lists.sourceforge.net>; Fri, 10 May 2002 08:09:04 -0700
To: trond.myklebust@fys.uio.no
In-Reply-To: <15578.35760.304321.857560@charged.uio.no>
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

/Thu, 9 May 2002 16:46:08 +0200/ you wrote:

 >> Is it so bad idea to have this functionality in NFSd ? Why ?
 >> Samba has it, for example.

TM> The question to ask when deciding whether or not to implement some
TM> functionality in the kernel is not 'why shouldn't we have it?', it is
TM> 'why do we need it?'

TM> Exactly in what situation do the needs of an NFS exported system
TM> differ from that of your standard ext2/3 filesystem?

In situation with different clients environments (OSes, for examle),
which don't allow users to use standard Linux i18N functionality.

-- 
Best regards,
Ed V. Bartosh

_______________________________________________________________

Have big pipes? SourceForge.net is looking for download mirrors. We supply
the hardware. You get the recognition. Email Us: bandwidth@sourceforge.net
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
