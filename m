From: ed@sam-solutions.net (Ed V. Bartosh)
Subject: Re: NFS v.3 I18N
Date: 08 May 2002 19:48:50 +0300
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <857kmepoul.fsf@pc213.belcaf.minsk.by>
References: <85offst0ou.fsf@pc213.belcaf.minsk.by>
	<shsk7qfhgmu.fsf@charged.uio.no>
	<85wuufq8wv.fsf@pc213.belcaf.minsk.by>
	<200205081746.54522.trond.myklebust@fys.uio.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from mail.belcaf.minsk.by ([217.21.35.41])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 175Uki-0000rT-00
	for <nfs@lists.sourceforge.net>; Wed, 08 May 2002 09:57:21 -0700
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <200205081746.54522.trond.myklebust@fys.uio.no>
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

/Wed, 8 May 2002 17:46:54 +0200/ you wrote:

 >> I'm talking about having ability to represent filenames and other NFS
 >> related strings i18n way, which allows clients with different
 >> languages works with NFS without problem.
 >> As I know this is the part of NFS v4 specification. Is it already
 >> implemented in any NFS4 projects ?

TM> Hang on a bit here. You started by talking about NFSv3 and now you are onto 
TM> NFSv4...
Sorry for misunderstanding. I mentioned NFSv4, but I need that for
NFSv3, as I said in the 1st message. I've just thought that if this
kind of stuff is already implemented in NFSv4 project that may helps.
Now I see that I was wrong, sorry.

TM> To clarify a bit here: NFSv2 and v3 do not specify any character encoding 
TM> schemes, so it is pointless to do any NLS stuff for it: the protocol just 
TM> doesn't offer any support for it.
I understand that. But I think it's possible to implement charset
translation for filenames and other strings not toching NFS protocol,
just on the server side. Info about used client encodings may be given
from some config file or as an additional option in /etc/exports.

Is it so bad idea to have this functionality in NFSd ? Why ?
Samba has it, for example.

TM> (I was assuming you meant i18n string translations: this is what has been 
TM> banned by Linus...)
Yes, it is i18n string translation. 
But I think it shouldn't be in the kernel, I was going to implement it
in the user space, using iconv, look at my prev. message, please. I
tried to explain how I plan to do that. I need your feedback
especially regarding defered requests.

TM> NFSv4, OTOH, specifies the use of UTF-8 encoding in order to communicate 
TM> between the client and the server.
TM> If you want to help with NLS character conversion for NFSv4, then you should 
TM> talk to the CITI people (see 
TM> http://www.citi.umich.edu/projects/nfsv4/index.html) as they are responsible 
TM> for that project. 
Thank you for the info, but I want to implement that for 2.4 knfsd.

Answer, please, Trond. What do you think about that ?

-- 
Best regards,
Ed V. Bartosh

_______________________________________________________________

Have big pipes? SourceForge.net is looking for download mirrors. We supply
the hardware. You get the recognition. Email Us: bandwidth@sourceforge.net
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
