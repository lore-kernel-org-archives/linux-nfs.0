From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: NFS v.3 I18N
Date: 07 May 2002 22:01:13 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <shsk7qfhgmu.fsf@charged.uio.no>
References: <85offst0ou.fsf@pc213.belcaf.minsk.by>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from mons.uio.no ([129.240.130.14])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 175B9O-0007Ic-00
	for <nfs@lists.sourceforge.net>; Tue, 07 May 2002 13:01:31 -0700
To: ed@sam-solutions.net (Ed V. Bartosh)
In-Reply-To: <85offst0ou.fsf@pc213.belcaf.minsk.by>
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

>>>>> " " == Ed V Bartosh <ed@sam-solutions.net> writes:

     > Hello, Can anyone tell me about NFS3 KNFSD I18N solutions ?  Is
     > it already implemented somewhere or may be somebody works on it
     > ?  Any ideas, explanations, links are welcome.

I presume you are talking about the supporting userland daemons
(mountd, statd, portmap...)?  Please note that Linus has banned any
i18n stuff in the kernel itself...

AFAIK, nobody has bothered yet, so if you are feeling like giving it a
shot, then by all means do...

Cheers,
  Trond

_______________________________________________________________

Have big pipes? SourceForge.net is looking for download mirrors. We supply
the hardware. You get the recognition. Email Us: bandwidth@sourceforge.net
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
