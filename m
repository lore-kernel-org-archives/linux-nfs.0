From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [repost] Another NFS related oops on smp servers
Date: 03 Feb 2003 21:47:06 +0100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <shsvg015bxx.fsf@charged.uio.no>
References: <E18fkq3-000DC8-00@f10.mail.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from mons.uio.no ([129.240.130.14] ident=7411)
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18fnUp-0004Q7-00
	for <nfs@lists.sourceforge.net>; Mon, 03 Feb 2003 12:47:15 -0800
To: "Peter Lojkin" <ia6432@inbox.ru>
In-Reply-To: <E18fkq3-000DC8-00@f10.mail.ru>
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

>>>>> " " == Peter Lojkin <ia6432@inbox.ru> writes:

     > Hello, i got no answer for original message (lost in holidays
     > spam probably) so i'm reposting it (we got another such oops
     > this sunday):

     > -----Original Message----- From: "Peter Lojkin"
     > <ia6432@inbox.ru> To: nfs@lists.sourceforge.net Date: Thu, 26
     > Dec 2002 17:48:03 +0300 Subject: [NFS] Another NFS related oops
     > on smp servers

    >>
    >> Hello,
    >>
    >> we had 3 nfs related oopses on our servers in 2 days. such
    >> oopses never happened before. the kernel on oopsed servers is
    >> basically 2.4.20aa1 + trond's waitq fix. one of the oopsed
    >> servers had also trond's fix for another our oops problem,
    >> discussed earlier.  the setup is:

I suggest you first try to reproduce that Oops on a stock kernel from
ftp.kernel.org: 2.4.20aa1 is very unlikely to be used by too many of
the developers (I certainly don't use it).

Cheers,
  Trond


-------------------------------------------------------
This SF.NET email is sponsored by:
SourceForge Enterprise Edition + IBM + LinuxWorld = Something 2 See!
http://www.vasoftware.com
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
