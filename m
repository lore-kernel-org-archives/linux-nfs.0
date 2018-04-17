Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:53806 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753070AbeDQNV6 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 17 Apr 2018 09:21:58 -0400
Date: Tue, 17 Apr 2018 09:21:56 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: Olga Kornievskaia <kolga@netapp.com>
Cc: linux-nfs <linux-nfs@vger.kernel.org>,
        ng-linux-team <ng-linux-team@netapp.com>
Subject: Re: nfsd issue with a kerberized callback
Message-ID: <20180417132156.GA10291@parsley.fieldses.org>
References: <680B7A1A-792A-4B9E-A0CA-46E459B65077@netapp.com>
 <20180416212942.GA2634@parsley.fieldses.org>
 <EC52DFFD-CB6F-45F5-BAB9-C684C205DE26@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
In-Reply-To: <EC52DFFD-CB6F-45F5-BAB9-C684C205DE26@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Apr 16, 2018 at 08:05:44PM -0400, Olga Kornievskaia wrote:
> > On Apr 16, 2018, at 5:29 PM, J. Bruce Fields <bfields@redhat.com> wrote:
> >> I believe what’s happening is that because the client hasn’t received
> >> CB_NULL that establishes a callback channel but got a CB_RECALL it’s
> >> just ignoring it.
> > 
> > I see two succesful CB_NULL calls and replies, so I think the context
> > establishment worked.  I don't know why there's a third CB_NULL in frame
> > 285.
> 
> The two CB_NULL calls are both gss_init calls. They are not RPC NULL call. Server for some reason establishes 2 different gss context (again not necessarily a problem). The 3rd CB_NULL is gss_data and it sends an actual NULL call. I believe that’s the one that establishes a callback channel.

Oh, I see.  No, that NULL call isn't necessary.  It's just the server
probing to see whether the callback channel works.  That NULL call isn't
required by the spec and everything should still work if the CB_RECALL
is sent out before it completes.

--b.
