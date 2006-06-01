From: "Kevin Coffman" <kwc@citi.umich.edu>
Subject: Re: Fusing Debian patches back into nfs-utils
Date: Thu, 1 Jun 2006 12:42:47 -0400
Message-ID: <4d569c330606010942u6900ca96w1795b5a624ea21ee@mail.gmail.com>
References: <20060601155929.GA890@uio.no>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-list1-b.sourceforge.net ([10.3.1.7]
	helo=sc8-sf-list1.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1FlvUn-0000h1-Ob
	for nfs@lists.sourceforge.net; Thu, 01 Jun 2006 15:18:25 -0700
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 4.30)
	id 1FlvQo-0002Ci-VE
	for nfs@lists.sourceforge.net; Thu, 01 Jun 2006 15:14:18 -0700
Received: from nf-out-0910.google.com ([64.233.182.188])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1FlvQo-0004Yk-I3
	for nfs@lists.sourceforge.net; Thu, 01 Jun 2006 15:14:18 -0700
Received: by nf-out-0910.google.com with SMTP id l36so757222nfa
	for <nfs@lists.sourceforge.net>; Thu, 01 Jun 2006 15:14:17 -0700 (PDT)
To: "Steinar H. Gunderson" <sesse@debian.org>
In-Reply-To: <20060601155929.GA890@uio.no>
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

On 6/1/06, Steinar H. Gunderson <sesse@debian.org> wrote:
> (Please Cc me on any followups, I'm not subscribed to the list)
>
> Hi,

>  - fix_anonuid_and_anongid.diff: The current code uses -2 for default
>    anonymous uid and gid, in the hope that it will be equivalent to 65534.
>    However, on systems with 32-bit uids and gids, this returns another value
>    entirely, which gives rise to an unpredictable default uid and gid (which
>    probably doesn't match what's in passwd and group). This patch fixes the
>    code and documentation to use 65534 explicitly instead.

There is a similar issue in the svcgssd code.  However, while I was
looking into this, it appeared that the kernel code uses "-2" in
places as well.  It seems like a similar change may be needed in the
kernel code as well?

The svcgssd code has the added problem that it really wants to use the
per-export anon values if they were specified differently than the
default.  Those probably need to be passed up in the upcall, or we
need a way of indicating that the default values should be used in the
downcall.

K.C.


_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
