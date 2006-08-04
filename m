From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH 3/4] Add /proc/sys/fs/nfs sysctls to nfsd module
Date: Fri, 04 Aug 2006 14:23:26 -0400
Message-ID: <1154715807.4727.30.camel@localhost>
References: <20060803110538.GA17173@suse.de>
	<76bd70e30608030952p15e1500cy191b5ef19241b58e@mail.gmail.com>
	<1154680981.21040.2415.camel@hole.melbourne.sgi.com>
	<1154705797.4727.18.camel@localhost> <20060804175232.GA29852@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Chuck Lever <chucklever@gmail.com>,
	Linux NFS Mailing List <nfs@lists.sourceforge.net>,
	Greg Banks <gnb@melbourne.sgi.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1G94Kw-0001SE-JD
	for nfs@lists.sourceforge.net; Fri, 04 Aug 2006 11:23:54 -0700
Received: from pat.uio.no ([129.240.10.4] ident=7411)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1G94Kv-00056N-P1
	for nfs@lists.sourceforge.net; Fri, 04 Aug 2006 11:23:55 -0700
To: Olaf Kirch <okir@suse.de>
In-Reply-To: <20060804175232.GA29852@suse.de>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

On Fri, 2006-08-04 at 19:52 +0200, Olaf Kirch wrote:
> On Fri, Aug 04, 2006 at 11:36:37AM -0400, Trond Myklebust wrote:
> > Not really. It would be better to identify and fix the buggy clients
> > that aren't setting the READDIRPLUS maxcount parameter correctly.
> 
> One of them was Solaris 9, IIRC. Don't recall what the other one was.
> I contacted at least Sun, but that didn't go anywhere.

Yeah.... Solaris appears to have a warped design in their READDIR code.
They want to specify one size for the actual READDIR reply, and one size
for all the extra READDIRPLUS gunk (see pages 209 and 210 in Brent's
'NFS Illustrated').
In their case, you want to look at the 'dircount' parameter, and
truncate the readdirplus reply when you hit 'dircount' bytes of filename
+fileid information. After that, you have to look at the total XDR
information, and truncate again when you hit 'maxcount' bytes.

Sucks, sucks, sucks....

Trond


-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys -- and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
