From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [NFS] "used greatest stack depth: n bytes left" messages
Date: Wed, 12 Sep 2007 15:13:44 -0400
Message-ID: <20070912191344.GB13792@fieldses.org>
References: <46E7CD31.4080306@bull.net>
	<4d569c330709120510o3146454bo44b0a83cc01a6a99@mail.gmail.com>
	<46E7E170.8000903@bull.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net, nfsv4 <nfsv4@linux-nfs.org>
To: Le Rouzic <aime.le-rouzic@bull.net>
Return-path: <nfsv4-bounces@linux-nfs.org>
In-Reply-To: <46E7E170.8000903@bull.net>
List-Unsubscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=unsubscribe>
List-Archive: <http://linux-nfs.org/pipermail/nfsv4>
List-Post: <mailto:nfsv4@linux-nfs.org>
List-Help: <mailto:nfsv4-request@linux-nfs.org?subject=help>
List-Subscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=subscribe>
Sender: nfsv4-bounces@linux-nfs.org
Errors-To: nfsv4-bounces@linux-nfs.org
List-ID: <nfs.lists.sourceforge.net>

On Wed, Sep 12, 2007 at 02:54:08PM +0200, Le Rouzic wrote:
>   CONFIG_DEBUG_STACK_USAGE was already set in my previous kernel configuration
>   but those messages are new  but like you wrote more for debug warning.
>   Nevertheless the question was more to know if they mean some degradation
>   happening. So far, it looks not.

Right, it doesn't necessarily mean anything, it's just telling you the
number of bytes that weren't used on the stack.  If you've got thousands
of bytes left:

> >>Sep 11 12:22:40 frec kernel: loadkeys used greatest stack depth: 4568
> >>bytes left
> >>Sep 11 12:22:40 frec kernel: rc.sysinit used greatest stack depth: 4448
> >>bytes left
> >>Sep 11 12:22:40 frec kernel: readahead used greatest stack depth: 4264
> >>bytes left
> >>Sep 11 13:38:36 frec kernel: mount.nfs4 used greatest stack depth: 4088
> >>bytes left
> >>Sep 11 17:12:08 frec kernel: mount.nfs4 used greatest stack depth: 3512
> >>bytes left

then nothing's coming anywhere near overflowing its stack, so that's
good.  (But do you know what stack size your kernel is using?  I guess
it's >4k, so probably 8k, suggesting some of these processes are using
over 4k, which seems like a lot.)

--b.
