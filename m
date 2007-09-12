From: "Kevin Coffman" <kwc@citi.umich.edu>
Subject: Re: "used greatest stack depth: n bytes left" messages
Date: Wed, 12 Sep 2007 08:10:04 -0400
Message-ID: <4d569c330709120510o3146454bo44b0a83cc01a6a99@mail.gmail.com>
References: <46E7CD31.4080306@bull.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net, nfsv4 <nfsv4@linux-nfs.org>
To: "Le Rouzic" <aime.le-rouzic@bull.net>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IVR2h-0008B3-PR
	for nfs@lists.sourceforge.net; Wed, 12 Sep 2007 05:10:03 -0700
Received: from rv-out-0910.google.com ([209.85.198.189])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IVR2l-0000ES-Ch
	for nfs@lists.sourceforge.net; Wed, 12 Sep 2007 05:10:08 -0700
Received: by rv-out-0910.google.com with SMTP id g11so597118rvb
	for <nfs@lists.sourceforge.net>; Wed, 12 Sep 2007 05:10:05 -0700 (PDT)
In-Reply-To: <46E7CD31.4080306@bull.net>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

On 9/12/07, Le Rouzic <aime.le-rouzic@bull.net> wrote:
>
>
>
>  Hi,
>
> Since 2.6.23-RC5 we can get the following kind of messages in
> /var/log/messages:
>
> Sep 11 12:22:40 frec kernel: loadkeys used greatest stack depth: 4568
> bytes left
> Sep 11 12:22:40 frec kernel: rc.sysinit used greatest stack depth: 4448
> bytes left
> Sep 11 12:22:40 frec kernel: readahead used greatest stack depth: 4264
> bytes left
> Sep 11 13:38:36 frec kernel: mount.nfs4 used greatest stack depth: 4088
> bytes left
> Sep 11 17:12:08 frec kernel: mount.nfs4 used greatest stack depth: 3512
> bytes left
>
> Are there only WARNINGs?
> Does that mean we need to act on some kernel parameter ? Which one?
> Can we conclude anything is not normal?
> How nfsv4 can be impacted in its behavior?
>
> Cheers

You must have changed your kernel configuration to include stack debugging?
This message comes from kerne/exit.c and is #ifdef'd with
CONFIG_DEBUG_STACK_USAGE.  So it seems to be more of a debug warning.

-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2005.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
