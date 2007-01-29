From: "Kevin Coffman" <kwc@citi.umich.edu>
Subject: Re: rpc.gssd segfault on FC5 client
Date: Mon, 29 Jan 2007 17:02:33 -0500
Message-ID: <4d569c330701291402pa6760c4mf64cbfd82cfc6fd2@mail.gmail.com>
References: <1169911208.2767.15.camel@localhost.localdomain>
	<20070128230148.GB12125@fieldses.org>
	<1170030999.9144.8.camel@localhost.localdomain>
	<20070129010419.GF12125@fieldses.org>
	<1170079837.2871.15.camel@localhost.localdomain>
	<45BE5A87.3010204@CS.Arizona.EDU>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: "Jim Davis" <jdavis@cs.arizona.edu>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HBeaC-0002oL-Qb
	for nfs@lists.sourceforge.net; Mon, 29 Jan 2007 14:02:39 -0800
Received: from nf-out-0910.google.com ([64.233.182.186])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HBeaD-0002Bb-BA
	for nfs@lists.sourceforge.net; Mon, 29 Jan 2007 14:02:38 -0800
Received: by nf-out-0910.google.com with SMTP id c31so7064nfb
	for <nfs@lists.sourceforge.net>; Mon, 29 Jan 2007 14:02:34 -0800 (PST)
In-Reply-To: <45BE5A87.3010204@CS.Arizona.EDU>
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

On 1/29/07, Jim Davis <jdavis@cs.arizona.edu> wrote:
> I'm trying to set up Kerberized NFSv3 between a Network Appliance NFS
> server and a Fedora Core 5 and 6 clients, following the outline in
> http://www.netapp.com/library/tr/3481.pdf.  FC6 is working, but trying
> to start rpc.gssd on FC5 fails as the daemon dies with a segmentation fault:

[snip]

> Any ideas on what I've missed, or how to get more useful information out
> of the core dump?

Hmmm,

Interesting.  I'll assume from the addresses listed in gdb that this
is a 32-bit machine.  It looks like the binaries are stripped, so I'm
not sure what we could get from the dump.

I assume you have all the pre-reqs or it wouldn't start.  Just poking
around.  What do the following show?
"rpm -qa | grep nfs"
"rpm -qa | grep krb"

What are the contents of /etc/gssapi_mech.conf?

K.C.

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys - and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
