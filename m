Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ey0-f174.google.com ([209.85.215.174]:65131 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932637Ab1JaRIs (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 31 Oct 2011 13:08:48 -0400
Received: by eye27 with SMTP id 27so5485297eye.19
        for <linux-nfs@vger.kernel.org>; Mon, 31 Oct 2011 10:08:47 -0700 (PDT)
Message-ID: <4EAED61B.7030405@tonian.com>
Date: Mon, 31 Oct 2011 19:08:43 +0200
From: Benny Halevy <bhalevy@tonian.com>
MIME-Version: 1.0
To: Trond Myklebust <Trond.Myklebust@netapp.com>
CC: Peng Tao <bergwolf@gmail.com>, linux-nfs@vger.kernel.org,
        Peng Tao <peng_tao@emc.com>, nfsv4 list <nfsv4@ietf.org>
Subject: Re: [PATCH 2/2] nfs41: handle BLK_LAYOUT CB_RECALL_ANY
References: <1320074136-3087-1-git-send-email-bergwolf@gmail.com>  <1320074136-3087-2-git-send-email-bergwolf@gmail.com>  <1320076148.4714.4.camel@lade.trondhjem.org>  <CA+a=Yy4L4GDsQL6hHG4DRLNPmvkMBpk4mW9ofWbQob+z2a1G2A@mail.gmail.com> <1320079501.4714.9.camel@lade.trondhjem.org>
In-Reply-To: <1320079501.4714.9.camel@lade.trondhjem.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 2011-10-31 18:45, Trond Myklebust wrote:
> On Tue, 2011-11-01 at 00:38 +0800, Peng Tao wrote: 
>> On Mon, Oct 31, 2011 at 11:49 PM, Trond Myklebust
>> <Trond.Myklebust@netapp.com> wrote:
>>> On Mon, 2011-10-31 at 08:15 -0700, Peng Tao wrote:
>>>> For blocklayout, we need to issue layoutreturn to return layouts when
>>>> handling CB_RECALL_ANY.
>>>
>>> Why?
>> Because replying NFS4_OK to CB_RECALL_ANY indicates that client knows
>> that server wants client to return layout. And server will be waiting
>> for layoutreturn in such case.
> 
> No it doesn't. NFS4_OK means that the client acknowledges that it has
> been given a new limit on the number of recallable objects it can keep.
> There is no requirement in the text that it should send layoutreturn or
> that the server should expect that.

The motivation for CB_RECALL_ANY is to reduce the state on the *server* side.
Quoting from RFC5661:
   The server may decide that it cannot hold all of the state for
   recallable objects, such as delegations and layouts, without running
   out of resources.  In such a case, while not optimal, the server is
   free to recall individual objects to reduce the load.
...
   In order to implement an effective reclaim scheme for such objects,
   the server's knowledge of available resources must be used to
   determine when objects must be recalled with the clients selecting
   the actual objects to be returned.
                      ^^^^^^^^^^^^^^
...
   When a given resource pool is over-utilized, the server can send a
   CB_RECALL_ANY to clients holding recallable objects of the types
   involved, allowing it to keep a certain number of such objects and
   return any excess.
   ^^^^^^^^^^^^^^^^^
...
   RCA4_TYPE_MASK_FILE_LAYOUT

      The client is to return layouts of type LAYOUT4_NFSV4_1_FILES.
                    ^^^^^^^^^^^^^^^^^

Isn't that explicit enough?

> 
> In any case, there is no reason to make a difference between block,
> object and file layouts when it comes to CB_RECALL_ANY. The code to
> handle it should be the same for all.
> 

Agreed.

Benny
