From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: NFS v.3 I18N
Date: Thu, 9 May 2002 16:46:08 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <15578.35760.304321.857560@charged.uio.no>
References: <85offst0ou.fsf@pc213.belcaf.minsk.by>
	<shsk7qfhgmu.fsf@charged.uio.no>
	<85wuufq8wv.fsf@pc213.belcaf.minsk.by>
	<200205081746.54522.trond.myklebust@fys.uio.no>
	<857kmepoul.fsf@pc213.belcaf.minsk.by>
Reply-To: trond.myklebust@fys.uio.no
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from mons.uio.no ([129.240.130.14])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 175pBU-0006VK-00
	for <nfs@lists.sourceforge.net>; Thu, 09 May 2002 07:46:20 -0700
To: ed@sam-solutions.net (Ed V. Bartosh)
In-Reply-To: <857kmepoul.fsf@pc213.belcaf.minsk.by>
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

    TM> To clarify a bit here: NFSv2 and v3 do not specify any
    TM> character encoding schemes, so it is pointless to do any NLS
    TM> stuff for it: the protocol just doesn't offer any support for
    TM> it.
     > I understand that. But I think it's possible to implement
     > charset translation for filenames and other strings not toching
     > NFS protocol, just on the server side. Info about used client
     > encodings may be given from some config file or as an
     > additional option in /etc/exports.

     > Is it so bad idea to have this functionality in NFSd ? Why ?
     > Samba has it, for example.

The question to ask when deciding whether or not to implement some
functionality in the kernel is not 'why shouldn't we have it?', it is
'why do we need it?'

Exactly in what situation do the needs of an NFS exported system
differ from that of your standard ext2/3 filesystem?

Cheers,
  Trond

_______________________________________________________________

Have big pipes? SourceForge.net is looking for download mirrors. We supply
the hardware. You get the recognition. Email Us: bandwidth@sourceforge.net
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
