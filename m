Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ig0-f177.google.com ([209.85.213.177]:36401 "EHLO
	mail-ig0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753201AbcC3SUl (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 30 Mar 2016 14:20:41 -0400
Received: by mail-ig0-f177.google.com with SMTP id nk17so109001827igb.1
        for <linux-nfs@vger.kernel.org>; Wed, 30 Mar 2016 11:20:41 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20160330174040.GA12525@fieldses.org>
References: <CAN-5tyE_Y8gw9MrCwXpY-zjE2b7sdFGTTWMcO6pOZgo4HAy8AA@mail.gmail.com>
	<20160330174040.GA12525@fieldses.org>
Date: Wed, 30 Mar 2016 14:20:40 -0400
Message-ID: <CAHQdGtRyYiC7Ji6Au444bjc-ibBfdJEn=WLG=zy_XfHzzB557A@mail.gmail.com>
Subject: Re: out of order v3 write replies and cache invalidation
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Olga Kornievskaia <aglo@umich.edu>, linux-nfs <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Mar 30, 2016 at 1:40 PM, J. Bruce Fields <bfields@fieldses.org> wrote:
> If we assume no other writers until we close, couldn't you on close wait
> for all writes, send a final getattr for change attribute, and trust
> that?  If the extra getattr's too much, then you'd need some algorithm
> like the above to determine which change attribute is the last.  Or
> implement
> https://tools.ietf.org/html/draft-ietf-nfsv4-minorversion2-41#section-12.2.3
> on client and server and just track the maximum returned value when the
> server returns something other than NFS4_CHANGE_TYPE_IS_UNDEFINED.
>

The correct tool to use for resolving these caching issues is
ultimately a write delegation.

You can also eliminate a lot of invalidations if you know that the
server implements change_attr_type ==
NFS4_CHANGE_TYPE_IS_VERSION_COUNTER or
NFS4_CHANGE_TYPE_IS_VERSION_COUNTER_NOPNFS, since that allows you to
predict what the attribute should be after a change.

Cheers
  Trond
