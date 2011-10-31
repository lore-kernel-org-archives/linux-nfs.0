Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:27950 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933097Ab1JaRmq convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 31 Oct 2011 13:42:46 -0400
Subject: Re: [PATCH 2/2] nfs41: handle BLK_LAYOUT CB_RECALL_ANY
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Benny Halevy <bhalevy@tonian.com>
Cc: Peng Tao <bergwolf@gmail.com>, linux-nfs@vger.kernel.org,
        Peng Tao <peng_tao@emc.com>, nfsv4 list <nfsv4@ietf.org>
Date: Mon, 31 Oct 2011 13:42:44 -0400
In-Reply-To: <4EAED61B.7030405@tonian.com>
References: <1320074136-3087-1-git-send-email-bergwolf@gmail.com>
	  <1320074136-3087-2-git-send-email-bergwolf@gmail.com>
	  <1320076148.4714.4.camel@lade.trondhjem.org>
	  <CA+a=Yy4L4GDsQL6hHG4DRLNPmvkMBpk4mW9ofWbQob+z2a1G2A@mail.gmail.com>
	 <1320079501.4714.9.camel@lade.trondhjem.org> <4EAED61B.7030405@tonian.com>
Content-Type: text/plain; charset="UTF-8"
Message-ID: <1320082964.4714.23.camel@lade.trondhjem.org>
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 2011-10-31 at 19:08 +0200, Benny Halevy wrote: 
> On 2011-10-31 18:45, Trond Myklebust wrote:
> > On Tue, 2011-11-01 at 00:38 +0800, Peng Tao wrote: 
> >> On Mon, Oct 31, 2011 at 11:49 PM, Trond Myklebust
> >> <Trond.Myklebust@netapp.com> wrote:
> >>> On Mon, 2011-10-31 at 08:15 -0700, Peng Tao wrote:
> >>>> For blocklayout, we need to issue layoutreturn to return layouts when
> >>>> handling CB_RECALL_ANY.
> >>>
> >>> Why?
> >> Because replying NFS4_OK to CB_RECALL_ANY indicates that client knows
> >> that server wants client to return layout. And server will be waiting
> >> for layoutreturn in such case.
> > 
> > No it doesn't. NFS4_OK means that the client acknowledges that it has
> > been given a new limit on the number of recallable objects it can keep.
> > There is no requirement in the text that it should send layoutreturn or
> > that the server should expect that.
> 
> The motivation for CB_RECALL_ANY is to reduce the state on the *server* side.
> Quoting from RFC5661:
>    The server may decide that it cannot hold all of the state for
>    recallable objects, such as delegations and layouts, without running
>    out of resources.  In such a case, while not optimal, the server is
>    free to recall individual objects to reduce the load.
> ...
>    In order to implement an effective reclaim scheme for such objects,
>    the server's knowledge of available resources must be used to
>    determine when objects must be recalled with the clients selecting
>    the actual objects to be returned.
>                       ^^^^^^^^^^^^^^
> ...
>    When a given resource pool is over-utilized, the server can send a
>    CB_RECALL_ANY to clients holding recallable objects of the types
>    involved, allowing it to keep a certain number of such objects and
>    return any excess.
>    ^^^^^^^^^^^^^^^^^
> ...
>    RCA4_TYPE_MASK_FILE_LAYOUT
> 
>       The client is to return layouts of type LAYOUT4_NFSV4_1_FILES.
>                     ^^^^^^^^^^^^^^^^^
> 
> Isn't that explicit enough?

Leaving aside the fact that the above quotes contain no normative
language:
Right now, we do a bulk return of all layouts. Doing a layoutreturn for
each and every layout in that case is just ridiculous. Either do a
LAYOUTRETURN4_ALL after freeing all the layouts, or don't do anything at
all and just wait for the server to revoke the layouts for us (which is
what we currently do).
Both options should be faster than doing a LAYOUTRETURN4_FILE on each
and every file that is currently in use.

Trond

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

