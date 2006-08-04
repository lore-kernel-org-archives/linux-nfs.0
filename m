From: Peter Staubach <staubach@redhat.com>
Subject: Re: [PATCH 3/4] Add /proc/sys/fs/nfs sysctls to nfsd module
Date: Fri, 04 Aug 2006 15:16:40 -0400
Message-ID: <44D39D18.7080907@redhat.com>
References: <20060803110538.GA17173@suse.de>	<76bd70e30608030952p15e1500cy191b5ef19241b58e@mail.gmail.com>	<1154680981.21040.2415.camel@hole.melbourne.sgi.com>	<1154705797.4727.18.camel@localhost>
	<20060804175232.GA29852@suse.de>
	<1154715807.4727.30.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Olaf Kirch <okir@suse.de>, Greg Banks <gnb@melbourne.sgi.com>,
	Linux NFS Mailing List <nfs@lists.sourceforge.net>,
	Chuck Lever <chucklever@gmail.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1G95AI-0005z9-Pq
	for nfs@lists.sourceforge.net; Fri, 04 Aug 2006 12:16:59 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1G95AI-0000Pt-WC
	for nfs@lists.sourceforge.net; Fri, 04 Aug 2006 12:16:59 -0700
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <1154715807.4727.30.camel@localhost>
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

Trond Myklebust wrote:
> On Fri, 2006-08-04 at 19:52 +0200, Olaf Kirch wrote:
>   
>> On Fri, Aug 04, 2006 at 11:36:37AM -0400, Trond Myklebust wrote:
>>     
>>> Not really. It would be better to identify and fix the buggy clients
>>> that aren't setting the READDIRPLUS maxcount parameter correctly.
>>>       
>> One of them was Solaris 9, IIRC. Don't recall what the other one was.
>> I contacted at least Sun, but that didn't go anywhere.
>>     
>
> Yeah.... Solaris appears to have a warped design in their READDIR code.
> They want to specify one size for the actual READDIR reply, and one size
> for all the extra READDIRPLUS gunk (see pages 209 and 210 in Brent's
> 'NFS Illustrated').
> In their case, you want to look at the 'dircount' parameter, and
> truncate the readdirplus reply when you hit 'dircount' bytes of filename
> +fileid information. After that, you have to look at the total XDR
> information, and truncate again when you hit 'maxcount' bytes.
>
> Sucks, sucks, sucks....

Actually, the Solaris implementation matches the intended semantics as
described in RFC1813.  The number of bytes of requested information
via readdir(3) is passed via dircount and then the maximum size of the
response is passed through maxcount.

The two fields were intended to be used to reduce the overhead on
the server by passing a hint for the amount of data that the client
was actually looking for and then a count for the maximum sized response
that it was prepared to handle.

Solaris probably uses something like 1048/32768 or 8192/32768, doesn't
it?

    Thanx...

       ps

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys -- and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
