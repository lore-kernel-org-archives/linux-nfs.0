From: "Brandon D. Valentine" <brandon@dvalentine.com>
Subject: Re: [bug] FC2/2.6.8.1 does not fallback to NFSv2
Date: Sat, 28 Aug 2004 01:29:59 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20040828062959.GA68499@brandon.dvalentine.com>
References: <20040827212244.GA57703@brandon.dvalentine.com> <1093642565.5758.108.camel@lade.trondhjem.org> <1093643490.5758.120.camel@lade.trondhjem.org> <20040827233235.GB57703@brandon.dvalentine.com> <20040827233431.GC57703@brandon.dvalentine.com> <1093671305.6028.46.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1C0wjO-00061F-Eb
	for nfs@lists.sourceforge.net; Fri, 27 Aug 2004 23:30:30 -0700
Received: from mail.michaelchaney.com ([207.65.84.68] helo=daphne.michaelchaney.com)
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.34)
	id 1C0wjN-0005Wn-22
	for nfs@lists.sourceforge.net; Fri, 27 Aug 2004 23:30:30 -0700
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <1093671305.6028.46.camel@lade.trondhjem.org>
Errors-To: nfs-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

On Sat, Aug 28, 2004 at 01:35:05AM -0400, Trond Myklebust wrote:
> P? fr , 27/08/2004 klokka 19:34, skreiv Brandon D. Valentine:
> > And of course I didn't actually attach the strace output file so here it
> > comes.  Sorry for the extra message.
> 
> It all looks OK, apart from the fact that the mount program gives up
> after it receives the PROG_MISMATCH reply from the server.
> 
> Mind applying the following debugging line to the util-linux SRPM, then
> using the resulting "mount" to test out what is going wrong?

I would be happy to, but you forgot to include the debugging line.  =)

Thanks,

Brandon D. Valentine
-- 
brandon@dvalentine.com                           http://www.geekpunk.net
Pseudo-Random Googlism:  sunlight is a project of the california voter
                         foundation to advance electronic filing and
                         internet disclosure of campaign finance data


-------------------------------------------------------
This SF.Net email is sponsored by BEA Weblogic Workshop
FREE Java Enterprise J2EE developer tools!
Get your free copy of BEA WebLogic Workshop 8.1 today.
http://ads.osdn.com/?ad_id=5047&alloc_id=10808&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
