From: ed@sam-solutions.net (Ed V. Bartosh)
Subject: Re: NFS v.3 I18N
Date: 08 May 2002 12:35:28 +0300
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <85wuufq8wv.fsf@pc213.belcaf.minsk.by>
References: <85offst0ou.fsf@pc213.belcaf.minsk.by>
	<shsk7qfhgmu.fsf@charged.uio.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from mail.belcaf.minsk.by ([217.21.35.41])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 175O93-0007rc-00
	for <nfs@lists.sourceforge.net>; Wed, 08 May 2002 02:54:02 -0700
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <shsk7qfhgmu.fsf@charged.uio.no>
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

/07 May 2002 22:01:13 +0200/ you wrote:

 >> Hello, Can anyone tell me about NFS3 KNFSD I18N solutions ?  Is
 >> it already implemented somewhere or may be somebody works on it
 >> ?  Any ideas, explanations, links are welcome.

TM> I presume you are talking about the supporting userland daemons
TM> (mountd, statd, portmap...)?

I'm talking about having ability to represent filenames and other NFS
related strings i18n way, which allows clients with different
languages works with NFS without problem.
As I know this is the part of NFS v4 specification. Is it already implemented
in any NFS4 projects ?

TM> Please note that Linus has banned any i18n stuff in the kernel itself...


TM> AFAIK, nobody has bothered yet, so if you are feeling like giving it a
TM> shot, then by all means do...

I think it should be following scheme:
All strings should be translated from the client encoding to the
server one for incoming requests and in backward direction for
outgoing requests. If it's not possible to do it in the kernel then it
should be done at the userspace, right ? It can be implemented 
by open communication channel (pipe or so) between kernel and
userspace and passing data for recoding through it.
Answers could be returned to the kernel through the syscalls.
Also, as suggested Neil Brown, we need mechanism for suspended
rpc requests until we have result from the userspace. Without it
we will probably have kernel threads waiting for answers from
the userspace which is not acceptable.
As far as I know defered rpc requests mechanism was in Neil's
NFSD Auth patches. Last vesion of it I can find is there: 
http://cgi.cse.unsw.edu.au/~neilb/patches/linux/2.4.14/patch-R-NfsdAuthWIP2

I think that defered requests is important and useful mechanism
for kernel-userspace communication. Also it is the most difficult
part for implementing.
Is it already in 2.5 ? If so how difficult is to backport it to 2.4 ?
If it would be implemented that other parts of recoding will be done 
easily, I think.

What do you think about this, Trond ?
I need your feedback. Answer, please.

-- 
Best regards,
Ed V. Bartosh

_______________________________________________________________

Have big pipes? SourceForge.net is looking for download mirrors. We supply
the hardware. You get the recognition. Email Us: bandwidth@sourceforge.net
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
