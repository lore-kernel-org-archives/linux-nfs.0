Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:16420 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754462Ab3JIU0G (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 9 Oct 2013 16:26:06 -0400
Date: Wed, 9 Oct 2013 16:25:48 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: Andy Adamson <androsadamson@gmail.com>
Cc: Andi Kleen <andi@firstfloor.org>,
        "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
        Jeff Layton <jlayton@redhat.com>, Coffman Kevin <kwc@citi.umich.edu>,
        NFS list <linux-nfs@vger.kernel.org>
Subject: Re: unread variables in sunrpc kerberos code
Message-ID: <20131009202548.GC29734@pad.fieldses.org>
References: <20130930183926.GB6931@two.firstfloor.org>
 <20131004031643.GA13502@two.firstfloor.org>
 <20131004062915.48772e4b@tlielax.poochiereds.net>
 <DD6C34BD-1F21-4355-BE73-56538E5B29D4@netapp.com>
 <20131007131237.GA20881@pad.fieldses.org>
 <20131008222029.GP6882@two.firstfloor.org>
 <20131009162838.GA29734@pad.fieldses.org>
 <CAHVgHyVXeDPr8vEN=pQz3-1ZH7=f8ouNvWOmxpUV0Lg_8tGP=w@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <CAHVgHyVXeDPr8vEN=pQz3-1ZH7=f8ouNvWOmxpUV0Lg_8tGP=w@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Oct 09, 2013 at 02:33:22PM -0400, Andy Adamson wrote:
> RPCSEC_GSS requires that the GSS-API level sequencing is turned off -
> e.g. the sequence_req_flag is set to false.
> 
> rfc2203:
> 
>   When GSS_Init_sec_context() is called, the parameters
>   replay_det_req_flag and sequence_req_flag must be turned off. The
>   reasons for this are:
> 
>   *    ONC RPC can be used over unreliable transports and provides no
>         layer to reliably re-assemble messages. Thus it is possible for
>         gaps in message sequencing to occur, as well as out of order
>         messages.
> 
>    *    RPC servers can be multi-threaded, and thus the order in which
>         GSS-API messages are signed or wrapped can be different from the
>         order in which the messages are verified or unwrapped, even if
>         the requests are sent on reliable transports.
> 
>    *    To maximize convenience of implementation, the order in which an
>         ONC RPC entity will verify the header and verify/unwrap the body
>         of an RPC call or reply is left unspecified.
> 
>    The RPCSEC_GSS protocol provides for protection from replay attack,
>    yet tolerates out-of-order delivery or processing of messages and
>    tolerates dropped requests.
> 
> 
> So the RPCSEC_GSS layer does the sequencing, not the GSS layer.

Thanks Andy, that RFC text is a good explanation;  I'll add a comment
referencing that.

--b.
