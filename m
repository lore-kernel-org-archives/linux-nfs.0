Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:34886 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751014AbaGKUUp (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 11 Jul 2014 16:20:45 -0400
Date: Fri, 11 Jul 2014 16:20:44 -0400
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: Frank Filz <ffilzlnx@mindspring.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Linux Kernel mailing list <linux-kernel@vger.kernel.org>
Subject: Re: [PATCH 1/1] Fix permission checking by NFS client for
 open-create with mode 000
Message-ID: <20140711202044.GD11931@fieldses.org>
References: <1404942892-18323-1-git-send-email-ffilzlnx@mindspring.com>
 <CAHQdGtSUwScEdUeKT1w+-ynqNz-e1=YvDBtdu_k=_6yndFZSVQ@mail.gmail.com>
 <033801cf9bc7$0d7ee190$287ca4b0$@mindspring.com>
 <CAHQdGtQjCYV2jE7FGu-J+02xp25uaUUVv8uzcs5sfbKXBbVk6A@mail.gmail.com>
 <CAHQdGtTkTh4MQJk6bec46OjsyZHnEGGws3b_2HA+kszzOHM-pw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <CAHQdGtTkTh4MQJk6bec46OjsyZHnEGGws3b_2HA+kszzOHM-pw@mail.gmail.com>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Jul 09, 2014 at 07:12:09PM -0400, Trond Myklebust wrote:
> Oops. Sorry, the correct sub-sub-sub-sub-....paragraph is this one:
> 
>          Permission to execute a file.
> 
>          Servers SHOULD allow a user the ability to read the data of the
>          file when only the ACE4_EXECUTE access mask bit is allowed.
>          This is because there is no way to execute a file without
>          reading the contents.  Though a server may treat ACE4_EXECUTE
>          and ACE4_READ_DATA bits identically when deciding to permit a
>          READ operation, it SHOULD still allow the two bits to be set
>          independently in ACLs, and MUST distinguish between them when
>          replying to ACCESS operations.  In particular, servers SHOULD
>          NOT silently turn on one of the two bits when the other is set,
>          as that would make it impossible for the client to correctly
>          enforce the distinction between read and execute permissions.
> 
> 
> > To me that translates as saying that the server SHOULD accept an
> > OPEN(SHARE_ACCESS_READ|SHARE_ACCESS_WRITE) request in the above
> > situation.
> 
> Same conclusion, though....

Are we sure that's not just a spec bug?

Allowing OPEN(BOTH) on a -wx file seems like a pretty weird result.

--b.
