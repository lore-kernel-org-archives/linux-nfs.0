From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: NFS v.3 I18N
Date: Wed, 8 May 2002 17:46:54 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <200205081746.54522.trond.myklebust@fys.uio.no>
References: <85offst0ou.fsf@pc213.belcaf.minsk.by> <shsk7qfhgmu.fsf@charged.uio.no> <85wuufq8wv.fsf@pc213.belcaf.minsk.by>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from mons.uio.no ([129.240.130.14])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 175Tey-0002hP-00
	for <nfs@lists.sourceforge.net>; Wed, 08 May 2002 08:47:21 -0700
To: ed@sam-solutions.net (Ed V. Bartosh)
In-Reply-To: <85wuufq8wv.fsf@pc213.belcaf.minsk.by>
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

On Onsdag 8. mai 2002 11:35, Ed V. Bartosh wrote:

> I'm talking about having ability to represent filenames and other NFS
> related strings i18n way, which allows clients with different
> languages works with NFS without problem.
> As I know this is the part of NFS v4 specification. Is it already
> implemented in any NFS4 projects ?

Hang on a bit here. You started by talking about NFSv3 and now you are onto 
NFSv4...

To clarify a bit here: NFSv2 and v3 do not specify any character encoding 
schemes, so it is pointless to do any NLS stuff for it: the protocol just 
doesn't offer any support for it.
(I was assuming you meant i18n string translations: this is what has been 
banned by Linus...)



NFSv4, OTOH, specifies the use of UTF-8 encoding in order to communicate 
between the client and the server.
If you want to help with NLS character conversion for NFSv4, then you should 
talk to the CITI people (see 
http://www.citi.umich.edu/projects/nfsv4/index.html) as they are responsible 
for that project. Please note though that most of the work has already been 
done: see the stuff in linux/fs/nls

Cheers,
  Trond

_______________________________________________________________

Have big pipes? SourceForge.net is looking for download mirrors. We supply
the hardware. You get the recognition. Email Us: bandwidth@sourceforge.net
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
