Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:55790 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726268AbeHXTBN (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 24 Aug 2018 15:01:13 -0400
Date: Fri, 24 Aug 2018 11:26:06 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: "Paul B. Henson" <henson@acm.org>
Cc: linux-nfs@vger.kernel.org
Subject: Re: nfs4-acl-tools 0.3.5
Message-ID: <20180824152606.GB15219@fieldses.org>
References: <20180822003301.GA17500@fieldses.org>
 <d4649560-ad74-d119-13ba-876af9a4974e@acm.org>
 <20180822151213.GA24172@fieldses.org>
 <c1b05b61-b85e-7dff-8cff-12b85bffb3c6@acm.org>
 <20180822194620.GA25562@fieldses.org>
 <2be55f4f-4c9c-9ee1-72f4-b21e37336b6e@acm.org>
 <20180823143835.GB1019@fieldses.org>
 <a52a1f00-69ba-4d09-ae91-d7ae7483d1c1@acm.org>
 <20180823205703.GH32415@fieldses.org>
 <584be3e5-f4d1-3082-5e2c-1a4a74248f22@acm.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
In-Reply-To: <584be3e5-f4d1-3082-5e2c-1a4a74248f22@acm.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Aug 23, 2018 at 05:50:22PM -0700, Paul B. Henson wrote:
> Hmm, the door is open a crack :). When I get a chance to put
> something together I'll be back…

OK.  I can't promise anything.  It all depends on whether it would make
any sense for the NFS reexport case, and I just don't know.

> From a design perspective, would you want this to just take the
> verbatim xdr encoded acl from the file system and shove it over the
> wire, or would you want the NFS server to decode the acl received
> from the extended attribute, process or sanity check as necessary,
> and then re-encode it to send over the wire? The same I guess for
> ones received over the network, pass as is to fs xattr call or
> decode/re-encode.

It'd be simplest to pass it straight through, but the complicated issue
is names.  See the logic in fs/nfsd/idmap.c which defaults to string
names in the krb5 case (where we assume the necessary infrastructure to
get that right is all set up), but ascii-encoded numeric id's in the
auth_sys case (when legacy numeric ID's are the simpler default).

--b.
